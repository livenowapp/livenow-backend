export const ACTION_ICONS = [
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
];

export const reflectionJsonSchema = {
  type: "object",
  additionalProperties: false,

  required: [
    "safety",
    "shortTitle",
    "analysis",
    "evidence",
    "reframes",
    "actions",
    "insight",
  ],

  properties: {
    safety: {
      type: "object",
      additionalProperties: false,
      required: ["level", "message"],

      properties: {
        level: {
          type: "string",
          enum: ["normal", "elevated", "urgent"],
        },

        message: {
          type: ["string", "null"],
          maxLength: 500,
        },
      },
    },

    shortTitle: {
      type: "string",
      minLength: 2,
      maxLength: 30,
    },

    analysis: {
      type: "array",

      items: {
        type: "object",
        additionalProperties: false,
        required: ["type", "label", "sub"],

        properties: {
          type: {
            type: "string",
            enum: [
              "assumption",
              "brain_response",
              "balanced_context",
            ],
          },

          label: {
            type: "string",
            minLength: 1,
            maxLength: 38,
          },

          sub: {
            type: "string",
            minLength: 1,
            maxLength: 110,
          },
        },
      },
    },

    evidence: {
      type: "array",

      items: {
        type: "object",
        additionalProperties: false,
        required: ["q", "a"],

        properties: {
          q: {
            type: "string",
            minLength: 1,
            maxLength: 85,
          },

          a: {
            type: "string",
            minLength: 1,
            maxLength: 75,
          },
        },
      },
    },

    reframes: {
      type: "array",

      items: {
        type: "string",
        minLength: 1,
        maxLength: 90,
      },
    },

    actions: {
      type: "array",

      items: {
        type: "object",
        additionalProperties: false,
        required: ["icon", "label"],

        properties: {
          icon: {
            type: "string",
            enum: ACTION_ICONS,
          },

          label: {
            type: "string",
            minLength: 1,
            maxLength: 90,
          },
        },
      },
    },

    insight: {
      type: "string",
      minLength: 1,
      maxLength: 140,
    },
  },
};