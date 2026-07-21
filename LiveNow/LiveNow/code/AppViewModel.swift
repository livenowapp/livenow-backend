//
//  AppViewModel.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
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
    @Published var showWelcomeBack = false
    
    @Published var showResetCheckIn = false
    @Published var pendingCheckInEntries: [ThoughtEntry] = []
    
    // MARK: - onboarding personalization

    @Published var onboardingReason = ""
    @Published var onboardingTime = ""
    @Published var onboardingThinkerType = ""
    @Published var onboardingNeed = ""
    
    private var lastAnalyzedThought: String = ""
    private var lastAIResponse: AIResponse? = nil

    private let db = Firestore.firestore()
    var isGuestUser: Bool {
        Auth.auth().currentUser == nil
    }
    private let guestFirstResetKey = 
        "livenow_guest_first_reset_v1"
    
    private let lastCheckInPromptDateKey =
        "livenow_last_check_in_prompt_date_v1"

    @Published var guestFirstReset: ThoughtEntry? = nil
    @Published var hasCompletedGuestReset = false
    @Published var showPaywall = false
    
    init() {
        loadGuestFirstReset()
                                            UserDefaults.standard.removeObject(
                                                forKey: lastCheckInPromptDateKey
                                            )
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
        if isSimilarThought(cleanedThought, lastAnalyzedThought),
           let cachedResponse = lastAIResponse {

            thought = cleanedThought
            aiResponse = cachedResponse
            step = .analyze
            return
        }

        isLoading = true
        errorMessage = nil
        step = .thinking

        do {
            
            /* let response = try await AIService.shared.analyzeThought(thought: cleanedThought)

            aiResponse = response
            lastAnalyzedThought = cleanedThought
            lastAIResponse = response

            step = .analyze*/
             
            
            let response = AIResponse(
                shortTitle: "feeling judged",
                analysis: [
                    AIAnalysisItem(
                        label: "possible overthinking",
                        sub: "Your mind may be assuming the worst too quickly."
                    ),
                    AIAnalysisItem(
                        label: "what your brain is doing",
                        sub: "You are trying to predict danger before it happens."
                    ),
                    AIAnalysisItem(
                        label: "thinking trap",
                        sub: "You're predicting what others think without evidence."
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
                    AIActionItem(icon: "action_leaf", label: "take 3 deep breaths"),
                    AIActionItem(icon: "action_nophone", label: "go for a short walk"),
                    AIActionItem(icon: "action_book", label: "write down the thought"),
                    AIActionItem(icon: "action_sleep", label: "rest for a moment")
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

        let action = ai.actions.indices.contains(selectedActionIndex)
            ? ai.actions[selectedActionIndex]
            : nil

        let reframe = ai.reframes.indices.contains(selectedReframeIndex)
            ? ai.reframes[selectedReframeIndex]
            : nil

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

        Task {
            await NotificationManager.shared.refreshTonightNotification(
                reason: onboardingReason,
                thinkerType: onboardingThinkerType,
                need: onboardingNeed,
                entries: entries
            )
        }
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
    
    // MARK: - Reset check-in

    func preparePendingCheckIns() {
        guard !isGuestUser else {
            pendingCheckInEntries = []
            showResetCheckIn = false
            return
        }

        // Če je check-in že odprt, ga ne pripravljaj ponovno.
        guard !showResetCheckIn,
              pendingCheckInEntries.isEmpty else {
            return
        }

        // Če je bil danes že prikazan, ga ne pokaži ponovno.
        guard !didShowCheckInToday else {
            pendingCheckInEntries = []
            showResetCheckIn = false
            return
        }

        let cutoffDate =
            Date().addingTimeInterval(-24 * 60 * 60)

        let eligibleEntries = entries
            .filter { entry in
                entry.worthIt == nil &&
                entry.date <= cutoffDate
            }
            .sorted { $0.date < $1.date }

        guard !eligibleEntries.isEmpty else {
            pendingCheckInEntries = []
            showResetCheckIn = false
            return
        }

        pendingCheckInEntries = eligibleEntries

        // Dan označimo šele, ko se ima kartica dejansko kaj prikazati.
        saveCheckInPromptDate()

        showResetCheckIn = true
    }

    func answerPendingCheckIn(
        entryID: UUID,
        outcome: EntryOutcome
    ) {
        updateOutcome(
            for: entryID,
            outcome: outcome
        )

        removePendingCheckIn(entryID: entryID)
    }

    func skipPendingCheckIn(entryID: UUID) {
        removePendingCheckIn(entryID: entryID)
    }

    func skipAllPendingCheckIns() {
        pendingCheckInEntries.removeAll()
        showResetCheckIn = false
    }

    private func removePendingCheckIn(entryID: UUID) {
        pendingCheckInEntries.removeAll {
            $0.id == entryID
        }

        if pendingCheckInEntries.isEmpty {
            showResetCheckIn = false
        }
    }
    
    private var didShowCheckInToday: Bool {
        guard let savedDate =
            UserDefaults.standard.object(
                forKey: lastCheckInPromptDateKey
            ) as? Date else {
            return false
        }

        return Calendar.current.isDateInToday(savedDate)
    }

    private func saveCheckInPromptDate() {
        UserDefaults.standard.set(
            Date(),
            forKey: lastCheckInPromptDateKey
        )
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
    
    var hasOnboardingAnswers: Bool {
        !onboardingReason.isEmpty ||
        !onboardingTime.isEmpty ||
        !onboardingThinkerType.isEmpty ||
        !onboardingNeed.isEmpty
    }

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

                Task { @MainActor in
                    let decodedEntries: [ThoughtEntry] = documents.compactMap { document in
                        do {
                            let rawData = try JSONSerialization.data(
                                withJSONObject: document.data()
                            )

                            let decoder = JSONDecoder()

                            return try decoder.decode(
                                ThoughtEntry.self,
                                from: rawData
                            )
                        } catch {
                            print("Decode entry error:", error)
                            return nil
                        }
                    }

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

    func loadOnboardingAnswersAsync() async {
        guard let user = Auth.auth().currentUser else {
            print("PERSONALIZATION: no Firebase user")
            return
        }

        print("PERSONALIZATION USER UID:", user.uid)

        do {
            let snapshot = try await db
                .collection("users")
                .document(user.uid)
                .getDocument()

            guard
                let data = snapshot.data()?["personalization"] as? [String: Any]
            else {
                print("PERSONALIZATION: document has no personalization field")
                return
            }

            await MainActor.run {
                self.onboardingReason =
                    data["onboardingReason"] as? String ?? ""

                self.onboardingTime =
                    data["onboardingTime"] as? String ?? ""

                self.onboardingThinkerType =
                    data["onboardingThinkerType"] as? String ?? ""

                self.onboardingNeed =
                    data["onboardingNeed"] as? String ?? ""
            }

            print("PERSONALIZATION LOADED")

        } catch {
            print(
                "LOAD ONBOARDING ERROR:",
                error.localizedDescription
            )
        }
    }
    
    func saveOnboardingAnswers(
        _ answers: [String: String]
    ) {
        onboardingReason =
            answers["onboardingReason"] ?? ""

        onboardingTime =
            answers["onboardingTime"] ?? ""

        onboardingThinkerType =
            answers["onboardingThinkerType"] ?? ""

        onboardingNeed =
            answers["onboardingNeed"] ?? ""

        print("ONBOARDING ANSWERS SAVED LOCALLY")
    }
    
    func saveCurrentOnboardingAnswersForLoggedInUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("PERSONALIZATION SAVE: no logged-in user")
            return
        }

        let hasAnswers =
            !onboardingReason.isEmpty ||
            !onboardingTime.isEmpty ||
            !onboardingThinkerType.isEmpty ||
            !onboardingNeed.isEmpty

        guard hasAnswers else {
            print("PERSONALIZATION SAVE: no answers available")
            return
        }

        let personalizationData: [String: Any] = [
            "onboardingReason": onboardingReason,
            "onboardingTime": onboardingTime,
            "onboardingThinkerType": onboardingThinkerType,
            "onboardingNeed": onboardingNeed,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        do {
            try await db
                .collection("users")
                .document(uid)
                .setData(
                    ["personalization": personalizationData],
                    merge: true
                )

            print("PERSONALIZATION SAVED TO FIRESTORE")
        } catch {
            print(
                "PERSONALIZATION SAVE ERROR:",
                error.localizedDescription
            )
        }
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

    private func normalizedThought(_ text: String) -> String {
        text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "[^a-z0-9 ]", with: "", options: .regularExpression)
    }

    private func isSimilarThought(_ current: String, _ previous: String) -> Bool {
        let a = normalizedThought(current)
        let b = normalizedThought(previous)

        guard !a.isEmpty, !b.isEmpty else { return false }

        if a == b { return true }

        let distance = levenshteinDistance(a, b)
        let maxLength = max(a.count, b.count)

        let similarity = 1.0 - (Double(distance) / Double(maxLength))

        return similarity >= 0.88
    }

    private func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        let lhs = Array(lhs)
        let rhs = Array(rhs)

        var matrix = Array(
            repeating: Array(repeating: 0, count: rhs.count + 1),
            count: lhs.count + 1
        )

        for i in 0...lhs.count {
            matrix[i][0] = i
        }

        for j in 0...rhs.count {
            matrix[0][j] = j
        }

        for i in 1...lhs.count {
            for j in 1...rhs.count {
                if lhs[i - 1] == rhs[j - 1] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = min(
                        matrix[i - 1][j] + 1,
                        matrix[i][j - 1] + 1,
                        matrix[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return matrix[lhs.count][rhs.count]
    }
    
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
