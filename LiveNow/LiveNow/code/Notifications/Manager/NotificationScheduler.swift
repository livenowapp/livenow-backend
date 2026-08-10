//
//  NotificationScheduler.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation
import UserNotifications

final class NotificationScheduler {

    private let notificationCenter: UNUserNotificationCenter
    private let notificationPrefix = "livenow.notification."

    init(
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.notificationCenter = notificationCenter
    }

    // MARK: - SCHEDULE MULTIPLE

    func schedule(
        _ notifications: [ScheduledNotification]
    ) async {
        let now = Date()

        for notification in notifications {
            guard notification.date > now else {
                continue
            }

            await schedule(notification)
        }
    }

    // MARK: - SCHEDULE SINGLE

    func schedule(
        _ notification: ScheduledNotification
    ) async {
        guard notification.date > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = notification.message.title
        content.body = notification.message.body
        content.sound = .default

        content.threadIdentifier = threadIdentifier(
            for: notification.type
        )

        content.userInfo = [
            "notificationType": notification.type.rawValue,
            "messageID": notification.message.id
        ]

        let dateComponents = Calendar.current.dateComponents(
            [
                .year,
                .month,
                .day,
                .hour,
                .minute
            ],
            from: notification.date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let identifier = notificationIdentifier(
            period: notification.period,
            date: notification.date
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    // MARK: - REMOVE ALL LIVENOW

    func removeAllLiveNowNotifications() async {
        let pendingIdentifiers =
            await pendingLiveNowIdentifiers()

        let deliveredIdentifiers =
            await deliveredLiveNowIdentifiers()

        if !pendingIdentifiers.isEmpty {
            notificationCenter
                .removePendingNotificationRequests(
                    withIdentifiers: pendingIdentifiers
                )
        }

        if !deliveredIdentifiers.isEmpty {
            notificationCenter
                .removeDeliveredNotifications(
                    withIdentifiers: deliveredIdentifiers
                )
        }
    }

    // MARK: - REMOVE PERIOD FOR DATE

    func removeNotification(
        period: ReminderPeriod,
        date: Date
    ) {
        let identifier = notificationIdentifier(
            period: period,
            date: date
        )

        notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )

        notificationCenter
            .removeDeliveredNotifications(
                withIdentifiers: [identifier]
            )
    }

    // MARK: - IDENTIFIERS

    private func notificationIdentifier(
        period: ReminderPeriod,
        date: Date
    ) -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )

        return [
            notificationPrefix,
            period.rawValue,
            String(components.year ?? 0),
            String(components.month ?? 0),
            String(components.day ?? 0)
        ]
        .joined(separator: ".")
    }

    private func threadIdentifier(
        for type: NotificationType
    ) -> String {
        switch type {
        case .morningPersonalized:
            return "livenow.personalized"

        case .afternoonPersonalized:
            return "livenow.personalized"

        case .eveningPersonalized:
            return "livenow.personalized"

        case .dailyResetReminder:
            return "livenow.reset"

        case .inactivityReminder:
            return "livenow.inactivity"

        case .weeklyAchievement:
            return "livenow.achievement"
        }
    }

    // MARK: - PENDING

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

    // MARK: - DELIVERED

    private func deliveredLiveNowIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            notificationCenter
                .getDeliveredNotifications { notifications in
                    let identifiers = notifications
                        .map {
                            $0.request.identifier
                        }
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
}
