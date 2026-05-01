import express from "express";
import cors from "cors";
import Anthropic from "@anthropic-ai/sdk";

const app = express();

app.use(cors());
app.use(express.json());

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

const APP_SECRET = process.env.APP_SECRET;

// očisti Claude response
function cleanClaudeJson(text) {
  return text
    .replace(/```json/gi, "")
    .replace(/```/g, "")
    .trim();
}

app.post("/analyze", async (req, res) => {
  // 🔐 ZAŠČITA
  const clientSecret = req.headers["x-app-secret"];

  if (clientSecret !== APP_SECRET) {
    return res.status(401).json({
      error: "Unauthorized",
    });
  }

  const thought = req.body.thought || "";

  if (!thought.trim()) {
    return res.status(400).json({
      error: "No thought provided",
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
- keep tone warm, short, practical
- no diagnosis
- choose EXACTLY 4 actions that best match the thought
- keep all responses very short
- limit each sentence to under 12 words

Available actions (choose only from these):

- wind — take 3 slow breaths
- figure.walk — take a short walk
- bubble.left.and.bubble.right — text someone you trust
- pencil — write the thought down
- leaf — notice 5 things around you
- music.note — play calming music
- drop — drink water
- bed.double — rest for a few minutes
- sun.max — step into daylight
- hand.raised — pause before reacting
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