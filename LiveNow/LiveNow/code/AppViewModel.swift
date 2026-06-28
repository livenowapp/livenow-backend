//
//  AppViewModel.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

// MARK: - STORAGE

final class AppViewModel: ObservableObject {
    @Published var currentTab: MainTab = .home
    @Published var step: AppStep = .home

    @Published var thought = ""
    @Published var aiResponse: AIResponse? = nil
    @Published var selectedReframeIndex = 0
    @Published var selectedActionIndex = 0
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    @Published var entries: [ThoughtEntry] = []
    @Published var selectedMoment: ThoughtEntry? = nil
    @Published var showAllTodayEntries = false
    @Published var selectedDate = Date()
    @Published var showSelectedDateEntries = false
    
    private var lastAnalyzedThought: String = ""
    private var lastAIResponse: AIResponse? = nil

    private let db = Firestore.firestore()
    var isGuestUser: Bool {
        Auth.auth().currentUser == nil
    }
    private let guestFirstResetKey = "livenow_guest_first_reset_v1"

    @Published var guestFirstReset: ThoughtEntry? = nil
    @Published var hasCompletedGuestReset = false
    @Published var showPaywall = false
    
    init() {
        loadGuestFirstReset()

        if Auth.auth().currentUser != nil {
            loadEntries()
        }
    }
    

    // MARK: - Navigation

    func goToInput() {
        if isGuestUser && hasCompletedGuestReset {
            showPaywall = true
            return
        }

        currentTab = .home
        step = .input
        thought = ""
        aiResponse = nil
        selectedReframeIndex = 0
        selectedActionIndex = 0
        errorMessage = nil
    }

    func goNext() {
        switch step {
        case .home: step = .input
        case .input: step = .thinking
        case .thinking: step = .analyze
        case .analyze: step = .reframe
        case .reframe: step = .action
        case .action:
            if isGuestUser {
                completeGuestReset()
            } else {
                completeReset()
            }
        case .complete: step = .home
        }
    }

