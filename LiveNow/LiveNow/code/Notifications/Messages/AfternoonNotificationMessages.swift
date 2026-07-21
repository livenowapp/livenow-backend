//
//  AfternoonNotification.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 18. 7. 2026.
//

import Foundation

enum AfternoonNotificationMessages {

    // MARK: - GENERAL

    static let general: [NotificationMessage] = [
        NotificationMessage(
            id: "afternoon_general_001",
            title: "Pause the mental noise",
            body: "Step out of your thoughts for one quiet minute."
        ),
        NotificationMessage(
            id: "afternoon_general_002",
            title: "A quick reset",
            body: "Loosen your shoulders and take one slower breath."
        ),
        NotificationMessage(
            id: "afternoon_general_003",
            title: "Come back to now",
            body: "What needs your attention in this exact moment?"
        ),
        NotificationMessage(
            id: "afternoon_general_004",
            title: "You can pause here",
            body: "You don’t need to carry every thought forward."
        ),
        NotificationMessage(
            id: "afternoon_general_005",
            title: "Make room in your mind",
            body: "A thought can be present without becoming a problem."
        ),
        NotificationMessage(
            id: "afternoon_general_006",
            title: "Take the pressure off",
            body: "You are allowed to continue without perfect certainty."
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
                    title: "Choose calm first",
                    body: "A calm mind gives you space to see things more clearly."
                ),

                NotificationMessage(
                    id: "morning_need_calm_002",
                    title: "Protect your calm",
                    body: "Not every thought deserves your attention this morning."
                ),

                NotificationMessage(
                    id: "morning_need_calm_003",
                    title: "Start with a calmer mind",
                    body: "You don't have to carry yesterday's worries into today."
                )
            ]

        case .confidence:
            return [

                NotificationMessage(
                    id: "afternoon_need_confidence_001",
                    title: "Trust your next step",
                    body: "You know more than your doubt is allowing you to feel."
                ),

                NotificationMessage(
                    id: "afternoon_need_confidence_002",
                    title: "You are doing better than you think",
                    body: "Keep moving instead of waiting for perfect confidence."
                ),

                NotificationMessage(
                    id: "afternoon_need_confidence_003",
                    title: "Believe your progress",
                    body: "Confidence grows from taking the next step, not predicting every outcome."
                )
            ]

        case .clarity:
            return [

                NotificationMessage(
                    id: "afternoon_need_clarity_001",
                    title: "Clear a little space",
                    body: "A short pause may help you see what matters next."
                ),

                NotificationMessage(
                    id: "afternoon_need_clarity_002",
                    title: "Come back to what matters",
                    body: "Focus on the next decision instead of every possible one."
                ),

                NotificationMessage(
                    id: "afternoon_need_clarity_003",
                    title: "One thing at a time",
                    body: "Clarity often appears when you stop trying to solve everything."
                )
            ]

        case .lessOverthinking:
            return [

                NotificationMessage(
                    id: "afternoon_need_less_overthinking_001",
                    title: "Take a break from your thoughts",
                    body: "You don't have to figure everything out right now."
                ),

                NotificationMessage(
                    id: "afternoon_need_less_overthinking_002",
                    title: "Pause before you overthink",
                    body: "One slow breath can interrupt a spiral of thoughts."
                ),

                NotificationMessage(
                    id: "afternoon_need_less_overthinking_003",
                    title: "Come back to the present",
                    body: "Notice what's happening now instead of what might happen next."
                )
            ]

        case .betterHabits:
            return [

                NotificationMessage(
                    id: "afternoon_need_habits_001",
                    title: "Repeat one helpful choice",
                    body: "Small actions become familiar when you keep returning to them."
                ),

                NotificationMessage(
                    id: "afternoon_need_habits_002",
                    title: "Build today's habit",
                    body: "One mindful pause is another vote for the person you want to become."
                ),

                NotificationMessage(
                    id: "afternoon_need_habits_003",
                    title: "Consistency matters more",
                    body: "Small habits grow stronger every time you practice them."
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
                    id: "afternoon_thinker_past_001",
                    title: "The moment has passed",
                    body: "You don’t need to replay that conversation again."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_past_002",
                    title: "Leave it where it happened",
                    body: "The conversation belongs to the past, not the rest of your day."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_past_003",
                    title: "One replay is enough",
                    body: "You already lived that moment. You don't have to relive it."
                )
            ]

