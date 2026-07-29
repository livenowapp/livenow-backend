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
  const message = await anthropic.messages.create({
    model: MODEL,
    max_tokens: 1_200,
    temperature: 0.35,

    system: SYSTEM_PROMPT,

    messages: [
      {
        role: "user",
        content: buildUserPrompt(thought),
      },
    ],

    output_config: {
      format: {
        type: "json_schema",
        schema: reflectionJsonSchema,
      },
    },
  });

  return message;
}