//
//  ResetReminderMessages.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation

enum ResetReminderMessages {

    static let messages: [NotificationMessage] = [

        // Gentle

        NotificationMessage(
            id: "reset-reminder-001",
            title: "Still carrying something?",
            body: "Take a moment to clear your mind with a reset."
        ),

        NotificationMessage(
            id: "reset-reminder-002",
            title: "Your mind deserves a pause",
            body: "A quick reset can help you leave today's thoughts behind."
        ),

        NotificationMessage(
            id: "reset-reminder-003",
            title: "Before the day ends",
            body: "Is there a thought you would feel better letting go of?"
        ),

        NotificationMessage(
            id: "reset-reminder-004",
            title: "Make space in your mind",
            body: "You still have time for one small reset today."
        ),

        NotificationMessage(
            id: "reset-reminder-005",
            title: "Anything on your mind?",
            body: "Put it into words and see it more clearly."
        ),

        // Reflective

        NotificationMessage(
            id: "reset-reminder-006",
            title: "What stayed with you today?",
            body: "One honest reset may help you leave it behind."
        ),

        NotificationMessage(
            id: "reset-reminder-007",
            title: "Take one quiet minute",
            body: "Sometimes understanding a thought starts by writing it down."
        ),

        NotificationMessage(
            id: "reset-reminder-008",
            title: "Is your mind still busy?",
            body: "You don't have to carry every thought into tomorrow."
        ),

        NotificationMessage(
            id: "reset-reminder-009",
            title: "What's asking for your attention?",
            body: "A reset can help you separate the important from the unnecessary."
        ),

        NotificationMessage(
            id: "reset-reminder-010",
            title: "Leave one thought behind",
            body: "Your evening doesn't need to be filled with unfinished worries."
        ),

        // Encouraging

        NotificationMessage(
            id: "reset-reminder-011",
            title: "One reset is enough",
            body: "A single minute can completely change how the day feels."
        ),

        NotificationMessage(
            id: "reset-reminder-012",
            title: "Give yourself that minute",
            body: "A small pause now can make tonight feel much lighter."
        ),

        NotificationMessage(
            id: "reset-reminder-013",
            title: "Choose clarity tonight",
            body: "You don't have to solve everything before you rest."
        ),

        NotificationMessage(
            id: "reset-reminder-014",
            title: "Take care of your mind",
            body: "One thoughtful reset is a small act of kindness toward yourself."
        ),

        NotificationMessage(
            id: "reset-reminder-015",
            title: "End today a little lighter",
            body: "Your thoughts don't have to come to bed with you."
        )
    ]

    static func message(
        seed: Int
    ) -> NotificationMessage {
        NotificationMessageSelector.select(
            from: messages,
            seed: seed
        )
    }
}
