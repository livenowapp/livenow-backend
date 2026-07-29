import "dotenv/config";
import Anthropic from "@anthropic-ai/sdk";

if (!process.env.ANTHROPIC_API_KEY) {
  throw new Error(
    "Missing ANTHROPIC_API_KEY environment variable."
  );
}

export const MODEL =
  process.env.ANTHROPIC_MODEL ||
  "claude-haiku-4-5-20251001";

export const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
  timeout: 20_000,
  maxRetries: 2,
});