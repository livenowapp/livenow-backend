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
    case morePeaceOfMind = "more_peace_of_mind"

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

        case .morePeaceOfMind:
            return "I want more peace of mind"
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

        case "i want more peace of mind":
            self = .morePeaceOfMind

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
    case calm = "calm"
    case confidence = "confidence"
    case clarity = "clarity"
    case lessOverthinking = "less_overthinking"
    case betterHabits = "better_habits"

    var title: String {
        switch self {
        case .calm:
            return "Calm"

        case .confidence:
            return "Confidence"

        case .clarity:
            return "Clarity"

        case .lessOverthinking:
            return "Less overthinking"

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
        case "calm":
            self = .calm

        case "confidence":
            self = .confidence

        case "clarity":
            self = .clarity

        case "less overthinking":
            self = .lessOverthinking

        case "better habits":
            self = .betterHabits

        default:
            return nil
        }
    }
}
