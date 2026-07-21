//
//  MorningNotificationMessages.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 18. 7. 2026.
//

import Foundation

enum MorningNotificationMessages {

    // MARK: - GENERAL

    static let general: [NotificationMessage] = [

        NotificationMessage(
            id: "morning_general_001",
            title: "Start a little lighter",
            body: "You don’t need to solve the whole day at once."
        ),

        NotificationMessage(
            id: "morning_general_002",
            title: "One calm moment",
            body: "Take one slow breath before the day gets busy."
        ),

        NotificationMessage(
            id: "morning_general_003",
            title: "Begin where you are",
            body: "The next small step is enough for now."
        ),

        NotificationMessage(
            id: "morning_general_004",
            title: "A softer start",
            body: "Not every thought needs your attention today."
        ),

        NotificationMessage(
            id: "morning_general_005",
            title: "Before the noise begins",
            body: "Give yourself a moment without fixing anything."
        ),

        NotificationMessage(
            id: "morning_general_006",
            title: "Today can unfold slowly",
            body: "You only need to handle what is in front of you."
        )
    ]

    // MARK: - NEED

    static func forNeed(
        _ need: String?
    ) -> [NotificationMessage] {

        switch OnboardingNeed(
            storedValue: need
        ) {

        case .calm:
            return [

                NotificationMessage(
                    id: "morning_need_calm_001",
                    title: "Protect your calm",
                    body: "You don't need every answer before the day begins."
                ),

                NotificationMessage(
                    id: "morning_need_calm_002",
                    title: "Let this morning stay gentle",
                    body: "Choose calm before your thoughts begin asking for more."
                ),

                NotificationMessage(
                    id: "morning_need_calm_003",
                    title: "Start with a quieter mind",
                    body: "Calm often begins by letting one thought go."
                )
            ]

        case .confidence:
            return [

                NotificationMessage(
                    id: "morning_need_confidence_001",
                    title: "Trust yourself today",
                    body: "You have handled uncertain moments before."
                ),

                NotificationMessage(
                    id: "morning_need_confidence_002",
                    title: "You know more than you think",
                    body: "Let confidence grow from action instead of certainty."
                ),

                NotificationMessage(
                    id: "morning_need_confidence_003",
                    title: "Believe in your next step",
                    body: "You do not need perfect certainty to move forward."
                )
            ]

        case .clarity:
            return [

                NotificationMessage(
                    id: "morning_need_clarity_001",
                    title: "Look for the next step",
                    body: "Clarity doesn’t require seeing the entire path."
                ),

                NotificationMessage(
                    id: "morning_need_clarity_002",
                    title: "Keep it simple",
                    body: "Focus on what is clear instead of everything that isn't."
                ),

                NotificationMessage(
                    id: "morning_need_clarity_003",
                    title: "One clear step is enough",
                    body: "You do not need the whole plan before you begin."
                )
            ]

        case .lessOverthinking:
            return [

                NotificationMessage(
                    id: "morning_need_less_overthinking_001",
                    title: "You don't have to solve everything",
                    body: "Focus on today. The rest can wait."
                ),

                NotificationMessage(
                    id: "morning_need_less_overthinking_002",
                    title: "Let your mind slow down",
                    body: "Not every thought deserves your attention."
                ),

                NotificationMessage(
                    id: "morning_need_less_overthinking_003",
                    title: "Start with a calmer mind",
                    body: "The quieter your mind, the clearer your day becomes."
                )
            ]

        case .betterHabits:
            return [

                NotificationMessage(
                    id: "morning_need_habits_001",
                    title: "A small habit starts here",
                    body: "One calm minute still counts."
                ),

                NotificationMessage(
                    id: "morning_need_habits_002",
                    title: "Choose consistency",
                    body: "Small actions repeated gently become lasting habits."
                ),

                NotificationMessage(
                    id: "morning_need_habits_003",
                    title: "Build today quietly",
                    body: "The habits that change us often begin with tiny moments."
                )
            ]

        case nil:
            return []
        }
    }

    // MARK: - THINKER TYPE

