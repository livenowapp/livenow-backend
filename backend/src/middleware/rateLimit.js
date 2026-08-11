import {
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";

import {
  firebaseDb,
} from "../config/firebase.js";

const COOLDOWN_MS = 10 * 1000;
const DAILY_LIMIT = 20;

function getTodayKey() {
  return new Date().toISOString().slice(0, 10);
}

export async function checkRateLimit(firebaseUid) {
  if (
    typeof firebaseUid !== "string" ||
    firebaseUid.trim().length === 0 ||
    firebaseUid.length > 128
  ) {
    return {
      allowed: false,
      status: 401,
      retryAfterSeconds: null,
      message: "A valid authenticated user is required.",
    };
  }

  const now = Date.now();
  const today = getTodayKey();

  const rateLimitReference = firebaseDb
    .collection("rateLimits")
    .doc(firebaseUid);

  try {
    return await firebaseDb.runTransaction(
      async (transaction) => {
        const snapshot = await transaction.get(
          rateLimitReference
        );

        const storedData = snapshot.exists
          ? snapshot.data()
          : null;

        const storedDate =
          typeof storedData?.date === "string"
            ? storedData.date
            : null;

        const isSameDay = storedDate === today;

        const currentCount =
          isSameDay &&
          Number.isInteger(storedData?.count)
            ? storedData.count
            : 0;

        const lastRequestAt =
          isSameDay &&
          storedData?.lastRequestAt instanceof Timestamp
            ? storedData.lastRequestAt.toMillis()
            : 0;

        const cooldownRemaining =
          COOLDOWN_MS - (now - lastRequestAt);

        if (cooldownRemaining > 0) {
          return {
            allowed: false,
            status: 429,
            retryAfterSeconds: Math.ceil(
              cooldownRemaining / 1000
            ),
            message:
              "Please wait a few seconds before analyzing again.",
          };
        }

        if (currentCount >= DAILY_LIMIT) {
          return {
            allowed: false,
            status: 429,
            retryAfterSeconds: null,
            message: "You've reached today's reflection limit. You can continue tomorrow.",
          };
        }

        const updatedCount = currentCount + 1;

        console.info("Rate limit updated", {
          date: today,
          count: updatedCount,
        });

        transaction.set(
          rateLimitReference,
          {
            uid: firebaseUid,
            date: today,
            count: updatedCount,
            lastRequestAt: Timestamp.fromMillis(now),
            updatedAt: FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          }
        );

        return {
          allowed: true,
          remaining: DAILY_LIMIT - updatedCount,
        };
      }
    );
  } catch (error) {
    console.error("Firestore rate-limit error:", {
      errorName: error?.name,
      errorMessage: error?.message,
    });

    return {
      allowed: false,
      status: 503,
      retryAfterSeconds: null,
      message:
        "The reflection service is temporarily unavailable. Please try again.",
    };
  }
}
