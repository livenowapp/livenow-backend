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
    inputAssessment: z.enum([
      "analyzable",
      "not_overthinking",
      "too_vague",
    ]),

    safety: z
      .object({
        level: z.enum([
          "normal",
          "elevated",
          "urgent",
        ]),
        message: z
          .string()
          .max(500)
          .nullable(),
      })
      .strict(),

    shortTitle: z
      .string()
      .min(2)
      .max(35),

    analysis: z.array(
      z
        .object({
          type: z.enum([
            "assumption",
            "brain_response",
            "balanced_context",
          ]),
          label: z
            .string()
            .min(1)
            .max(50),
          sub: z
            .string()
            .min(1)
            .max(150),
        })
        .strict()
    ),

    evidence: z.array(
      z
        .object({
          q: z
            .string()
            .min(1)
            .max(100),
          a: z
            .string()
            .min(1)
            .max(100),
        })
        .strict()
    ),

    reframes: z.array(
      z
        .string()
        .min(1)
        .max(130)
    ),

    actions: z.array(
      z
        .object({
          icon: ActionIconSchema,
          label: z
            .string()
            .min(1)
            .max(130),
        })
        .strict()
    ),

    insight: z
      .string()
      .min(1)
      .max(160),
  })
  .strict()
  .superRefine((data, context) => {

    // MARK: - INPUT ASSESSMENT

    if (data.inputAssessment === "analyzable") {

      if (data.analysis.length !== 3) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["analysis"],
          message:
            "Analyzable responses must contain exactly 3 analysis items.",
        });
      }

      if (data.evidence.length !== 2) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["evidence"],
          message:
            "Analyzable responses must contain exactly 2 evidence items.",
        });
      }

      if (data.reframes.length !== 3) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["reframes"],
          message:
            "Analyzable responses must contain exactly 3 reframes.",
        });
      }

      if (data.actions.length !== 4) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["actions"],
          message:
            "Analyzable responses must contain exactly 4 actions.",
        });
      }

    } else {

      if (data.analysis.length !== 0) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["analysis"],
          message:
            "Non-analyzable responses must return an empty analysis array.",
        });
      }

      if (data.evidence.length !== 0) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["evidence"],
          message:
            "Non-analyzable responses must return an empty evidence array.",
        });
      }

      if (data.reframes.length !== 0) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["reframes"],
          message:
            "Non-analyzable responses must return an empty reframes array.",
        });
      }

      if (data.actions.length !== 0) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["actions"],
          message:
            "Non-analyzable responses must return an empty actions array.",
        });
      }
    }

    // MARK: - ANALYSIS ORDER

    if (
      data.inputAssessment === "analyzable" &&
      data.analysis.length === 3
    ) {
      const expectedAnalysisTypes = [
        "assumption",
        "brain_response",
        "balanced_context",
      ];

      const receivedTypes =
        data.analysis.map(
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
    }

    // MARK: - DISTINCT REFRAMES

    if (
      data.inputAssessment === "analyzable" &&
      data.reframes.length === 3
    ) {
      const normalizedReframes =
        data.reframes.map((item) =>
          item.toLowerCase().trim()
        );

      if (
        new Set(normalizedReframes).size !== 3
      ) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["reframes"],
          message:
            "Reframes must be meaningfully distinct.",
        });
      }
    }

    // MARK: - DISTINCT ACTIONS

    if (
      data.inputAssessment === "analyzable" &&
      data.actions.length === 4
    ) {
      const normalizedActions =
        data.actions.map((item) =>
          item.label
            .toLowerCase()
            .trim()
        );

      if (
        new Set(normalizedActions).size !== 4
      ) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["actions"],
          message:
            "Actions must be distinct.",
        });
      }
    }

    // MARK: - SAFETY MESSAGE

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

    // MARK: - ACTION ICON VARIETY

    if (
      data.inputAssessment === "analyzable" &&
      data.actions.length === 4
    ) {
      const actionIcons =
        data.actions.map(
          (item) => item.icon
        );

      if (
        new Set(actionIcons).size < 3
      ) {
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
        data.actions.filter(
          (action) =>
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
    }
  });

export const AnalyzeRequestSchema = z
  .object({
    thought: z.string(),
  })
  .strict();