//
//  NotificationPriority.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation

enum NotificationPriority: Int, Comparable {
    case eveningPersonalized = 0
    case dailyResetReminder = 1
    case inactivityReminder = 2
    case weeklyAchievement = 3

    static func < (
        lhs: NotificationPriority,
        rhs: NotificationPriority
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
