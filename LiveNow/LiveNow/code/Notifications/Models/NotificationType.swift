//
//  NotificationType.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation

enum NotificationType: String, Codable {
    case morningPersonalized
    case afternoonPersonalized
    case eveningPersonalized

    case dailyResetReminder
    case inactivityReminder
    case weeklyAchievement

    var identifierComponent: String {
        rawValue
    }
}
