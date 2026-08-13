//
//  Models.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI

// MARK: - MODELS

enum AppStep {
    case home
    case input
    case thinking
    case analyze
    case urgentSafety
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
    let type: String
    let label: String
    let sub: String

    enum CodingKeys: String, CodingKey {
        case type
        case label
        case sub
    }

    init(
        type: String,
        label: String,
        sub: String
    ) {
        self.type = type
        self.label = label
        self.sub = sub
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        type = try container.decodeIfPresent(
            String.self,
            forKey: .type
        ) ?? "balanced_context"

        label = try container.decode(
            String.self,
            forKey: .label
        )

        sub = try container.decode(
            String.self,
            forKey: .sub
        )
    }
}

struct AISafety: Codable, Hashable {
    let level: String
    let message: String?
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
    let safety: AISafety
    let shortTitle: String
    let analysis: [AIAnalysisItem]
    let evidence: [AIEvidenceItem]
    let reframes: [String]
    let actions: [AIActionItem]
    let insight: String

    enum CodingKeys: String, CodingKey {
        case safety
        case shortTitle
        case analysis
        case evidence
        case reframes
        case actions
        case insight
    }

    init(
        safety: AISafety,
        shortTitle: String,
        analysis: [AIAnalysisItem],
        evidence: [AIEvidenceItem],
        reframes: [String],
        actions: [AIActionItem],
        insight: String
    ) {
        self.safety = safety
        self.shortTitle = shortTitle
        self.analysis = analysis
        self.evidence = evidence
        self.reframes = reframes
        self.actions = actions
        self.insight = insight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        safety = try container.decodeIfPresent(
            AISafety.self,
            forKey: .safety
        ) ?? AISafety(
            level: "normal",
            message: nil
        )

        shortTitle = try container.decode(
            String.self,
            forKey: .shortTitle
        )

        analysis = try container.decode(
            [AIAnalysisItem].self,
            forKey: .analysis
        )

        evidence = try container.decode(
            [AIEvidenceItem].self,
            forKey: .evidence
        )

        reframes = try container.decode(
            [String].self,
            forKey: .reframes
        )

        actions = try container.decode(
            [AIActionItem].self,
            forKey: .actions
        )

        insight = try container.decode(
            String.self,
            forKey: .insight
        )
    }
}

struct ThoughtEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let thought: String
    let ai: AIResponse
    var selectedActionLabel: String?
    var selectedActionIcon: String?
    var selectedReframe: String?
    var worthIt: EntryOutcome?
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
