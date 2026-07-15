//
//  NotificationManager.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 13. 7. 2026.
//

/*import Foundation
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
}*/

import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    private let notificationCenter =
        UNUserNotificationCenter.current()

    private let notificationPrefix =
        "livenow.notification."

    private let daysToSchedule = 20

    private init() {}

    // MARK: - MODELS

    private struct NotificationMessage {
        let title: String
        let body: String
    }

    private enum ReminderPeriod: String {
        case morning
        case afternoon
        case evening
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

        await scheduleUpcomingNotifications(
            reason: reason,
            thinkerType: thinkerType,
            need: need
        )
    }

    /// Pokliči ob zagonu aplikacije za uporabnika,
    /// ki je dovoljenje že odobril.
    func refreshNotificationsIfAuthorized(
        reason: String?,
        thinkerType: String?,
        need: String?
    ) async {
        let status = await authorizationStatus()

        guard status == .authorized ||
              status == .provisional ||
              status == .ephemeral
        else {
            return
        }

        await scheduleUpcomingNotifications(
            reason: reason,
            thinkerType: thinkerType,
            need: need
        )
    }

    // MARK: - SCHEDULE

    private func scheduleUpcomingNotifications(
        reason: String?,
        thinkerType: String?,
        need: String?
    ) async {
        await removeLiveNowNotifications()

        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 0..<daysToSchedule {
            guard let day = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: now
            ) else {
                continue
            }

            let schedule = dailySchedule(
                for: day,
                reason: reason,
                thinkerType: thinkerType,
                need: need
            )

            for item in schedule {
                guard item.date > now else {
                    continue
                }

                let identifier = notificationIdentifier(
                    period: item.period,
                    date: item.date
                )

                await scheduleNotification(
                    identifier: identifier,
                    date: item.date,
                    message: item.message
                )
            }
        }
    }

    private func dailySchedule(
        for day: Date,
        reason: String?,
        thinkerType: String?,
        need: String?
    ) -> [
        (
            period: ReminderPeriod,
            date: Date,
            message: NotificationMessage
        )
    ] {
        let seed = stableDaySeed(for: day)

        let morningDate = notificationDate(
            on: day,
            startHour: 8,
            startMinute: 45,
            availableMinutes: 90,
            seed: seed + 11
        )

        let afternoonDate = notificationDate(
            on: day,
            startHour: 13,
            startMinute: 30,
            availableMinutes: 180,
            seed: seed + 29
        )

        let eveningDate = notificationDate(
            on: day,
            startHour: 19,
            startMinute: 30,
            availableMinutes: 120,
            seed: seed + 47
        )

        return [
            (
                period: .morning,
                date: morningDate,
                message: selectedMessage(
                    from: morningMessages(
                        reason: reason,
                        need: need
                    ),
                    seed: seed + 3
                )
            ),
            (
                period: .afternoon,
                date: afternoonDate,
                message: selectedMessage(
                    from: afternoonMessages(
                        thinkerType: thinkerType,
                        need: need
                    ),
                    seed: seed + 7
                )
            ),
            (
                period: .evening,
                date: eveningDate,
                message: selectedMessage(
                    from: eveningMessages(
                        thinkerType: thinkerType,
                        need: need
                    ),
                    seed: seed + 13
                )
            )
        ]
    }

    private func notificationDate(
        on day: Date,
        startHour: Int,
        startMinute: Int,
        availableMinutes: Int,
        seed: Int
    ) -> Date {
        let calendar = Calendar.current

        var components = calendar.dateComponents(
            [.year, .month, .day],
            from: day
        )

        let variation = positiveModulo(
            seed,
            availableMinutes + 1
        )

        let totalMinutes =
            (startHour * 60) +
            startMinute +
            variation

        components.hour = totalMinutes / 60
        components.minute = totalMinutes % 60
        components.second = 0

        return calendar.date(from: components) ?? day
    }

    private func scheduleNotification(
        identifier: String,
        date: Date,
        message: NotificationMessage
    ) async {
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default
        content.threadIdentifier = "livenow.daily"

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
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
                date.formatted(
                    date: .abbreviated,
                    time: .shortened
                )
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

    func removeLiveNowNotifications() async {
        let identifiers = await pendingLiveNowIdentifiers()

        guard !identifiers.isEmpty else {
            return
        }

        notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: identifiers
            )

        notificationCenter
            .removeDeliveredNotifications(
                withIdentifiers: identifiers
            )
    }

    private func pendingLiveNowIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            notificationCenter
                .getPendingNotificationRequests { requests in
                    let identifiers = requests
                        .map(\.identifier)
                        .filter {
                            $0.hasPrefix(
                                self.notificationPrefix
                            )
                        }

                    continuation.resume(
                        returning: identifiers
                    )
                }
        }
    }

    // MARK: - MESSAGE SELECTION

    private func selectedMessage(
        from messages: [NotificationMessage],
        seed: Int
    ) -> NotificationMessage {
        guard !messages.isEmpty else {
            return NotificationMessage(
                title: "Take a small pause",
                body: "You don’t need to follow every thought."
            )
        }

        let index = positiveModulo(
            seed,
            messages.count
        )

        return messages[index]
    }

    private func stableDaySeed(for date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let referenceDate = calendar.startOfDay(
            for: Date(timeIntervalSinceReferenceDate: 0)
        )

        return calendar.dateComponents(
            [.day],
            from: referenceDate,
            to: startOfDay
        ).day ?? 0
    }

    private func positiveModulo(
        _ value: Int,
        _ divisor: Int
    ) -> Int {
        guard divisor > 0 else {
            return 0
        }

        let result = value % divisor
        return result >= 0 ? result : result + divisor
    }

    private func notificationIdentifier(
        period: ReminderPeriod,
        date: Date
    ) -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        return [
            notificationPrefix,
            period.rawValue,
            String(components.year ?? 0),
            String(components.month ?? 0),
            String(components.day ?? 0),
            String(components.hour ?? 0),
            String(components.minute ?? 0)
        ]
        .joined(separator: ".")
    }

    // MARK: - MORNING MESSAGES

    private func morningMessages(
        reason: String?,
        need: String?
    ) -> [NotificationMessage] {
        var messages = [
            NotificationMessage(
                title: "Start a little lighter",
                body: "You don’t need to solve the whole day at once."
            ),
            NotificationMessage(
                title: "One calm moment",
                body: "Take one slow breath before the day gets busy."
            ),
            NotificationMessage(
                title: "Begin where you are",
                body: "The next small step is enough for now."
            ),
            NotificationMessage(
                title: "A softer start",
                body: "Not every thought needs your attention today."
            ),
            NotificationMessage(
                title: "Before the noise begins",
                body: "Give yourself a moment without fixing anything."
            ),
            NotificationMessage(
                title: "Today can unfold slowly",
                body: "You only need to handle what is in front of you."
            )
        ]

        switch need {
        case "Peace of mind":
            messages.append(
                NotificationMessage(
                    title: "Protect your peace",
                    body: "You don’t need every answer before the day begins."
                )
            )

        case "Confidence":
            messages.append(
                NotificationMessage(
                    title: "Trust yourself today",
                    body: "You have handled uncertain moments before."
                )
            )

        case "Clarity":
            messages.append(
                NotificationMessage(
                    title: "Look for the next step",
                    body: "Clarity doesn’t require seeing the entire path."
                )
            )

        case "Motivation":
            messages.append(
                NotificationMessage(
                    title: "Begin with something small",
                    body: "A little movement is still progress."
                )
            )

        case "Better habits":
            messages.append(
                NotificationMessage(
                    title: "A small habit starts here",
                    body: "One calm minute still counts."
                )
            )

        default:
            break
        }

        switch reason {
        case "I feel anxious often":
            messages.append(
                NotificationMessage(
                    title: "You are here, right now",
                    body: "Let your breath bring you back to this moment."
                )
            )

        case "I overthink a lot":
            messages.append(
                NotificationMessage(
                    title: "Choose what deserves you",
                    body: "Not every thought needs more thinking."
                )
            )

        default:
            break
        }

        return messages
    }

    // MARK: - AFTERNOON MESSAGES

    private func afternoonMessages(
        thinkerType: String?,
        need: String?
    ) -> [NotificationMessage] {
        var messages = [
            NotificationMessage(
                title: "Pause the mental noise",
                body: "Step out of your thoughts for one quiet minute."
            ),
            NotificationMessage(
                title: "A quick reset",
                body: "Loosen your shoulders and take one slower breath."
            ),
            NotificationMessage(
                title: "Come back to now",
                body: "What needs your attention in this exact moment?"
            ),
            NotificationMessage(
                title: "You can pause here",
                body: "You don’t need to carry every thought forward."
            ),
            NotificationMessage(
                title: "Make room in your mind",
                body: "A thought can be present without becoming a problem."
            ),
            NotificationMessage(
                title: "Take the pressure off",
                body: "You are allowed to continue without perfect certainty."
            )
        ]

        switch thinkerType {
        case "I replay past conversations":
            messages.append(
                NotificationMessage(
                    title: "The moment has passed",
                    body: "You don’t need to replay that conversation again."
                )
            )

        case "I worry about the future":
            messages.append(
                NotificationMessage(
                    title: "Stay with today",
                    body: "Tomorrow does not need to be solved right now."
                )
            )

        case "I overanalyze decisions":
            messages.append(
                NotificationMessage(
                    title: "Enough information may be enough",
                    body: "One reasonable step can create more clarity."
                )
            )

        case "I assume the worst":
            messages.append(
                NotificationMessage(
                    title: "A thought is not evidence",
                    body: "The worst outcome is only one possibility."
                )
            )

        case "A bit of everything":
            messages.append(
                NotificationMessage(
                    title: "Let one thought pass",
                    body: "You don’t have to follow everything your mind offers."
                )
            )

        default:
            break
        }

        switch need {
        case "Motivation":
            messages.append(
                NotificationMessage(
                    title: "Choose one doable thing",
                    body: "Progress can begin with a very small action."
                )
            )

        case "Clarity":
            messages.append(
                NotificationMessage(
                    title: "Clear a little space",
                    body: "A short pause may help you see what matters next."
                )
            )

        default:
            break
        }

        return messages
    }

    // MARK: - EVENING MESSAGES

    private func eveningMessages(
        thinkerType: String?,
        need: String?
    ) -> [NotificationMessage] {
        var messages = [
            NotificationMessage(
                title: "Let the day become quieter",
                body: "You don’t need to solve anything else tonight."
            ),
            NotificationMessage(
                title: "Leave some thoughts here",
                body: "Not everything needs to follow you into tomorrow."
            ),
            NotificationMessage(
                title: "Your mind can rest",
                body: "You have done enough thinking for today."
            ),
            NotificationMessage(
                title: "Close the day gently",
                body: "Unfinished does not mean unsafe."
            ),
            NotificationMessage(
                title: "Release the need to know",
                body: "Tonight can be for resting, not predicting."
            ),
            NotificationMessage(
                title: "Make tonight lighter",
                body: "Let one unresolved thought wait until tomorrow."
            )
        ]

        switch thinkerType {
        case "I replay past conversations":
            messages.append(
                NotificationMessage(
                    title: "The conversation can stay in the past",
                    body: "You are allowed to stop reviewing it."
                )
            )

        case "I worry about the future":
            messages.append(
                NotificationMessage(
                    title: "Tomorrow can wait",
                    body: "The future does not need your attention tonight."
                )
            )

        case "I overanalyze decisions":
            messages.append(
                NotificationMessage(
                    title: "Thinking time is over",
                    body: "Rest may bring more clarity than another analysis."
                )
            )

        case "I assume the worst":
            messages.append(
                NotificationMessage(
                    title: "Fear is not a forecast",
                    body: "A difficult possibility is not a certain outcome."
                )
            )

        case "A bit of everything":
            messages.append(
                NotificationMessage(
                    title: "Set the thoughts down",
                    body: "You don’t need to carry all of them through the night."
                )
            )

        default:
            break
        }

        switch need {
        case "Peace of mind":
            messages.append(
                NotificationMessage(
                    title: "Peace does not require every answer",
                    body: "Let today end without resolving everything."
                )
            )

        case "Better habits":
            messages.append(
                NotificationMessage(
                    title: "End with one calm minute",
                    body: "Small peaceful moments can become familiar."
                )
            )

        default:
            break
        }

        return messages
    }
}
