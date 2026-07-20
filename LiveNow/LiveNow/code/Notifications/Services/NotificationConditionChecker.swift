//
//  NotificationConditionChecker.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation

// MARK: - MODELS

struct WeeklyNotificationStats {

    let resetCount: Int

    let resolvedCount: Int
    let worthItCount: Int
    let maybeCount: Int
    let notWorthItCount: Int

    let worthItPercentage: Int
    let maybePercentage: Int
    let notWorthItPercentage: Int

    var hasResets: Bool {
        resetCount > 0
    }

    var hasResolvedResets: Bool {
        resolvedCount > 0
    }
}
    
struct TonightNotificationSelection {
    let type: NotificationType
    let message: NotificationMessage
}

// MARK: - CONDITION CHECKER

struct NotificationConditionChecker {

    private let calendar: Calendar

    init(
        calendar: Calendar = .current
    ) {
        self.calendar = calendar
    }

    // MARK: - RESET TODAY

    func hasResetToday(
        entries: [ThoughtEntry],
        referenceDate: Date = Date()
    ) -> Bool {
        entries.contains { entry in
            calendar.isDate(
                entry.date,
                inSameDayAs: referenceDate
            )
        }
    }

    // MARK: - DAYS SINCE LAST RESET

    func daysSinceLastReset(
        entries: [ThoughtEntry],
        referenceDate: Date = Date()
    ) -> Int? {
        guard let latestEntry = entries.max(
            by: { $0.date < $1.date }
        ) else {
            return nil
        }

        let latestResetDay =
            calendar.startOfDay(for: latestEntry.date)

        let referenceDay =
            calendar.startOfDay(for: referenceDate)

        let difference = calendar.dateComponents(
            [.day],
            from: latestResetDay,
            to: referenceDay
        ).day ?? 0

        return max(difference, 0)
    }

    // MARK: - INACTIVITY REMINDER

    func shouldSendInactivityReminder(
        entries: [ThoughtEntry],
        minimumInactiveDays: Int = 3,
        referenceDate: Date = Date()
    ) -> Bool {
        guard let inactiveDays = daysSinceLastReset(
            entries: entries,
            referenceDate: referenceDate
        ) else {
            // Uporabnik nima še nobenega reseta.
            // To za zdaj ne obravnavamo kot večdnevno neaktivnost.
            return false
        }

        return inactiveDays >= minimumInactiveDays
    }

    // MARK: - DAILY RESET REMINDER

    func shouldSendDailyResetReminder(
        entries: [ThoughtEntry],
        referenceDate: Date = Date()
    ) -> Bool {
        !hasResetToday(
            entries: entries,
            referenceDate: referenceDate
        )
    }

    // MARK: - SUNDAY

    func isSunday(
        _ date: Date
    ) -> Bool {
        calendar.component(
            .weekday,
            from: date
        ) == 1
    }

    // MARK: - WEEKLY ACHIEVEMENT

    func shouldSendWeeklyAchievement(
        entries: [ThoughtEntry],
        referenceDate: Date = Date()
    ) -> Bool {
        guard isSunday(referenceDate) else {
            return false
        }

        let stats = weeklyStats(
            entries: entries,
            referenceDate: referenceDate
        )

        return stats.hasResets
    }

    // MARK: - WEEKLY STATS

    func weeklyStats(
        entries: [ThoughtEntry],
        referenceDate: Date = Date()
    ) -> WeeklyNotificationStats {
        let weeklyEntries = entriesForCurrentWeek(
            entries: entries,
            referenceDate: referenceDate
        )

        let resolvedEntries = weeklyEntries.filter {
            $0.worthIt != nil
        }

        let worthItCount = resolvedEntries.filter {
            $0.worthIt == .yes
        }.count

        let maybeCount = resolvedEntries.filter {
            $0.worthIt == .maybe
        }.count

        let notWorthItCount = resolvedEntries.filter {
            $0.worthIt == .no
        }.count

        let resolvedCount = resolvedEntries.count

        return WeeklyNotificationStats(
            resetCount: weeklyEntries.count,
            resolvedCount: resolvedCount,
            worthItCount: worthItCount,
            maybeCount: maybeCount,
            notWorthItCount: notWorthItCount,
            worthItPercentage: percentage(
                part: worthItCount,
                total: resolvedCount
            ),
            maybePercentage: percentage(
                part: maybeCount,
                total: resolvedCount
            ),
            notWorthItPercentage: percentage(
                part: notWorthItCount,
                total: resolvedCount
            )
        )
    }

