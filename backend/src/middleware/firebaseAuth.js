import {
  firebaseAuth,
} from "../config/firebase.js";

export async function requireFirebaseAuth(req, res, next) {
  try {
    const authorizationHeader = req.headers.authorization;

    if (
      !authorizationHeader ||
      !authorizationHeader.startsWith("Bearer ")
    ) {
      return res.status(401).json({
        error: "Unauthorized",
        message: "Missing Firebase ID token.",
      });
    }

    const idToken = authorizationHeader
      .slice("Bearer ".length)
      .trim();

    if (!idToken) {
      return res.status(401).json({
        error: "Unauthorized",
        message: "Missing Firebase ID token.",
      });
    }

    const decodedToken =
      await firebaseAuth.verifyIdToken(idToken);

    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email ?? null,
    };

    next();
  } catch (error) {
    console.error("Firebase authentication failed:", error);

    return res.status(401).json({
      error: "Unauthorized",
      message: "Invalid or expired Firebase ID token.",
    });
  }
}