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
    const msg = await anthropic.messages.create({
      model: "claude-3-sonnet-20240229",
      max_tokens: 100,
      messages: [
        {
          role: "user",
          content: "Return ONLY this JSON: {\"test\":\"ok\"}",
        },
      ],
    });

    const text = msg.content?.[0]?.text || "";

    console.log("CLAUDE RAW:", text);

    return res.json({
      raw: text,
    });
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