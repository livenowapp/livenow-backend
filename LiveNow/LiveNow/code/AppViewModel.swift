//
//  AppViewModel.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI
import Combine

// MARK: - STORAGE

final class AppViewModel: ObservableObject {
    @Published var currentTab: MainTab = .home
    @Published var step: AppStep = .home

    @Published var thought: String = ""
    @Published var aiResponse: AIResponse? = nil
    @Published var selectedReframeIndex: Int = 0
    @Published var selectedActionIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published var entries: [ThoughtEntry] = []
    @Published var selectedMoment: ThoughtEntry? = nil
    @Published var showAllTodayEntries: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var showSelectedDateEntries: Bool = false

    private let storageKey = "livenow_entries_v1"

    init() {
        loadEntries()
    }

    func goToInput() {
        currentTab = .home
        step = .input
        thought = ""
        aiResponse = nil
        selectedReframeIndex = 0
        selectedActionIndex = 0
        errorMessage = nil
    }

    @MainActor
    func analyze() async {
        guard !thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            //let response = try await AIService.shared.analyzeThought(thought: thought)
                  //      aiResponse = response
                   //     step = .analyze
            let response = AIResponse(
                analysis: [
                    AIAnalysisItem(
                        label: "possible overthinking",
                        sub: "Your mind may be assuming the worst too quickly."
                    ),
                    AIAnalysisItem(
                        label: "what your brain is doing",
                        sub: "You are trying to predict danger before it happens."
                    )
                ],

                evidence: [
                    AIEvidenceItem(
                        q: "Do you have clear proof?",
                        a: "Not really"
                    ),
                    AIEvidenceItem(
                        q: "Could there be another explanation?",
                        a: "Yes"
                    )
                ],

                reframes: [
                    "This thought is not necessarily true.",
                    "I don’t need to solve everything right now.",
                    "I can let this pass without reacting."
                ],

                actions: [
                    AIActionItem(
                        icon: "action_leaf",
                        label: "take 3 deep breaths"
                    ),
                    AIActionItem(
                        icon: "action_nophone",
                        label: "go for a short walk"
                    ),
                    AIActionItem(
                        icon: "action_book",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_sleep",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_walk",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_sunlight",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_music",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_handraised",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_chat",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_pencil",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_breath",
                        label: "write down the thought"
                    ),
                    AIActionItem(
                        icon: "action_meditation",
                        label: "listen to calming music"
                    )
                ],

                insight: "You often assume the worst before having evidence."
            )

            aiResponse = response
            step = .analyze
        } catch {
            print("ANALYZE ERROR:", error)
            errorMessage = "error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func goNext() {
        switch step {
        case .home:
            step = .input
        case .input:
            step = .analyze
        case .analyze:
            step = .reframe
        case .reframe:
            step = .action
        case .action:
            completeReset()
        case .complete:
            step = .home
        }
    }

    func goBack() {
        switch step {
        case .home:
            break
        case .input:
            step = .home
        case .analyze:
            step = .input
        case .reframe:
            step = .analyze
        case .action:
            step = .reframe
        case .complete:
            step = .home
        }
    }

    func completeReset() {
        guard let ai = aiResponse else { return }

        let action = ai.actions.indices.contains(selectedActionIndex) ? ai.actions[selectedActionIndex] : nil
        let reframe = ai.reframes.indices.contains(selectedReframeIndex) ? ai.reframes[selectedReframeIndex] : nil
        
        let entry = ThoughtEntry(
            id: UUID(),
            date: Date(),
            thought: thought,
            ai: ai,
            selectedActionLabel: action?.label,
            selectedActionIcon: action?.icon,
            selectedReframe: reframe,
            didHappen: nil
        )

        entries.insert(entry, at: 0)
        saveEntries()
        step = .complete
    }

    func resetToHome() {
        step = .home
        thought = ""
        aiResponse = nil
        selectedReframeIndex = 0
        selectedActionIndex = 0
        errorMessage = nil
        currentTab = .home
    }

    func updateOutcome(for entryID: UUID, outcome: EntryOutcome) {
        guard let index = entries.firstIndex(where: { $0.id == entryID }) else { return }
        entries[index].didHappen = outcome
        saveEntries()
    }

