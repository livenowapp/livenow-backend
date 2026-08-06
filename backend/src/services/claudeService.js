import {
  anthropic,
  MODEL,
} from "../config/anthropic.js";

import {
  SYSTEM_PROMPT,
  buildUserPrompt,
} from "../prompts/reflectionPrompt.js";

import {
  reflectionJsonSchema,
} from "../schemas/reflectionJsonSchema.js";

export async function generateReflection(thought) {
  console.log(
    "SYSTEM PROMPT CHARACTERS:",
    SYSTEM_PROMPT.length
  );

  const message = await anthropic.messages.create({
    model: MODEL,
    max_tokens: 1_200,
    temperature: 0.35,

    system: SYSTEM_PROMPT,

    messages: [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: buildUserPrompt(thought),
          },
        ],
      },
    ],

    output_config: {
      format: {
        type: "json_schema",
        schema: reflectionJsonSchema,
      },
    },
  });

  console.info("Claude usage", {
  inputTokens: message.usage?.input_tokens ?? 0,
  outputTokens: message.usage?.output_tokens ?? 0,
});

  return message;
}