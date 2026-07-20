//
//  InactivityNotificationMessages.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation

enum InactivityNotificationMessages {

    static let messages: [NotificationMessage] = [

        // Gentle

        NotificationMessage(
            id: "inactivity_001",
            title: "Your reset space is still here",
            body: "Come back whenever your thoughts start feeling heavy."
        ),

        NotificationMessage(
            id: "inactivity_002",
            title: "There's no rush",
            body: "Take care of your mind whenever you're ready."
        ),

        NotificationMessage(
            id: "inactivity_003",
            title: "A calmer moment is waiting",
            body: "Whenever you need a pause, LiveNow is here."
        ),

        NotificationMessage(
            id: "inactivity_004",
            title: "Come back when it feels right",
            body: "One quiet minute can change the rest of your day."
        ),

        NotificationMessage(
            id: "inactivity_005",
            title: "Your mind deserves a check-in",
            body: "Take a gentle moment for yourself today."
        ),

        // Reflective

        NotificationMessage(
            id: "inactivity_006",
            title: "What's been on your mind?",
            body: "Is there one thought you've been carrying for too long?"
        ),

        NotificationMessage(
            id: "inactivity_007",
            title: "How have you been feeling?",
            body: "A short reset might help you understand what's been building up."
        ),

        NotificationMessage(
            id: "inactivity_008",
            title: "Still carrying something?",
            body: "You don't have to hold every thought by yourself."
        ),

        NotificationMessage(
            id: "inactivity_009",
            title: "Take a small pause",
            body: "Sometimes writing one thought down changes everything."
        ),

        NotificationMessage(
            id: "inactivity_010",
            title: "What could you let go of today?",
            body: "One reset may be all your mind needs."
        ),

        // Encouraging

        NotificationMessage(
            id: "inactivity_011",
            title: "Ready for a fresh start?",
            body: "Your next reset is only one minute away."
        ),

        NotificationMessage(
            id: "inactivity_012",
            title: "One reset can change your day",
            body: "A small pause can create a surprising amount of clarity."
        ),

        NotificationMessage(
            id: "inactivity_013",
            title: "Your thoughts don't need to stay tangled",
            body: "Come back for one reset and see what changes."
        ),

        NotificationMessage(
            id: "inactivity_014",
            title: "A better moment could begin now",
            body: "Give yourself one quiet minute before moving on."
        ),

        NotificationMessage(
            id: "inactivity_015",
            title: "Welcome back anytime",
            body: "Whenever life feels overwhelming, we're here for your next reset."
        )
    ]

    static func message(
        inactiveDays: Int,
        seed: Int
    ) -> NotificationMessage {

        let selected = NotificationMessageSelector.select(
            from: messages,
            seed: seed
        )

        let body: String

        switch inactiveDays {

        case 0...3:
            body = selected.body

        case 4...6:
            body = selected.body + " It's only been a few days."

        case 7...13:
            body = selected.body + " It's been a little while."

        case 14...29:
            body = selected.body + " We hope you're doing okay."

        default:
            body = selected.body + " Your reset space will always be here."

        }

        return NotificationMessage(
            id: "\(selected.id)-\(inactiveDays)",
            title: selected.title,
            body: body
        )
    }
}
