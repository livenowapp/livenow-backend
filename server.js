import express from "express";
import cors from "cors";
import Anthropic from "@anthropic-ai/sdk";

const app = express();

app.use(cors());
app.use(express.json());

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

function cleanClaudeJson(text) {
  return text
    .replace(/```json/gi, "")
    .replace(/```/g, "")
    .trim();
}

// ----------------------------
// Basic protection
// ----------------------------

const userLimits = new Map();

const COOLDOWN_MS = 10 * 1000;
const DAILY_LIMIT = 100;
const MAX_THOUGHT_LENGTH = 800;

function getTodayKey() {
  return new Date().toISOString().slice(0, 10);
}

function checkRateLimit(userKey) {
  const today = getTodayKey();
  const now = Date.now();

  const current = userLimits.get(userKey) || {
    date: today,
    count: 0,
    lastRequestAt: 0,
  };

  if (current.date !== today) {
    current.date = today;
    current.count = 0;
    current.lastRequestAt = 0;
  }

  if (now - current.lastRequestAt < COOLDOWN_MS) {
    return {
      allowed: false,
      status: 429,
      message: "Please wait a few seconds before analyzing again.",
    };
  }

  if (current.count >= DAILY_LIMIT) {
    return {
      allowed: false,
      status: 429,
      message: "Daily analysis limit reached.",
    };
  }

  current.count += 1;
  current.lastRequestAt = now;

  userLimits.set(userKey, current);

  return { allowed: true };
}

app.post("/analyze", async (req, res) => {
  const thought = req.body.thought || "";

  // Empty thought
  if (!thought.trim()) {
    return res.status(400).json({
      error: "No thought provided",
    });
  }

  // Too long
  if (thought.length > MAX_THOUGHT_LENGTH) {
    return res.status(400).json({
      error: "Thought is too long",
    });
  }

  // Temporary protection by IP
  const userKey = req.ip;

  const limitCheck = checkRateLimit(userKey);

  if (!limitCheck.allowed) {
    return res.status(limitCheck.status).json({
      error: limitCheck.message,
    });
  }

  try {
    const prompt = `
User thought: "${thought}"

Act as a calm mental clarity assistant.

Respond in VALID JSON only (no markdown, no text outside JSON).

Format:
{
  "analysis": [
    { "label": "...", "sub": "..." },
    { "label": "...", "sub": "..." },
    { "label": "...", "sub": "..." }
  ],
  "evidence": [
    { "q": "...", "a": "..." },
    { "q": "...", "a": "..." }
  ],
  "reframes": ["...", "...", "..."],
  "actions": [
    { "icon": "...", "label": "..." },
    { "icon": "...", "label": "..." },
    { "icon": "...", "label": "..." },
    { "icon": "...", "label": "..." }
  ],
  "insight": "..."
}

Rules:
- Return EXACTLY 3 analysis items.
- Return EXACTLY 2 evidence items.
- Return EXACTLY 3 reframes.
- Return EXACTLY 4 actions.
- keep tone warm, short, practical
- no diagnosis
- Keep all responses very short.
- Limit each sentence to under 12 words.
- For every action, icon must be one exact value from Available actions.
- Do not use emojis or SF Symbols.

Available actions.

Choose only from these icon values.
The icon value must match exactly:

- action_breath — take 3 slow breaths
- action_walk — take a short walk
- action_chat — text someone you trust
- action_pencil — write the thought down
- action_leaf — notice 5 things around you
- action_music — play calming music
- action_sleep — rest for a few minutes
- action_sunlight — step into daylight
- action_handraised — pause before reacting
- action_meditation — meditate for 10 minutes
- action_book — read 10 pages
- action_nophone — put your phone away
`;

    const msg = await anthropic.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 700,
      temperature: 0.4,
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    });

    const rawText = msg.content?.[0]?.text || "";
    const cleanedText = cleanClaudeJson(rawText);

    console.log("CLAUDE CLEAN:", cleanedText);

    const jsonStart = cleanedText.indexOf("{");
    const jsonEnd = cleanedText.lastIndexOf("}");

    if (jsonStart === -1 || jsonEnd === -1) {
      throw new Error("No JSON found in Claude response");
    }

    const jsonText = cleanedText.slice(jsonStart, jsonEnd + 1);
    const parsed = JSON.parse(jsonText);

    return res.json(parsed);

  } catch (err) {
    console.error("AI ERROR:", err);

    return res.status(500).json({
      error: "AI error",
    });
  }
});

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});