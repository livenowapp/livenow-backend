import express from "express";
import cors from "cors";

const app = express();

app.use(cors());
app.use(express.json());

const actionsPool = [
  {
    icon: "wind",
    label: "take 3 slow breaths"
  },
  {
    icon: "figure.walk",
    label: "take a short walk"
  },
  {
    icon: "bubble.left.and.bubble.right",
    label: "talk to someone"
  },
  {
    icon: "pencil",
    label: "write it down"
  },
  {
    icon: "leaf",
    label: "focus on your surroundings"
  },
  {
    icon: "music.note",
    label: "listen to calming music"
  }
];

function getRandomActions(arr, n) {
  return [...arr].sort(() => 0.5 - Math.random()).slice(0, n);
}

app.post("/analyze", async (req, res) => {
  const thought = req.body.thought || "";

  if (!thought.trim()) {
    return res.status(400).json({
      error: "No thought provided"
    });
  }

  try {
    res.json({
      analysis: [
        {
          label: "possible distortion",
          sub: "This thought may be assuming the worst without full evidence."
        },
        {
          label: "what your mind is doing",
          sub: "Your brain is trying to protect you, but it may be overpredicting danger."
        }
      ],
      evidence: [
        {
          q: "Do you have clear proof this is true?",
          a: "Not necessarily"
        },
        {
          q: "Could there be another explanation?",
          a: "Yes, there usually is"
        }
      ],
      reframes: [
        "This is a thought, not a fact.",
        "I do not have enough evidence to assume the worst.",
        "I can pause before believing this story."
      ],
      actions: getRandomActions(actionsPool, 4),
      insight: "You may be treating uncertainty like danger."
    });
  } catch (err) {
    res.status(500).json({
      error: "AI error"
    });
  }
});

app.listen(3001, () => {
  console.log("Server running on port 3001");
});