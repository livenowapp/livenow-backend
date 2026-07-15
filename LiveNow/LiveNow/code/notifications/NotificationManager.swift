//
//  NotificationManager.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 13. 7. 2026.
//

import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    private let notificationCenter =
        UNUserNotificationCenter.current()

    private init() {}

    // MARK: - IDENTIFIERS

    private enum Identifier {
        static let morning = "livenow.notification.morning"
        static let afternoon = "livenow.notification.afternoon"
        static let evening = "livenow.notification.evening"

        static let all = [
            morning,
            afternoon,
            evening
        ]
    }

    // MARK: - AUTHORIZATION

    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter
                .requestAuthorization(
                    options: [
                        .alert,
                        .sound,
                        .badge
                    ]
                )
        } catch {
            print(
                "NOTIFICATION AUTHORIZATION ERROR:",
                error.localizedDescription
            )

            return false
        }
    }

    func authorizationStatus() async
        -> UNAuthorizationStatus {

        await withCheckedContinuation { continuation in
            notificationCenter
                .getNotificationSettings { settings in
                    continuation.resume(
                        returning:
                            settings.authorizationStatus
                    )
                }
        }
    }

    // MARK: - MAIN SETUP

    func configureNotifications(
        reason: String?,
        thinkerType: String?,
        need: String?
    ) async {
        let status = await authorizationStatus()

        switch status {
        case .notDetermined:
            let granted = await requestAuthorization()

            guard granted else {
                return
            }

        case .authorized, .provisional, .ephemeral:
            break

        case .denied:
            return

        @unknown default:
            return
        }

        await scheduleDailyNotifications(
            reason: reason,
            thinkerType: thinkerType,
            need: need
        )
    }

    // MARK: - SCHEDULE

    func scheduleDailyNotifications(
        reason: String?,
        thinkerType: String?,
        need: String?
    ) async {
        removeLiveNowNotifications()

        let messages = notificationMessages(
            reason: reason,
            thinkerType: thinkerType,
            need: need
        )

        await scheduleDailyNotification(
            identifier: Identifier.morning,
            hour: 9,
            minute: 30,
            title: "A calmer start",
            body: messages.morning
        )

        await scheduleDailyNotification(
            identifier: Identifier.afternoon,
            hour: 15,
            minute: 0,
            title: "Take a small reset",
            body: messages.afternoon
        )

        await scheduleDailyNotification(
            identifier: Identifier.evening,
            hour: 20,
            minute: 30,
            title: "Leave today a little lighter",
            body: messages.evening
        )
    }

    private func scheduleDailyNotification(
        identifier: String,
        hour: Int,
        minute: Int,
        title: String,
        body: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.threadIdentifier = "livenow.daily"

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)

            print(
                "SCHEDULED NOTIFICATION:",
                identifier,
                "\(hour):\(String(format: "%02d", minute))"
            )
        } catch {
            print(
                "NOTIFICATION SCHEDULING ERROR:",
                identifier,
                error.localizedDescription
            )
        }
    }

    // MARK: - REMOVE

    func removeLiveNowNotifications() {
        notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: Identifier.all
            )

        notificationCenter
            .removeDeliveredNotifications(
                withIdentifiers: Identifier.all
            )
    }

    // MARK: - PERSONALIZED CONTENT

    private func notificationMessages(
        reason: String?,
        thinkerType: String?,
        need: String?
    ) -> (
        morning: String,
        afternoon: String,
        evening: String
    ) {
        let morning = morningMessage(
            reason: reason,
            need: need
        )

        let afternoon = afternoonMessage(
            thinkerType: thinkerType,
            need: need
        )

        let evening = eveningMessage(
            thinkerType: thinkerType,
            need: need
        )

        return (
            morning,
            afternoon,
            evening
        )
    }

    private func morningMessage(
        reason: String?,
        need: String?
    ) -> String {
        switch need {
        case "Peace of mind":
            return "You don’t need to solve everything before the day begins."

        case "Confidence":
            return "Start the day by trusting yourself a little more."

        case "Clarity":
            return "You only need to see the next step, not the whole path."

        case "Motivation":
            return "One small action can change the direction of your day."

        case "Better habits":
            return "A calm minute now can become a habit that lasts."

        default:
            break
        }

        switch reason {
        case "I feel anxious often":
            return "Take one slow breath before the day gets busy."

        case "I overthink a lot":
            return "Not every thought deserves your attention today."

        default:
            return "Take one quiet moment before the day begins."
        }
    }

    private func afternoonMessage(
        thinkerType: String?,
        need: String?
    ) -> String {
        switch thinkerType {
        case "I replay past conversations":
            return "You don’t have to replay that conversation again."

        case "I worry about the future":
            return "You don’t need to solve tomorrow right now."

        case "I overanalyze decisions":
            return "Clarity often comes after one small action."

        case "I assume the worst":
            return "A difficult thought is not proof that something is wrong."

        case "A bit of everything":
            return "Pause for a moment. You don’t need to follow every thought."

        default:
            break
        }

        switch need {
        case "Motivation":
            return "Feeling stuck? Choose one small step and begin there."

        case "Clarity":
            return "A quick reset can help you see what matters next."

        default:
            return "Take one minute to step out of your thoughts."
        }
    }

    private func eveningMessage(
        thinkerType: String?,
        need: String?
    ) -> String {
        switch thinkerType {
        case "I replay past conversations":
            return "The conversation is over. You’re allowed to leave it there."

        case "I worry about the future":
            return "Tomorrow doesn’t need to be solved tonight."

        case "I overanalyze decisions":
            return "You’ve thought enough for today. Let your mind rest."

        case "I assume the worst":
            return "Your worst-case thought is only one possibility."

        case "A bit of everything":
            return "You don’t have to carry every thought into tomorrow."

        default:
            break
        }

        switch need {
        case "Peace of mind":
            return "Let today end without solving everything."

        case "Better habits":
            return "End the day with one small moment of calm."

        default:
            return "Leave today a little lighter than you found it."
        }
    }
}
