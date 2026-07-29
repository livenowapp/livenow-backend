const COOLDOWN_MS = 10 * 1000;
const DAILY_LIMIT = 100;

// Remove inactive in-memory rate-limit entries after this period.
const RATE_LIMIT_ENTRY_TTL_MS = 48 * 60 * 60 * 1000;

const userLimits = new Map();

function getTodayKey() {
  return new Date().toISOString().slice(0, 10);
}

export function checkRateLimit(userKey) {
  const now = Date.now();
  const today = getTodayKey();

  const current = userLimits.get(userKey) || {
    date: today,
    count: 0,
    lastRequestAt: 0,
    lastSeenAt: now,
  };

  if (current.date !== today) {
    current.date = today;
    current.count = 0;
    current.lastRequestAt = 0;
  }

  current.lastSeenAt = now;

  const cooldownRemaining =
    COOLDOWN_MS - (now - current.lastRequestAt);

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

  if (current.count >= DAILY_LIMIT) {
    return {
      allowed: false,
      status: 429,
      retryAfterSeconds: null,
      message: "Daily analysis limit reached.",
    };
  }

  current.count += 1;
  current.lastRequestAt = now;

  userLimits.set(userKey, current);

  return {
    allowed: true,
    remaining: DAILY_LIMIT - current.count,
  };
}

// Periodically remove old rate-limit entries so the Map
// does not grow forever.
const cleanupInterval = setInterval(() => {
  const cutoff = Date.now() - RATE_LIMIT_ENTRY_TTL_MS;

  for (const [key, value] of userLimits.entries()) {
    if (value.lastSeenAt < cutoff) {
      userLimits.delete(key);
    }
  }
}, 60 * 60 * 1000);

cleanupInterval.unref();