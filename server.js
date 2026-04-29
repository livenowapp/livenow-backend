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
      error: "No thought provided"
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
- choose the 4 most relevant actions based on the user's specific thought

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

Return exactly 4 actions.
Choose the actions that best match the user's thought.

Action meaning:
- wind = breathing / calming body
- figure.walk = movement / walk / physical reset
- bubble.left.and.bubble.right = talking to someone / connection
- pencil = journaling / writing down
- leaf = grounding / noticing surroundings
- music.note = calming music / sensory reset

Keep action labels short.
Good examples:
- "take 3 slow breaths"
- "step outside for 2 minutes"
- "text someone you trust"
- "write the thought down"
- "notice 5 things around you"
- "play one calming song"
`;

    const msg = await anthropic.messages.create({
  model: "claude-3-haiku-20240307",
  max_tokens: 700,
  messages: [
    {
      role: "user",
      content: prompt
    }
  ]
});

    const text = msg.content?.[0]?.text || "";

try {
  const parsed = JSON.parse(text);
  res.json(parsed);
} catch (e) {
  console.error("JSON PARSE ERROR:", text);

  res.json({
    analysis: [{ label: "something went wrong", sub: "try again" }],
    evidence: [],
    reframes: ["This is just a temporary error."],
    actions: [],
    insight: "AI response could not be parsed"
  });
}

  } catch (err) {
    console.error("AI ERROR:", err);
    res.status(500).json({
      error: "AI error"
    });
  }
});

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});