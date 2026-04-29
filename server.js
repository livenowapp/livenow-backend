import express from "express";
import cors from "cors";
import Anthropic from "@anthropic-ai/sdk";

const app = express();

app.use(cors());
app.use(express.json());

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

app.post("/analyze", async (req, res) => {
  const thought = req.body.thought || "";

  if (!thought.trim()) {
    return res.status(400).json({
      error: "No thought provided",
    });
  }

  try {
    const prompt = `
User thought: "${thought}"

You are a calm mental clarity assistant for an app called LiveNow.

Your job:
- help the user question an anxious or overthinking thought
- do not diagnose
- do not sound clinical
- keep everything short, warm, and practical
- choose the 6 most relevant actions based on the user's specific thought

Return ONLY valid JSON.
Do not include markdown.
Do not include explanation outside JSON.

Use this exact structure:

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
    { "icon": "...", "label": "..." },
    { "icon": "...", "label": "..." },
    { "icon": "...", "label": "..." }
  ],
  "insight": "..."
}

Action icon rules:
Use ONLY these SF Symbol icon names:
- wind
- figure.walk
- bubble.left.and.bubble.right
- pencil
- leaf
- music.note

Return exactly 6 actions.

Keep action labels short.
`;

    const msg = await anthropic.messages.create({
      model: "claude-opus-4-7",
      max_tokens: 900,
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    });

    const text = msg.content?.[0]?.text || "";

    console.log("CLAUDE RAW:", text);

    const jsonStart = text.indexOf("{");
    const jsonEnd = text.lastIndexOf("}");

    if (jsonStart === -1 || jsonEnd === -1) {
      throw new Error("No JSON found in Claude response");
    }

    const jsonText = text.slice(jsonStart, jsonEnd + 1);
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