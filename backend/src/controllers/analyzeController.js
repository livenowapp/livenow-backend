import {
  checkRateLimit,
  refundRateLimit,
} from "../middleware/rateLimit.js";

import {
  generateReflection,
} from "../services/claudeService.js";

import {
  ReflectionSchema,
  AnalyzeRequestSchema,
} from "../schemas/reflectionValidation.js";

import {
  createRequestId,
  normalizeThought,
  extractTextFromClaudeMessage,
  getPublicError,
} from "../utils/reflectionHelpers.js";

const MAX_THOUGHT_LENGTH = 800;
const MIN_THOUGHT_LENGTH = 2;

export async function analyzeController(req, res) {
  const requestId = createRequestId();
  const startedAt = Date.now();

  // ----------------------------------------------------------
  // Validate request body
  // ----------------------------------------------------------

  const bodyResult =
    AnalyzeRequestSchema.safeParse(req.body);

  if (!bodyResult.success) {
    return res.status(400).json({
      error: {
        code: "INVALID_REQUEST",
        message:
          "The request must contain a thought.",
        requestId,
      },
    });
  }

  const thought = normalizeThought(
    bodyResult.data.thought
  );

  if (thought.length < MIN_THOUGHT_LENGTH) {
    return res.status(400).json({
      error: {
        code: "EMPTY_THOUGHT",
        message:
          "Please write a little more about what is on your mind.",
        requestId,
      },
    });
  }

  if (thought.length > MAX_THOUGHT_LENGTH) {
    return res.status(400).json({
      error: {
        code: "THOUGHT_TOO_LONG",
        message:
          `Please keep your thought under ${MAX_THOUGHT_LENGTH} characters.`,
        requestId,
      },
    });
  }

  // ----------------------------------------------------------
  // Authentication
  // ----------------------------------------------------------

  const firebaseUid = req.user?.uid;

  if (!firebaseUid) {
    return res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message:
          "Please sign in and try again.",
        requestId,
      },
    });
  }

  // ----------------------------------------------------------
  // Rate limiting
  //
  // Reserve one daily request before calling Claude.
  // If Claude fails or returns unusable output,
  // the reservation is refunded.
  // ----------------------------------------------------------

  const limitCheck =
    await checkRateLimit(firebaseUid);

  if (!limitCheck.allowed) {
    if (limitCheck.retryAfterSeconds) {
      res.set(
        "Retry-After",
        String(limitCheck.retryAfterSeconds)
      );
    }

    return res.status(limitCheck.status).json({
      error: {
        code:
          limitCheck.status === 503
            ? "RATE_LIMIT_UNAVAILABLE"
            : "RATE_LIMITED",
        message: limitCheck.message,
        requestId,
      },
    });
  }

  let shouldRefundRateLimit = true;

  // ----------------------------------------------------------
  // Claude request
  // ----------------------------------------------------------

  try {
    const message =
      await generateReflection(thought);

    if (message.stop_reason === "refusal") {
      console.warn("Claude request refused", {
        requestId,
        durationMs:
          Date.now() - startedAt,
      });

      await refundRateLimit(firebaseUid);
      shouldRefundRateLimit = false;

      return res.status(422).json({
        error: {
          code:
            "REFLECTION_NOT_AVAILABLE",
          message:
            "A reflection isn't available for this message.",
          requestId,
        },
      });
    }

    const rawText =
      extractTextFromClaudeMessage(message);

    if (!rawText) {
      throw new Error(
        "Claude returned no text content."
      );
    }

    let json;

    try {
      json = JSON.parse(rawText);
    } catch {
      throw new Error(
        "Claude returned invalid JSON despite structured output."
      );
    }

    const validationResult =
      ReflectionSchema.safeParse(json);

    if (!validationResult.success) {
      console.error(
        "Claude response validation failed",
        {
          requestId,
          issues:
            validationResult.error.issues.map(
              (issue) => ({
                path:
                  issue.path.join("."),
                message:
                  issue.message,
              })
            ),
        }
      );

      await refundRateLimit(firebaseUid);
      shouldRefundRateLimit = false;

      return res.status(502).json({
        error: {
          code: "INVALID_AI_RESPONSE",
          message:
            "The reflection could not be prepared. Please try again.",
          requestId,
        },
      });
    }

    const reflection =
      validationResult.data;

    // The reflection succeeded, so keep the
    // reserved daily request.
    shouldRefundRateLimit = false;

    // Do not log the thought or generated reflection.
    console.info("Reflection generated", {
      requestId,
      durationMs:
        Date.now() - startedAt,
      safetyLevel:
        reflection.safety.level,
      inputTokens:
        message.usage?.input_tokens,
      outputTokens:
        message.usage?.output_tokens,
      remainingDailyRequests:
        limitCheck.remaining,
    });

    return res.status(200).json({
      ...reflection,
      meta: {
        requestId,
      },
    });
  } catch (error) {
    if (shouldRefundRateLimit) {
      await refundRateLimit(firebaseUid);
      shouldRefundRateLimit = false;
    }

    const publicError =
      getPublicError(error);

    // Log technical metadata, not the user's private thought.
    console.error("AI request failed", {
      requestId,
      durationMs:
        Date.now() - startedAt,
      errorName: error?.name,
      errorStatus: error?.status,
    });

    return res
      .status(publicError.status)
      .json({
        error: {
          code: publicError.code,
          message: publicError.message,
          requestId,
        },
      });
  }
}