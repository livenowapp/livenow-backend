export function createRequestId() {
  return crypto.randomUUID();
}

export function normalizeThought(value) {
  if (typeof value !== "string") {
    return "";
  }

  return value
    .normalize("NFKC")
    .replace(/\u0000/g, "")
    .replace(/[ \t]+/g, " ")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

export function getUserKey(req) {
  const firebaseUid = req.user?.uid;

  if (
    typeof firebaseUid === "string" &&
    firebaseUid.trim().length > 0 &&
    firebaseUid.length <= 128
  ) {
    return `firebase-user:${firebaseUid}`;
  }

  // Pri zaščitenem /analyze endpointu se to ne bi smelo zgoditi,
  // vendar fallback prepreči nepričakovano sesutje.
  return `ip:${req.ip ?? "unknown"}`;
}

export function extractTextFromClaudeMessage(message) {
  return message.content
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("")
    .trim();
}

export function getPublicError(error) {
  const status = Number(error?.status);

  if (status === 400) {
    return {
      status: 502,
      code: "MODEL_REQUEST_ERROR",
      message:
        "The reflection could not be generated. Please try again.",
    };
  }

  if (status === 401 || status === 403) {
    return {
      status: 500,
      code: "SERVER_CONFIGURATION_ERROR",
      message:
        "The reflection service is temporarily unavailable.",
    };
  }

  if (status === 429) {
    return {
      status: 503,
      code: "AI_RATE_LIMITED",
      message:
        "The reflection service is busy. Please try again shortly.",
    };
  }

  if (status === 529) {
    return {
      status: 503,
      code: "AI_OVERLOADED",
      message:
        "The reflection service is temporarily busy.",
    };
  }

  if (
    error?.name === "AbortError" ||
    error?.name === "APIConnectionTimeoutError"
  ) {
    return {
      status: 504,
      code: "AI_TIMEOUT",
      message:
        "The reflection took too long. Please try again.",
    };
  }

  return {
    status: 500,
    code: "AI_ERROR",
    message:
      "The reflection could not be generated. Please try again.",
  };
}