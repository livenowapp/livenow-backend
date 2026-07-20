//
//  OnboardingPersonalization.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation

// MARK: - ONBOARDING REASON

enum OnboardingReason: String, Codable, CaseIterable {
    case overthinkOften = "overthink_often"
    case anxietyOften = "anxiety_often"
    case moreClarity = "more_clarity"
    case healthierHabits = "healthier_habits"
    case understandMyself = "understand_myself"

    var title: String {
        switch self {
        case .overthinkOften:
            return "I overthink a lot"

        case .anxietyOften:
            return "I feel anxious often"

        case .moreClarity:
            return "I want more clarity"

        case .healthierHabits:
            return "I want healthier habits"

        case .understandMyself:
            return "I want to understand myself"
        }
    }

    init?(storedValue: String?) {
        guard let value = storedValue?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty
        else {
            return nil
        }

        if let rawValueMatch = Self(rawValue: value) {
            self = rawValueMatch
            return
        }

        switch value.lowercased() {
        case "i overthink a lot":
            self = .overthinkOften

        case "i feel anxious often":
            self = .anxietyOften

        case "i want more clarity":
            self = .moreClarity

        case "i want healthier habits":
            self = .healthierHabits

        case "i want to understand myself":
            self = .understandMyself

        default:
            return nil
        }
    }
}

// MARK: - THINKER TYPE

enum OnboardingThinkerType: String, Codable, CaseIterable {
    case replayPastConversations = "replay_past_conversations"
    case worryAboutFuture = "worry_about_future"
    case overanalyzeDecisions = "overanalyze_decisions"
    case assumeWorst = "assume_worst"
    case mixed = "mixed"

    var title: String {
        switch self {
        case .replayPastConversations:
            return "I replay past conversations"

        case .worryAboutFuture:
            return "I worry about the future"

        case .overanalyzeDecisions:
            return "I overanalyze decisions"

        case .assumeWorst:
            return "I assume the worst"

        case .mixed:
            return "A bit of everything"
        }
    }

    init?(storedValue: String?) {
        guard let value = storedValue?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty
        else {
            return nil
        }

        if let rawValueMatch = Self(rawValue: value) {
            self = rawValueMatch
            return
        }

        switch value.lowercased() {
        case "i replay past conversations":
            self = .replayPastConversations

        case "i worry about the future":
            self = .worryAboutFuture

        case "i overanalyze decisions":
            self = .overanalyzeDecisions

        case "i assume the worst":
            self = .assumeWorst

        case "a bit of everything":
            self = .mixed

        default:
            return nil
        }
    }
}

// MARK: - ONBOARDING NEED

enum OnboardingNeed: String, Codable, CaseIterable {
    case peaceOfMind = "peace_of_mind"
    case confidence = "confidence"
    case clarity = "clarity"
    case motivation = "motivation"
    case betterHabits = "better_habits"

    var title: String {
        switch self {
        case .peaceOfMind:
            return "Peace of mind"

        case .confidence:
            return "Confidence"

        case .clarity:
            return "Clarity"

        case .motivation:
            return "Motivation"

        case .betterHabits:
            return "Better habits"
        }
    }

    init?(storedValue: String?) {
        guard let value = storedValue?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty
        else {
            return nil
        }

        if let rawValueMatch = Self(rawValue: value) {
            self = rawValueMatch
            return
        }

        switch value.lowercased() {
        case "peace of mind":
            self = .peaceOfMind

        case "confidence":
            self = .confidence

        case "clarity":
            self = .clarity

        case "motivation":
            self = .motivation

        case "better habits":
            self = .betterHabits

        default:
            return nil
        }
    }
}