    // MARK: - CURRENT WEEK ENTRIES

    private func entriesForCurrentWeek(
        entries: [ThoughtEntry],
        referenceDate: Date
    ) -> [ThoughtEntry] {
        guard let startOfWeek = startOfMondayWeek(
            containing: referenceDate
        ) else {
            return []
        }

        guard let endOfWeek = calendar.date(
            byAdding: .day,
            value: 7,
            to: startOfWeek
        ) else {
            return []
        }

        return entries.filter { entry in
            entry.date >= startOfWeek &&
            entry.date < endOfWeek
        }
    }

    // MARK: - MONDAY WEEK START

    private func startOfMondayWeek(
        containing date: Date
    ) -> Date? {
        let startOfDay =
            calendar.startOfDay(for: date)

        let weekday = calendar.component(
            .weekday,
            from: startOfDay
        )

        /*
         Calendar weekday:
         Sunday = 1
         Monday = 2
         Tuesday = 3
         ...
         Saturday = 7
         */

        let daysSinceMonday =
            (weekday + 5) % 7

        return calendar.date(
            byAdding: .day,
            value: -daysSinceMonday,
            to: startOfDay
        )
    }

    // MARK: - PERCENTAGE

    private func percentage(
        part: Int,
        total: Int
    ) -> Int {
        guard total > 0 else {
            return 0
        }

        return Int(
            (
                Double(part) /
                Double(total) *
                100
            ).rounded()
        )
    }
    
    // MARK: - TONIGHT NOTIFICATION SELECTION

    func tonightSelection(
        entries: [ThoughtEntry],
        reason: String?,
        thinkerType: String?,
        need: String?,
        referenceDate: Date,
        seed: Int
    ) -> TonightNotificationSelection {

        // Priority 1:
        // Sunday weekly achievement.
        if shouldSendWeeklyAchievement(
            entries: entries,
            referenceDate: referenceDate
        ) {
            let stats = weeklyStats(
                entries: entries,
                referenceDate: referenceDate
            )

            let message = WeeklyAchievementMessages.message(
                stats: stats,
                seed: seed + 101
            )

            return TonightNotificationSelection(
                type: .weeklyAchievement,
                message: message
            )
        }

        // Priority 2:
        // User has been inactive for at least 3 days.
        if shouldSendInactivityReminder(
            entries: entries,
            minimumInactiveDays: 3,
            referenceDate: referenceDate
        ) {
            let inactiveDays = daysSinceLastReset(
                entries: entries,
                referenceDate: referenceDate
            ) ?? 3

            let message = InactivityNotificationMessages.message(
                inactiveDays: inactiveDays,
                seed: seed + 103
            )

            return TonightNotificationSelection(
                type: .inactivityReminder,
                message: message
            )
        }

        // Priority 3:
        // User has not completed a reset today.
        if shouldSendDailyResetReminder(
            entries: entries,
            referenceDate: referenceDate
        ) {
            let message = ResetReminderMessages.message(
                seed: seed + 107
            )

            return TonightNotificationSelection(
                type: .dailyResetReminder,
                message: message
            )
        }

        // Priority 4:
        // Normal personalized evening notification.
        let message = NotificationMessageSelector.selectPersonalized(
            general: EveningNotificationMessages.general,
            need: EveningNotificationMessages.forNeed(
                need
            ),
            thinkerType: EveningNotificationMessages.forThinkerType(
                thinkerType
            ),
            reason: EveningNotificationMessages.forReason(
                reason
            ),
            seed: seed + 13
        )

        return TonightNotificationSelection(
            type: .eveningPersonalized,
            message: message
        )
    }
}
