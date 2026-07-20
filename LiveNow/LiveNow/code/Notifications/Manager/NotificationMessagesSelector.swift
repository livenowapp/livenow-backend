//
//  NotificationSelector.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 18. 7. 2026.
//

import Foundation

enum NotificationMessageSelector {

    // MARK: - BASIC SELECTION

    static func select(
        from messages: [NotificationMessage],
        seed: Int
    ) -> NotificationMessage {

        guard !messages.isEmpty else {
            return fallbackMessage
        }

        let index = positiveModulo(
            seed,
            messages.count
        )

        return messages[index]
    }

    // MARK: - PERSONALIZED SELECTION

    static func selectPersonalized(
        general: [NotificationMessage],
        need: [NotificationMessage],
        thinkerType: [NotificationMessage],
        reason: [NotificationMessage],
        seed: Int
    ) -> NotificationMessage {

        let categoryValue = positiveModulo(
            mixedSeed(seed),
            100
        )

        let preferredMessages: [NotificationMessage]

        switch categoryValue {

        // 50 %
        case 0..<50:
            preferredMessages = general

        // 25 %
        case 50..<75:
            preferredMessages = need

        // 15 %
        case 75..<90:
            preferredMessages = thinkerType

        // 10 %
        default:
            preferredMessages = reason
        }

        if !preferredMessages.isEmpty {
            return select(
                from: preferredMessages,
                seed: seed + 101
            )
        }

        let fallbackPool =
            general +
            need +
            thinkerType +
            reason

        return select(
            from: fallbackPool,
            seed: seed + 211
        )
    }

    // MARK: - HELPERS

    static func positiveModulo(
        _ value: Int,
        _ divisor: Int
    ) -> Int {

        guard divisor > 0 else {
            return 0
        }

        let result = value % divisor

        return result >= 0
            ? result
            : result + divisor
    }

    private static func mixedSeed(
        _ seed: Int
    ) -> Int {

        seed &* 1_103_515_245 &+ 12_345
    }

    private static let fallbackMessage =
        NotificationMessage(
            id: "notification_fallback",
            title: "Take a small pause",
            body: "You don’t need to follow every thought."
        )
}
