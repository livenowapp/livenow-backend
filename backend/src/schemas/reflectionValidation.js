import { z } from "zod";

const ActionIconSchema = z.enum([
  "action_breath",
  "action_walk",
  "action_chat",
  "action_pencil",
  "action_leaf",
  "action_music",
  "action_sleep",
  "action_sunlight",
  "action_handraised",
  "action_meditation",
  "action_book",
  "action_nophone",
]);

export const ReflectionSchema = z
  .object({
    safety: z
      .object({
        level: z.enum(["normal", "elevated", "urgent"]),
        message: z.string().max(500).nullable(),
      })
      .strict(),

    shortTitle: z.string().min(2).max(30),

    analysis: z
      .array(
        z
          .object({
            type: z.enum([
              "assumption",
              "brain_response",
              "balanced_context",
            ]),
            label: z.string().min(1).max(38),
            sub: z.string().min(1).max(110),
          })
          .strict()
      )
      .length(3),

    evidence: z
      .array(
        z
          .object({
            q: z.string().min(1).max(85),
            a: z.string().min(1).max(75),
          })
          .strict()
      )
      .length(2),

    reframes: z
      .array(z.string().min(1).max(90))
      .length(3),

    actions: z
      .array(
        z
          .object({
            icon: ActionIconSchema,
            label: z.string().min(1).max(70),
          })
          .strict()
      )
      .length(4),

    insight: z.string().min(1).max(120),
  })
  .strict()
  .superRefine((data, context) => {
    const expectedAnalysisTypes = [
      "assumption",
      "brain_response",
      "balanced_context",
    ];

    const receivedTypes = data.analysis.map(
      (item) => item.type
    );

    const hasCorrectAnalysisOrder =
      expectedAnalysisTypes.every(
        (type, index) =>
          receivedTypes[index] === type
      );

    if (!hasCorrectAnalysisOrder) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["analysis"],
        message:
          "Analysis items must be in the required order.",
      });
    }

    const normalizedReframes = data.reframes.map((item) =>
      item.toLowerCase().trim()
    );

    if (new Set(normalizedReframes).size !== 3) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["reframes"],
        message: "Reframes must be meaningfully distinct.",
      });
    }

    const normalizedActions = data.actions.map((item) =>
      item.label.toLowerCase().trim()
    );

    if (new Set(normalizedActions).size !== 4) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["actions"],
        message: "Actions must be distinct.",
      });
    }

    if (
      data.safety.level === "normal" &&
      data.safety.message !== null
    ) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["safety", "message"],
        message:
          "Normal responses must not include a safety message.",
      });
    }

    if (
      data.safety.level !== "normal" &&
      !data.safety.message?.trim()
    ) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["safety", "message"],
        message:
          "Elevated and urgent responses must include a safety message.",
      });
    }

    const actionIcons = data.actions.map(
      (item) => item.icon
    );

    if (new Set(actionIcons).size < 3) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["actions"],
        message:
          "Actions must use at least three different icons.",
      });
    }

    const calmingIcons = new Set([
      "action_breath",
      "action_leaf",
      "action_meditation",
    ]);

    const calmingActionCount =
      data.actions.filter((action) =>
        calmingIcons.has(action.icon)
      ).length;

    if (calmingActionCount > 1) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["actions"],
        message:
          "Only one calming action icon may be used.",
      });
    }
  });

export const AnalyzeRequestSchema = z
  .object({
    thought: z.string(),
  })
  .strict();