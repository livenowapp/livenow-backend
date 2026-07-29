import cors from "cors";

const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS
      .split(",")
      .map((origin) => origin.trim())
      .filter(Boolean)
  : [];

export const corsMiddleware = cors({
  origin(origin, callback) {
    // Native iOS requests usually do not contain a browser Origin.
    if (!origin) {
      return callback(null, true);
    }

    // During development, allow all browser origins when no list
    // has been configured.
    if (ALLOWED_ORIGINS.length === 0) {
      return callback(null, true);
    }

    if (ALLOWED_ORIGINS.includes(origin)) {
      return callback(null, true);
    }

    return callback(new Error("Origin not allowed by CORS."));
  },

  methods: ["GET", "POST"],

  allowedHeaders: [
    "Content-Type",
    "Authorization",
    "X-User-ID",
  ],
});