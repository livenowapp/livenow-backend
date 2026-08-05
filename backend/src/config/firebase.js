import "dotenv/config";
import fs from "node:fs";
import {
  cert,
  getApps,
  initializeApp,
} from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

const firebaseServiceAccountPath =
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

if (!firebaseServiceAccountPath) {
  throw new Error(
    "Missing FIREBASE_SERVICE_ACCOUNT_PATH environment variable."
  );
}

const serviceAccount = JSON.parse(
  fs.readFileSync(firebaseServiceAccountPath, "utf8")
);

if (getApps().length === 0) {
  initializeApp({
    credential: cert(serviceAccount),
  });
}

export const firebaseAuth = getAuth();
export const firebaseDb = getFirestore();