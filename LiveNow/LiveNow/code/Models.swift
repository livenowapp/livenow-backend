//
//  Models.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

// MARK: - MODELS

enum AppStep {
    case home
    case input
    case analyze
    case reframe
    case action
    case complete
}

enum MainTab {
    case home
    case moments
    case insights
    case profile
}

struct AIAnalysisItem: Codable, Hashable {
    let label: String
    let sub: String
}

struct AIEvidenceItem: Codable, Hashable {
    let q: String
    let a: String
}

struct AIActionItem: Codable, Hashable {
    let icon: String
    let label: String
}

struct AIResponse: Codable, Hashable {
    let analysis: [AIAnalysisItem]
    let evidence: [AIEvidenceItem]
    let reframes: [String]
    let actions: [AIActionItem]
    let insight: String
}

struct ThoughtEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let thought: String
    let ai: AIResponse
    var selectedActionLabel: String?
    var selectedActionIcon: String?
    var selectedReframe: String?
    var didHappen: EntryOutcome?
    var note: String?
}

enum EntryOutcome: String, Codable, CaseIterable, Hashable {
    case no
    case maybe
    case yes

    var title: String {
        switch self {
        case .no: return "no"
        case .maybe: return "maybe"
        case .yes: return "yes"
        }
    }

    var color: Color {
        switch self {
        case .no: return Color.green
        case .maybe: return Color.orange
        case .yes: return Color.red
        }
    }
}