    static func forThinkerType(
        _ thinkerType: String?
    ) -> [NotificationMessage] {

        switch OnboardingThinkerType(
            storedValue: thinkerType
        ) {

        case .replayPastConversations:
            return [

                NotificationMessage(
                    id: "morning_thinker_past_001",
                    title: "Today is a new moment",
                    body: "Yesterday’s conversations do not need to shape this morning."
                ),

                NotificationMessage(
                    id: "morning_thinker_past_002",
                    title: "Leave yesterday where it belongs",
                    body: "The conversation is over. You don't need to keep rewriting it."
                ),

                NotificationMessage(
                    id: "morning_thinker_past_003",
                    title: "A fresh start",
                    body: "Give today a chance before looking back at yesterday."
                )
            ]

        case .worryAboutFuture:
            return [

                NotificationMessage(
                    id: "morning_thinker_future_001",
                    title: "Stay with this morning",
                    body: "The future does not need to be solved before today begins."
                ),

                NotificationMessage(
                    id: "morning_thinker_future_002",
                    title: "Tomorrow can wait",
                    body: "You only need to take care of this moment right now."
                ),

                NotificationMessage(
                    id: "morning_thinker_future_003",
                    title: "Begin where your feet are",
                    body: "The future becomes easier one present moment at a time."
                )
            ]

        case .overanalyzeDecisions:
            return [

                NotificationMessage(
                    id: "morning_thinker_decisions_001",
                    title: "Leave room for movement",
                    body: "You can take the next step without perfect certainty."
                ),

                NotificationMessage(
                    id: "morning_thinker_decisions_002",
                    title: "Enough is enough",
                    body: "A good decision rarely needs endless thinking."
                ),

                NotificationMessage(
                    id: "morning_thinker_decisions_003",
                    title: "Trust your direction",
                    body: "You can always adjust later if you need to."
                )
            ]

        case .assumeWorst:
            return [

                NotificationMessage(
                    id: "morning_thinker_worst_001",
                    title: "Begin with what is real",
                    body: "A difficult possibility is not a certain outcome."
                ),

                NotificationMessage(
                    id: "morning_thinker_worst_002",
                    title: "Not every fear comes true",
                    body: "Give today a chance before expecting the worst."
                ),

                NotificationMessage(
                    id: "morning_thinker_worst_003",
                    title: "Stay with the facts",
                    body: "Your mind is imagining possibilities, not predicting the future."
                )
            ]

        case .mixed:
            return [

                NotificationMessage(
                    id: "morning_thinker_everything_001",
                    title: "Choose one thought less",
                    body: "You do not need to follow everything your mind offers."
                ),

                NotificationMessage(
                    id: "morning_thinker_everything_002",
                    title: "Your mind doesn't need to solve everything",
                    body: "Some questions become clearer when you stop chasing them."
                ),

                NotificationMessage(
                    id: "morning_thinker_everything_003",
                    title: "Start with a little more space",
                    body: "Leave a few thoughts behind and carry only what matters today."
                )
            ]

        case nil:
            return []
        }
    }

    // MARK: - REASON

    static func forReason(
        _ reason: String?
    ) -> [NotificationMessage] {

        switch OnboardingReason(
            storedValue: reason
        ) {

        case .overthinkOften:
            return [

                NotificationMessage(
                    id: "morning_reason_overthink_001",
                    title: "Choose what deserves you",
                    body: "Not every thought needs more thinking."
                ),

                NotificationMessage(
                    id: "morning_reason_overthink_002",
                    title: "You can stop the loop",
                    body: "A thought does not become more useful just because you repeat it."
                ),

                NotificationMessage(
                    id: "morning_reason_overthink_003",
                    title: "Let one thought pass",
                    body: "You do not need to follow every question your mind creates."
                )
            ]

        case .anxietyOften:
            return [

                NotificationMessage(
                    id: "morning_reason_anxiety_001",
                    title: "You are here, right now",
                    body: "Let your breath bring you back to this moment."
                ),

                NotificationMessage(
                    id: "morning_reason_anxiety_002",
                    title: "Start with what feels steady",
                    body: "Notice one thing around you that feels calm and real."
                ),

                NotificationMessage(
                    id: "morning_reason_anxiety_003",
                    title: "This moment is enough",
                    body: "You do not need to prepare for every possibility this morning."
                )
            ]

        case .moreClarity:
            return [

                NotificationMessage(
                    id: "morning_reason_clarity_001",
                    title: "Clear the first step",
                    body: "You only need to understand what comes next."
                ),

                NotificationMessage(
                    id: "morning_reason_clarity_002",
                    title: "Separate what you know",
                    body: "Start with the facts and leave the predictions for later."
                ),

                NotificationMessage(
                    id: "morning_reason_clarity_003",
                    title: "Clarity can be simple",
                    body: "One honest next step is enough to begin."
                )
            ]

        case .healthierHabits:
            return [

                NotificationMessage(
                    id: "morning_reason_habits_001",
                    title: "Start with one small choice",
                    body: "A healthier pattern can begin with one calm moment."
                ),

                NotificationMessage(
                    id: "morning_reason_habits_002",
                    title: "Practice the pause",
                    body: "Each time you stop before spiraling, the habit becomes stronger."
                ),

                NotificationMessage(
                    id: "morning_reason_habits_003",
                    title: "Repeat what helps",
                    body: "Small helpful choices become easier when you return to them."
                )
            ]

        case .morePeaceOfMind:
            return [

                NotificationMessage(
                    id: "morning_reason_peace_001",
                    title: "Start with a calmer mind",
                    body: "You don't have to carry yesterday's worries into today."
                ),

                NotificationMessage(
                    id: "morning_reason_peace_002",
                    title: "Protect your peace today",
                    body: "Not every thought needs your attention this morning."
                ),

                NotificationMessage(
                    id: "morning_reason_peace_003",
                    title: "Choose calm first",
                    body: "A peaceful mind makes room for a better day."
                )
            ]

        case nil:
            return []
        }
    }
}