    func goBack() {
        switch step {
        case .home: break
        case .input: step = .home
        case .thinking: step = .input
        case .analyze: step = .input
        case .reframe: step = .analyze
        case .action: step = .reframe
        case .complete: step = .home
        }
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
    
    func requestPremiumAccess() {
        showPaywall = true
    }
    
    func migrateGuestFirstResetToFirestoreIfNeeded() {
        guard Auth.auth().currentUser != nil else { return }
        guard let guestEntry = guestFirstReset else { return }

        entries.insert(guestEntry, at: 0)
        saveEntry(guestEntry)
        clearGuestFirstReset()
    }

    // MARK: - Analyze

    @MainActor
    func analyze() async {
        let cleanedThought = thought.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedThought.isEmpty else { return }

        // Če je user že analiziral isti tekst, ne kličemo API-ja ponovno
        if cleanedThought == lastAnalyzedThought, let cachedResponse = lastAIResponse {
            aiResponse = cachedResponse
            step = .analyze
            return
        }

        isLoading = true
        errorMessage = nil
        step = .thinking

        do {
            
            /*let response = try await AIService.shared.analyzeThought(thought: cleanedThought)

            aiResponse = response
            lastAnalyzedThought = cleanedThought
            lastAIResponse = response

            step = .analyze
             */
            
            let response = AIResponse(
                analysis: [
                    AIAnalysisItem(label: "possible overthinking", sub: "Your mind may be assuming the worst too quickly."),
                    AIAnalysisItem(label: "what your brain is doing", sub: "You are trying to predict danger before it happens.")
                ],
                evidence: [
                    AIEvidenceItem(q: "Do you have clear proof?", a: "Not really"),
                    AIEvidenceItem(q: "Could there be another explanation?", a: "Yes")
                ],
                reframes: [
                    "This thought is not necessarily true.",
                    "I don’t need to solve everything right now.",
                    "I can let this pass without reacting."
                ],
                actions: [
                    AIActionItem(icon: "action_leaf", label: "take 3 deep breaths"),
                    AIActionItem(icon: "action_nophone", label: "go for a short walk"),
                    AIActionItem(icon: "action_book", label: "write down the thought"),
                    AIActionItem(icon: "action_sleep", label: "rest for a moment"),
                   /* AIActionItem(icon: "action_walk", label: "take a short walk"),
                    AIActionItem(icon: "action_sunlight", label: "step into sunlight"),
                    AIActionItem(icon: "action_music", label: "listen to calming music"),
                    AIActionItem(icon: "action_handraised", label: "pause and breathe"),
                    AIActionItem(icon: "action_chat", label: "talk to someone"),
                    AIActionItem(icon: "action_pencil", label: "write it down"),
                    AIActionItem(icon: "action_breath", label: "slow your breathing"),
                    AIActionItem(icon: "action_meditation", label: "sit quietly")*/
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

    // MARK: - Entries

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
            worthIt: nil
        )

        entries.insert(entry, at: 0)
        saveEntry(entry)
        step = .complete
    }

    func updateOutcome(for entryID: UUID, outcome: EntryOutcome?) {
        guard let index = entries.firstIndex(where: { $0.id == entryID }) else { return }
        entries[index].worthIt = outcome
        saveEntry(entries[index])
    }

    func updateNote(for entryID: UUID, note: String) {
        guard let index = entries.firstIndex(where: { $0.id == entryID }) else { return }
        entries[index].note = note
        saveEntry(entries[index])
    }

    func deleteEntry(_ entryID: UUID) {
        entries.removeAll { $0.id == entryID }
        selectedMoment = nil
        deleteEntryFromFirestore(entryID)
    }

    func entries(for date: Date) -> [ThoughtEntry] {
        let calendar = Calendar.current

        return entries
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date > $1.date }
    }

    func hasEntry(on date: Date) -> Bool {
        !entries(for: date).isEmpty
    }

    func symbolName(for icon: String?) -> String {
        icon ?? "sparkles"
    }
    
    func completeGuestReset() {
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
            worthIt: nil
        )

        guestFirstReset = entry
        hasCompletedGuestReset = true
        saveGuestFirstReset(entry)

        step = .complete
    }

    // MARK: - General Stats

    var unresolvedEntries: [ThoughtEntry] {
        entries.filter { $0.worthIt == nil }
    }

    var resolvedEntries: [ThoughtEntry] {
        entries.filter { $0.worthIt != nil }
    }

    var notWorthItCount: Int {
        entries.filter { $0.worthIt == .no }.count
    }

    var maybeCount: Int {
        entries.filter { $0.worthIt == .maybe }.count
    }

    var worthItCount: Int {
        entries.filter { $0.worthIt == .yes }.count
    }

    var totalResolvedCount: Int {
        entries.filter { $0.worthIt != nil }.count
    }

    var notWorthItPercent: Int {
        percent(part: notWorthItCount, total: totalResolvedCount)
    }

    // MARK: - Last 7 Days Stats

    var last7DaysEntries: [ThoughtEntry] {
        guard let sevenDaysAgo = Calendar.current.date(
            byAdding: .day,
            value: -7,
            to: Date()
        ) else {
            return []
        }

        return entries.filter { $0.date >= sevenDaysAgo }
    }

    var last7DaysResetCount: Int {
        last7DaysEntries.count
    }

    var last7DaysNotWorthItCount: Int {
        last7DaysEntries.filter { $0.worthIt == .no }.count
    }

    var last7DaysMaybeCount: Int {
        last7DaysEntries.filter { $0.worthIt == .maybe }.count
    }

    var last7DaysWorthItCount: Int {
        last7DaysEntries.filter { $0.worthIt == .yes }.count
    }

    var last7DaysResolvedCount: Int {
        last7DaysEntries.filter { $0.worthIt != nil }.count
    }

    var last7DaysNotWorthItPercent: Int {
        percent(
            part: last7DaysNotWorthItCount,
            total: last7DaysResolvedCount
        )
    }
    // MARK: - Month Stats

    var thisMonthEntries: [ThoughtEntry] {
        let calendar = Calendar.current

        guard let startOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: Date())
        ) else {
            return []
        }

