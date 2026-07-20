//
//  NotificationModels.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 18. 7. 2026.
//

import Foundation

struct NotificationMessage: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String

    init(
        id: String = UUID().uuidString,
        title: String,
        body: String
    ) {
        self.id = id
        self.title = title
        self.body = body
    }
}

enum ReminderPeriod: String {
    case morning
    case afternoon
    case evening
}

struct ScheduledNotification {
    let type: NotificationType
    let period: ReminderPeriod
    let date: Date
    let message: NotificationMessage
}