        case .worryAboutFuture:
            return [

                NotificationMessage(
                    id: "afternoon_thinker_future_001",
                    title: "Stay with today",
                    body: "Tomorrow does not need to be solved right now."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_future_002",
                    title: "Come back to today",
                    body: "Your attention is more useful here than in tomorrow's worries."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_future_003",
                    title: "The future can wait",
                    body: "Focus on the next hour instead of the next month."
                )
            ]

        case .overanalyzeDecisions:
            return [

                NotificationMessage(
                    id: "afternoon_thinker_decisions_001",
                    title: "Enough information may be enough",
                    body: "One reasonable step can create more clarity."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_decisions_002",
                    title: "Trust your decision",
                    body: "You don't need to compare every possible outcome again."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_decisions_003",
                    title: "Keep moving forward",
                    body: "Action often brings more clarity than more analysis."
                )
            ]

        case .assumeWorst:
            return [

                NotificationMessage(
                    id: "afternoon_thinker_worst_001",
                    title: "A thought is not evidence",
                    body: "The worst outcome is only one possibility."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_worst_002",
                    title: "Notice the facts",
                    body: "Your mind is predicting, not proving."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_worst_003",
                    title: "Give today a chance",
                    body: "Not every uncertain situation becomes a difficult one."
                )
            ]

        case .mixed:
            return [

                NotificationMessage(
                    id: "afternoon_thinker_everything_001",
                    title: "Let one thought pass",
                    body: "You don’t have to follow everything your mind offers."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_everything_002",
                    title: "Your mind can slow down",
                    body: "Leave a few mental tabs open. They don't all need closing today."
                ),

                NotificationMessage(
                    id: "afternoon_thinker_everything_003",
                    title: "Carry a little less",
                    body: "Choose one thought to release before continuing your day."
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
                    id: "afternoon_reason_overthink_001",
                    title: "Thinking more is not always helping",
                    body: "A pause may give you more than another round of analysis."
                ),

                NotificationMessage(
                    id: "afternoon_reason_overthink_002",
                    title: "Step out of the loop",
                    body: "Repeating the same thought will not always bring a new answer."
                ),

                NotificationMessage(
                    id: "afternoon_reason_overthink_003",
                    title: "Give your mind a break",
                    body: "You can return to the thought later with more space."
                )
            ]

        case .anxietyOften:
            return [

                NotificationMessage(
                    id: "afternoon_reason_anxiety_001",
                    title: "Return to what is here",
                    body: "Notice one thing you can see, hear, or feel right now."
                ),

                NotificationMessage(
                    id: "afternoon_reason_anxiety_002",
                    title: "Slow this moment down",
                    body: "Take one gentle breath and let your body catch up."
                ),

                NotificationMessage(
                    id: "afternoon_reason_anxiety_003",
                    title: "Come back to the present",
                    body: "You do not need to respond to every feeling immediately."
                )
            ]

        case .moreClarity:
            return [

                NotificationMessage(
                    id: "afternoon_reason_clarity_001",
                    title: "Separate facts from fears",
                    body: "What do you know, and what is your mind only predicting?"
                ),

                NotificationMessage(
                    id: "afternoon_reason_clarity_002",
                    title: "Make the thought smaller",
                    body: "Focus on the part you can understand or act on right now."
                ),

                NotificationMessage(
                    id: "afternoon_reason_clarity_003",
                    title: "Clarity needs some space",
                    body: "Step back from the noise and notice what still feels important."
                )
            ]

        case .healthierHabits:
            return [

                NotificationMessage(
                    id: "afternoon_reason_habits_001",
                    title: "Choose the helpful pattern",
                    body: "One mindful pause can interrupt an old habit."
                ),

                NotificationMessage(
                    id: "afternoon_reason_habits_002",
                    title: "Practice a different response",
                    body: "You can notice the thought without following the usual spiral."
                ),

                NotificationMessage(
                    id: "afternoon_reason_habits_003",
                    title: "Repeat what supports you",
                    body: "Each calm choice makes the healthier pattern easier to return to."
                )
            ]

        case .morePeaceOfMind:
            return [

                NotificationMessage(
                    id: "afternoon_reason_peace_001",
                    title: "Choose calm over control",
                    body: "You don't have to solve every thought to feel at peace."
                ),

                NotificationMessage(
                    id: "afternoon_reason_peace_002",
                    title: "Give your mind a moment",
                    body: "A short pause can create more peace than another hour of overthinking."
                ),

                NotificationMessage(
                    id: "afternoon_reason_peace_003",
                    title: "Protect your peace",
                    body: "Not every thought deserves your time or energy."
                )
            ]

        case nil:
            return []
        }
    }
}
