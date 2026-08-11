import "dotenv/config";
import express from "express";

import {
  MODEL,
} from "./src/config/anthropic.js";

import analyzeRouter from "./src/routes/analyze.js";

import {
  notFoundHandler,
  errorHandler,
} from "./src/middleware/errorHandlers.js";

import {
  corsMiddleware,
} from "./src/middleware/corsMiddleware.js";

// ============================================================
// Configuration
// ============================================================


const PORT = Number(process.env.PORT) || 3001;

// ============================================================
// Validate required environment variables
// ============================================================


// ============================================================
// App and API client
// ============================================================

const app = express();

// If your production host places Express behind exactly one
// trusted reverse proxy, set TRUST_PROXY=1.
//
// Do not enable this blindly unless it matches your host.
if (process.env.TRUST_PROXY) {
  const trustProxyValue = Number(process.env.TRUST_PROXY);

  app.set(
    "trust proxy",
    Number.isNaN(trustProxyValue)
      ? process.env.TRUST_PROXY
      : trustProxyValue
  );
}

// ============================================================
// Middleware
// ============================================================

app.disable("x-powered-by");

app.use(corsMiddleware);

app.use(
  express.json({
    limit: "10kb",
    strict: true,
  })
);

// ============================================================
// Allowed action icons
// ============================================================


// ============================================================
// Claude Structured Output JSON Schema
// ============================================================


// ============================================================
// Zod response validation
// ============================================================


// ============================================================
// Request input schema
// ============================================================


// ============================================================
// In-memory rate limiting
//
// Suitable for development and early testing.
// Replace with Redis or another shared data store before scaling
// to multiple server instances.
// ============================================================


// ============================================================
// Helper functions
// ============================================================


// ============================================================
// Prompts
// ============================================================



// ============================================================
// Routes
// ============================================================

app.get("/health", (_req, res) => {
  return res.status(200).json({
    status: "ok",
  });
});

app.use("/analyze", analyzeRouter);

// ============================================================
// 404 and error handlers
// ============================================================

app.use(notFoundHandler);
app.use(errorHandler);

// ============================================================
// Start server
// ============================================================

const server = app.listen(PORT, () => {
  console.log(`LiveNow server running on port ${PORT}`);
  console.log(`Claude model: ${MODEL}`);
});

// ============================================================
// Graceful shutdown
// ============================================================

function shutdown(signal) {
  console.log(`${signal} received. Shutting down.`);

  server.close(() => {
    console.log("Server closed.");
    process.exit(0);
  });

  setTimeout(() => {
    console.error("Forced shutdown after timeout.");
    process.exit(1);
  }, 10_000).unref();
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));