    func updateNote(for entryID: UUID, note: String) {
        guard let index = entries.firstIndex(where: { $0.id == entryID }) else { return }
        entries[index].note = note
        saveEntries()
    }

    func deleteEntry(_ entryID: UUID) {
        entries.removeAll { $0.id == entryID }
        selectedMoment = nil
        saveEntries()
    }
    
    func symbolName(for icon: String?) -> String {
        return icon ?? "sparkles"
    }
    
    var unresolvedEntries: [ThoughtEntry] {
        entries.filter { $0.didHappen == nil }
    }

    var resolvedEntries: [ThoughtEntry] {
        entries.filter { $0.didHappen != nil }
    }

    var didntHappenCount: Int {
        entries.filter { $0.didHappen == .no }.count
    }

    var maybeCount: Int {
        entries.filter { $0.didHappen == .maybe }.count
    }

    var happenedCount: Int {
        entries.filter { $0.didHappen == .yes }.count
    }

    var totalResolvedCount: Int {
        entries.filter { $0.didHappen != nil }.count
    }

    var didNotHappenPercent: Int {
        let total = totalResolvedCount
        guard total > 0 else { return 0 }
        return Int((Double(didntHappenCount) / Double(total) * 100).rounded())
    }

    var mostUsedAction: (icon: String, label: String) {
        let actions = entries.compactMap { entry -> (icon: String, label: String, date: Date)? in
            guard
                let icon = entry.selectedActionIcon,
                let label = entry.selectedActionLabel
            else {
                return nil
            }

            return (icon, label, entry.date)
        }

        guard !actions.isEmpty else {
            return ("sparkles", "No reset yet")
        }

        let grouped = Dictionary(grouping: actions, by: { $0.icon })

        let ranked = grouped.map { icon, items in
            (
                icon: icon,
                label: items.first?.label ?? "Reset",
                count: items.count,
                latestDate: items.map(\.date).max() ?? Date.distantPast
            )
        }

        let winner = ranked.sorted {
            if $0.count == $1.count {
                return $0.latestDate > $1.latestDate
            }

            return $0.count > $1.count
        }.first

        return (
            winner?.icon ?? "sparkles",
            winner?.label ?? "No reset yet"
        )
    }

    // MARK: - Last 7 days

    var last7DaysEntries: [ThoughtEntry] {
        let calendar = Calendar.current
        let now = Date()

        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: now) else {
            return []
        }

        let startDate = calendar.startOfDay(for: sevenDaysAgo)

        return entries.filter { entry in
            entry.date >= startDate
        }
    }

    var last7DaysDidntHappenCount: Int {
        last7DaysEntries.filter { $0.didHappen == .no }.count
    }

    var last7DaysMaybeCount: Int {
        last7DaysEntries.filter { $0.didHappen == .maybe }.count
    }

    var last7DaysHappenedCount: Int {
        last7DaysEntries.filter { $0.didHappen == .yes }.count
    }

    var last7DaysResolvedCount: Int {
        last7DaysEntries.filter { $0.didHappen != nil }.count
    }

    var last7DaysDidNotHappenPercent: Int {
        let total = last7DaysResolvedCount
        guard total > 0 else { return 0 }

        return Int((Double(last7DaysDidntHappenCount) / Double(total) * 100).rounded())
    }

    var streakCount: Int {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        let sortedDays = grouped.keys.sorted(by: >)

        guard !sortedDays.isEmpty else { return 0 }

        var streak = 0
        var currentDay = calendar.startOfDay(for: Date())

        for day in sortedDays {
            if calendar.isDate(day, inSameDayAs: currentDay) {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: currentDay) else { break }
                currentDay = previous
            } else if day < currentDay {
                break
            }
        }

        return streak
    }

    func entries(for date: Date) -> [ThoughtEntry] {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted(by: { $0.date > $1.date })
    }

    func hasEntry(on date: Date) -> Bool {
        !entries(for: date).isEmpty
    }

    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Save error:", error)
        }
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            entries = try JSONDecoder().decode([ThoughtEntry].self, from: data)
        } catch {
            print("Load error:", error)
        }
    }
    var activeDaysCount: Int {
        let calendar = Calendar.current

        let uniqueDays = Set(
            last7DaysEntries.map {
                calendar.startOfDay(for: $0.date)
            }
        )

        return uniqueDays.count
    }
}
