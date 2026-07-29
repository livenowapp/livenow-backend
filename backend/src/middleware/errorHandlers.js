export function notFoundHandler(req, res) {
  return res.status(404).json({
    error: {
      code: "NOT_FOUND",
      message: "Route not found.",
    },
  });
}

export function errorHandler(error, _req, res, _next) {
  if (error instanceof SyntaxError && "body" in error) {
    return res.status(400).json({
      error: {
        code: "INVALID_JSON",
        message: "The request body contains invalid JSON.",
      },
    });
  }

  if (
    error instanceof Error &&
    error.message === "Origin not allowed by CORS."
  ) {
    return res.status(403).json({
      error: {
        code: "ORIGIN_NOT_ALLOWED",
        message: "This origin is not allowed.",
      },
    });
  }

  console.error("Unhandled server error", {
    errorName: error?.name,
    errorMessage:
      process.env.NODE_ENV === "development"
        ? error?.message
        : undefined,
  });

  return res.status(500).json({
    error: {
      code: "SERVER_ERROR",
      message: "An unexpected server error occurred.",
    },
  });
}