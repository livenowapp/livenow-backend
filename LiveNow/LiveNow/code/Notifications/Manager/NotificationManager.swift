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

    private let scheduler =
        NotificationScheduler()

    private let conditionChecker =
        NotificationConditionChecker()

    private let daysToSchedule = 20

    private init() {}

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

    // MARK: - INITIAL CONFIGURATION

    func configureNotifications(
        reason: String?,
        thinkerType: String?,
        need: String?,
        entries: [ThoughtEntry]
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

        await rebuildNotificationSchedule(
            reason: reason,
            thinkerType: thinkerType,
            need: need,
            entries: entries
        )
    }

    // MARK: - APP REFRESH

    func refreshNotificationsIfAuthorized(
        reason: String?,
        thinkerType: String?,
        need: String?,
        entries: [ThoughtEntry]
    ) async {
        let status = await authorizationStatus()

        guard status == .authorized ||
              status == .provisional ||
              status == .ephemeral
        else {
            return
        }

        await rebuildNotificationSchedule(
            reason: reason,
            thinkerType: thinkerType,
            need: need,
            entries: entries
        )
    }

    // MARK: - FULL SCHEDULE

    private func rebuildNotificationSchedule(
        reason: String?,
        thinkerType: String?,
        need: String?,
        entries: [ThoughtEntry]
    ) async {
        print("REBUILDING NOTIFICATION SCHEDULE")

        await scheduler.removeAllLiveNowNotifications()

        var notifications: [ScheduledNotification] = []

        notifications.append(
            contentsOf: upcomingMorningNotifications(
                reason: reason,
                thinkerType: thinkerType,
                need: need
            )
        )

        notifications.append(
            contentsOf: upcomingAfternoonNotifications(
                reason: reason,
                thinkerType: thinkerType,
                need: need
            )
        )

        notifications.append(
            contentsOf: upcomingEveningNotifications(
                reason: reason,
                thinkerType: thinkerType,
                need: need,
                entries: entries
            )
        )

        await scheduler.schedule(notifications)
    }

    // MARK: - MORNING NOTIFICATIONS

    private func upcomingMorningNotifications(
        reason: String?,
        thinkerType: String?,
        need: String?
    ) -> [ScheduledNotification] {
        let calendar = Calendar.current
        let now = Date()

        var notifications: [ScheduledNotification] = []

        for dayOffset in 0..<daysToSchedule {
            guard let day = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: now
            ) else {
                continue
            }

            let seed = stableDaySeed(for: day)

            let date = notificationDate(
                on: day,
                startHour: 8,
                startMinute: 45,
                availableMinutes: 90,
                seed: seed + 11
            )

            guard date > now else {
                continue
            }

            let message =
                NotificationMessageSelector.selectPersonalized(
                    general:
                        MorningNotificationMessages.general,
                    need:
                        MorningNotificationMessages.forNeed(
                            need
                        ),
                    thinkerType:
                        MorningNotificationMessages.forThinkerType(
                            thinkerType
                        ),
                    reason:
                        MorningNotificationMessages.forReason(
                            reason
                        ),
                    seed: seed + 3
                )

            notifications.append(
                ScheduledNotification(
                    type: .morningPersonalized,
                    period: .morning,
                    date: date,
                    message: message
                )
            )
        }

        return notifications
    }

    // MARK: - AFTERNOON NOTIFICATIONS

    private func upcomingAfternoonNotifications(
        reason: String?,
        thinkerType: String?,
        need: String?
    ) -> [ScheduledNotification] {
        let calendar = Calendar.current
        let now = Date()

        var notifications: [ScheduledNotification] = []

        for dayOffset in 0..<daysToSchedule {
            guard let day = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: now
            ) else {
                continue
            }

            let seed = stableDaySeed(for: day)

            let date = notificationDate(
                on: day,
                startHour: 13,
                startMinute: 30,
                availableMinutes: 180,
                seed: seed + 29
            )

            guard date > now else {
                continue
            }

            let message =
                NotificationMessageSelector.selectPersonalized(
                    general:
                        AfternoonNotificationMessages.general,
                    need:
                        AfternoonNotificationMessages.forNeed(
                            need
                        ),
                    thinkerType:
                        AfternoonNotificationMessages.forThinkerType(
                            thinkerType
                        ),
                    reason:
                        AfternoonNotificationMessages.forReason(
                            reason
                        ),
                    seed: seed + 7
                )

            notifications.append(
                ScheduledNotification(
                    type: .afternoonPersonalized,
                    period: .afternoon,
                    date: date,
                    message: message
                )
            )
        }

        return notifications
    }

    // MARK: - EVENING NOTIFICATIONS

    private func upcomingEveningNotifications(
        reason: String?,
        thinkerType: String?,
        need: String?,
        entries: [ThoughtEntry]
    ) -> [ScheduledNotification] {
        let calendar = Calendar.current
        let now = Date()

        var notifications: [ScheduledNotification] = []

        for dayOffset in 0..<daysToSchedule {
            guard let day = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: now
            ) else {
                continue
            }

            guard let notification = makeEveningNotification(
                for: day,
                reason: reason,
                thinkerType: thinkerType,
                need: need,
                entries: entries
            ) else {
                continue
            }

            notifications.append(notification)
        }

        return notifications
    }

    // MARK: - REFRESH DYNAMIC EVENINGS

    func refreshTonightNotification(
        reason: String?,
        thinkerType: String?,
        need: String?,
        entries: [ThoughtEntry]
    ) async {
        let status = await authorizationStatus()

        guard status == .authorized ||
              status == .provisional ||
              status == .ephemeral
        else {
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        scheduler.removeNotification(
            period: .evening,
            date: today
        )

        if let tonightNotification = makeEveningNotification(
            for: today,
            reason: reason,
            thinkerType: thinkerType,
            need: need,
            entries: entries
        ) {
            await scheduler.schedule(tonightNotification)
        }

        if !conditionChecker.isSunday(today),
           let upcomingSunday = nextSunday(after: today) {

            scheduler.removeNotification(
                period: .evening,
                date: upcomingSunday
            )

            if let sundayNotification = makeEveningNotification(
                for: upcomingSunday,
                reason: reason,
                thinkerType: thinkerType,
                need: need,
                entries: entries
            ) {
                await scheduler.schedule(sundayNotification)
            }
        }

        print("EVENING NOTIFICATIONS REFRESHED")
    }

    // MARK: - MAKE EVENING NOTIFICATION

    private func makeEveningNotification(
        for day: Date,
        reason: String?,
        thinkerType: String?,
        need: String?,
        entries: [ThoughtEntry]
    ) -> ScheduledNotification? {
        let calendar = Calendar.current
        let seed = stableDaySeed(for: day)

        let eveningDate = notificationDate(
            on: day,
            startHour: 19,
            startMinute: 30,
            availableMinutes: 120,
            seed: seed + 47
        )

        guard eveningDate > Date() else {
            return nil
        }

        let selection: TonightNotificationSelection

        if conditionChecker.isSunday(day) {
            let stats = conditionChecker.weeklyStats(
                entries: entries,
                referenceDate: day
            )

            if stats.hasResets {
                selection = TonightNotificationSelection(
                    type: .weeklyAchievement,
                    message: WeeklyAchievementMessages.message(
                        stats: stats,
                        seed: seed + 101
                    )
                )
            } else {
                selection = TonightNotificationSelection(
                    type: .dailyResetReminder,
                    message: ResetReminderMessages.message(
                        seed: seed + 107
                    )
                )
            }

        } else if calendar.isDateInToday(day) {
            selection = conditionChecker.tonightSelection(
                entries: entries,
                reason: reason,
                thinkerType: thinkerType,
                need: need,
                referenceDate: day,
                seed: seed
            )

        } else {
            selection = TonightNotificationSelection(
                type: .dailyResetReminder,
                message: ResetReminderMessages.message(
                    seed: seed + 107
                )
            )
        }

        return ScheduledNotification(
            type: selection.type,
            period: .evening,
            date: eveningDate,
            message: selection.message
        )
    }

    // MARK: - NEXT SUNDAY

    private func nextSunday(
        after date: Date
    ) -> Date? {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: date)

        for dayOffset in 1...7 {
            guard let candidate = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: startOfToday
            ) else {
                continue
            }

            if conditionChecker.isSunday(candidate) {
                return candidate
            }
        }

        return nil
    }

    // MARK: - DATE GENERATION

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

        let mixedSeed =
            abs(seed &* 1_103_515_245 &+ 12_345)

        let variation =
            NotificationMessageSelector.positiveModulo(
                mixedSeed,
                availableMinutes + 1
            )

        let totalMinutes =
            startHour * 60 +
            startMinute +
            variation

        components.hour = totalMinutes / 60
        components.minute = totalMinutes % 60
        components.second = 0

        return calendar.date(
            from: components
        ) ?? day
    }

    // MARK: - REMOVE

    func removeLiveNowNotifications() async {
        await scheduler.removeAllLiveNowNotifications()
    }

    // MARK: - STABLE SEED

    private func stableDaySeed(
        for date: Date
    ) -> Int {
        let calendar = Calendar.current

        let startOfDay =
            calendar.startOfDay(for: date)

        let referenceDate =
            calendar.startOfDay(
                for: Date(
                    timeIntervalSinceReferenceDate: 0
                )
            )

        return calendar.dateComponents(
            [.day],
            from: referenceDate,
            to: startOfDay
        ).day ?? 0
    }
}