        return entries.filter { $0.date >= startOfMonth }
    }

    var thisMonthResetCount: Int {
        thisMonthEntries.count
    }

    var thisMonthNotWorthItCount: Int {
        thisMonthEntries.filter { $0.worthIt == .no }.count
    }

    var thisMonthMaybeCount: Int {
        thisMonthEntries.filter { $0.worthIt == .maybe }.count
    }

    var thisMonthWorthItCount: Int {
        thisMonthEntries.filter { $0.worthIt == .yes }.count
    }

    var thisMonthResolvedCount: Int {
        thisMonthEntries.filter { $0.worthIt != nil }.count
    }

    var thisMonthNotWorthItPercent: Int {
        percent(part: thisMonthNotWorthItCount, total: thisMonthResolvedCount)
    }

    var thisMonthActiveDaysCount: Int {
        let calendar = Calendar.current

        let uniqueDays = Set(
            thisMonthEntries.map {
                calendar.startOfDay(for: $0.date)
            }
        )

        return uniqueDays.count
    }

    // MARK: - Streak / Most Used

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

                guard let previous = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                    break
                }

                currentDay = previous
            } else if day < currentDay {
                break
            }
        }

        return streak
    }

    var mostUsedAction: (icon: String, label: String) {
        let actions = entries.compactMap { entry -> (icon: String, label: String, date: Date)? in
            guard let icon = entry.selectedActionIcon,
                  let label = entry.selectedActionLabel else {
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

    // MARK: - Firestore

    private func userEntriesCollection() -> CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        return db
            .collection("users")
            .document(uid)
            .collection("entries")
    }

    private func saveEntry(_ entry: ThoughtEntry) {
        guard let collection = userEntriesCollection() else { return }

        do {
            let data = try JSONEncoder().encode(entry)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

            collection
                .document(entry.id.uuidString)
                .setData(json) { error in
                    if let error {
                        print("Firestore save error:", error.localizedDescription)
                    } else {
                        print("Saved entry:", entry.id.uuidString)
                    }
                }
        } catch {
            print("Encode entry error:", error)
        }
    }

    private func loadEntries() {
        guard let collection = userEntriesCollection() else {
            entries = []
            return
        }

        collection
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    print("Firestore load error:", error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.entries = []
                    }
                    return
                }

                let decodedEntries: [ThoughtEntry] = documents.compactMap { document in
                    do {
                        let rawData = try JSONSerialization.data(withJSONObject: document.data())
                        let decoder = JSONDecoder()
                        return try decoder.decode(ThoughtEntry.self, from: rawData)
                    } catch {
                        print("Decode entry error:", error)
                        return nil
                    }
                }

                DispatchQueue.main.async {
                    self.entries = decodedEntries
                }
            }
    }

    private func deleteEntryFromFirestore(_ entryID: UUID) {
        guard let collection = userEntriesCollection() else { return }

        collection.document(entryID.uuidString).delete { error in
            if let error {
                print("Firestore delete error:", error.localizedDescription)
            }
        }
    }

    func reloadEntriesForCurrentUser() {
        guard Auth.auth().currentUser != nil else {
            entries = []
            return
        }

        loadEntries()
    }
    
    // MARK: - Last Month

    var lastMonthEntries: [ThoughtEntry] {
        let calendar = Calendar.current

        guard
            let startOfCurrentMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: Date())
            ),
            let startOfLastMonth = calendar.date(
                byAdding: .month,
                value: -1,
                to: startOfCurrentMonth
            )
        else {
            return []
        }

        return entries.filter {
            $0.date >= startOfLastMonth &&
            $0.date < startOfCurrentMonth
        }
    }

    var lastMonthResetCount: Int {
        lastMonthEntries.count
    }

    var lastMonthNotWorthItCount: Int {
        lastMonthEntries.filter { $0.worthIt == .no }.count
    }

    var lastMonthMaybeCount: Int {
        lastMonthEntries.filter { $0.worthIt == .maybe }.count
    }

    var lastMonthWorthItCount: Int {
        lastMonthEntries.filter { $0.worthIt == .yes }.count
    }

    var lastMonthResolvedCount: Int {
        lastMonthEntries.filter { $0.worthIt != nil }.count
    }

    var lastMonthNotWorthItPercent: Int {
        guard lastMonthResolvedCount > 0 else { return 0 }

        return Int(
            (Double(lastMonthNotWorthItCount) / Double(lastMonthResolvedCount) * 100)
                .rounded()
        )
    }

    var lastMonthActiveDaysCount: Int {
        let calendar = Calendar.current

        let uniqueDays = Set(
            lastMonthEntries.map {
                calendar.startOfDay(for: $0.date)
            }
        )

        return uniqueDays.count
    }

    // MARK: - Helpers

    private func percent(part: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(part) / Double(total) * 100).rounded())
    }
    
    private func saveGuestFirstReset(_ entry: ThoughtEntry) {
        do {
            let data = try JSONEncoder().encode(entry)
            UserDefaults.standard.set(data, forKey: guestFirstResetKey)
        } catch {
            print("Guest reset save error:", error)
        }
    }

    private func loadGuestFirstReset() {
        guard let data = UserDefaults.standard.data(forKey: guestFirstResetKey) else {
            guestFirstReset = nil
            hasCompletedGuestReset = false
            return
        }

        do {
            let entry = try JSONDecoder().decode(ThoughtEntry.self, from: data)
            guestFirstReset = entry
            hasCompletedGuestReset = true
        } catch {
            print("Guest reset load error:", error)
            guestFirstReset = nil
            hasCompletedGuestReset = false
        }
    }

    func clearGuestFirstReset() {
        guestFirstReset = nil
        hasCompletedGuestReset = false
        UserDefaults.standard.removeObject(forKey: guestFirstResetKey)
    }
}
