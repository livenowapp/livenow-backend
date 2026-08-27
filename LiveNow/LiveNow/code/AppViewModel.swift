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
    @Published var homeMessage: String = HomeMessages.random()
    
    @Published var showResetCheckIn = false
    @Published var pendingCheckInEntries: [ThoughtEntry] = []
    
    @Published var inputGuidanceMessage: String? = nil
    
    // MARK: - onboarding personalization

    @Published var onboardingReason = ""
    @Published var onboardingTime = ""
    @Published var onboardingThinkerType = ""
    @Published var onboardingNeed = ""
    
    private var lastAnalyzedThought: String = ""
    private var lastAIResponse: AIResponse? = nil

    private let db = Firestore.firestore()
    
    private let lastCheckInPromptDateKey =
        "livenow_last_check_in_prompt_date_v1"

    @Published var showPaywall = false
    
    @Published var completionNote = ""

    private var currentCompletedEntryID: UUID?

    func refreshHomeMessage() {
        homeMessage = HomeMessages.random()
    }
    
    // MARK: - Navigation

    func goToInput() {
        currentTab = .home
        step = .input
        thought = ""
        aiResponse = nil
        lastAnalyzedThought = ""
        lastAIResponse = nil
        selectedReframeIndex = 0
        selectedActionIndex = 0
        completionNote = ""
        currentCompletedEntryID = nil
        errorMessage = nil
        inputGuidanceMessage = nil
    }

    func goNext() {
        switch step {
        case .home: step = .input
        case .input: step = .thinking
        case .thinking: step = .analyze
        case .analyze: step = .reframe
        case .reframe: step = .action
        case .urgentSafety: step = .home
        case .action:
            completeReset()
        case .complete: step = .home
        }
    }

    func goBack() {
        switch step {
        case .home: break
        case .input: step = .home
        case .thinking: step = .input
        case .analyze: step = .input
        case .urgentSafety: resetToHome()
        case .reframe: step = .analyze
        case .action: step = .reframe
        case .complete: step = .home
        }
    }

    func resetToHome() {
        step = .home
        thought = ""
        aiResponse = nil
        
        lastAnalyzedThought = ""
        lastAIResponse = nil
        
        selectedReframeIndex = 0
        selectedActionIndex = 0
        completionNote = ""
        currentCompletedEntryID = nil
        errorMessage = nil
        currentTab = .home
    }
    
    func requestPremiumAccess() {
        showPaywall = true
    }

    // MARK: - Analyze

   /* @MainActor
    func analyze() async {
        let cleanedThought = thought.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedThought.isEmpty else { return }

        // Če je user že analiziral isti tekst,
        // uporabimo zadnji fixed odgovor.
        if isSimilarThought(
            cleanedThought,
            lastAnalyzedThought
        ),
           let cachedResponse = lastAIResponse {

            thought = cleanedThought
            aiResponse = cachedResponse

            if cachedResponse.safety.level == "urgent" {
                step = .urgentSafety
            } else {
                step = .analyze
            }

            return
        }

        isLoading = true
        errorMessage = nil
        step = .thinking

        // Samo za test, da se thinking screen malo pokaže.
        try? await Task.sleep(
            nanoseconds: 1_500_000_000
        )

        let response = AIResponse(
            safety: AISafety(
                level: "elevated",
                message: "It may help to slow down and talk to someone you trust if this feeling keeps getting stronger."
            ),

            shortTitle: "Worried about what they think",

            analysis: [
                AIAnalysisItem(
                    type: "catastrophizing",
                    label: "You’re predicting the worst",
                    sub: "Your mind is treating one possible negative outcome as if it is already certain."
                ),

                AIAnalysisItem(
                    type: "mind_reading",
                    label: "You’re guessing what they think",
                    sub: "Right now, you don’t actually know what the other person is thinking or how they interpreted the situation."
                ),

                AIAnalysisItem(
                    type: "balanced_context",
                    label: "There are other possibilities",
                    sub: "The moment may have felt bigger to you than it did to them, and their reaction could have many explanations."
                )
            ],

            evidence: [
                AIEvidenceItem(
                    q: "Do you know for sure what they think?",
                    a: "No"
                ),

                AIEvidenceItem(
                    q: "Is there clear evidence something went wrong?",
                    a: "Not really"
                ),

                AIEvidenceItem(
                    q: "Could there be another explanation?",
                    a: "Yes"
                )
            ],

            reframes: [
                "I don’t actually know what they’re thinking, and I don’t need to figure it out right now.",

                "One awkward moment doesn’t define how someone sees me.",

                "I can let this stay uncertain instead of trying to solve it in my head."
            ],

            actions: [
                AIActionItem(
                    icon: "action_breath",
                    label: "Take 5 slow breaths and let your attention return to what is happening now."
                ),

                AIActionItem(
                    icon: "action_walk",
                    label: "Take a short walk and leave your phone alone for a few minutes."
                ),

                AIActionItem(
                    icon: "action_chat",
                    label: "Message someone about something completely unrelated and shift your focus."
                ),
                
                AIActionItem(
                    icon: "action_sunlight",
                    label: "Go outside and get some natural light and air to help clear your mind."
                )
            ],

            insight: "Your mind is trying to remove uncertainty by imagining what another person thinks, but there isn’t enough evidence to know."
        )

        thought = cleanedThought
        aiResponse = response
        lastAnalyzedThought = cleanedThought
        lastAIResponse = response

        if response.safety.level == "urgent" {
            step = .urgentSafety
        } else {
            step = .analyze
        }

        isLoading = false
    }*/
    
    @MainActor
    func analyze() async {

        let cleanedThought = thought.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedThought.isEmpty else {
            return
        }

        // Če je uporabnik že analiziral isto misel,
        // uporabimo zadnji odgovor brez novega API klica.
        if isSimilarThought(
            cleanedThought,
            lastAnalyzedThought
        ),
           let cachedResponse = lastAIResponse {

            thought = cleanedThought

            handleAIResponse(
                cachedResponse,
                for: cleanedThought
            )

            return
        }

        isLoading = true
        errorMessage = nil
        step = .thinking

        do {

            let response = try await AIService.shared.analyzeThought(
                thought: cleanedThought
            )

            handleAIResponse(
                response,
                for: cleanedThought
            )

        } catch {

            isLoading = false
            errorMessage = error.localizedDescription
            step = .input

            #if DEBUG
            print(
                "ANALYZE ERROR:",
                error.localizedDescription
            )
            #endif

            return
        }

        isLoading = false
    }
    
    /*@MainActor
    func analyze() async {
        let cleanedThought = thought.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedThought.isEmpty else { return }

        // Če je user že analiziral isti tekst, ne kličemo API-ja ponovno
        if isSimilarThought(cleanedThought, lastAnalyzedThought),
           let cachedResponse = lastAIResponse {

            thought = cleanedThought
            aiResponse = cachedResponse

            if cachedResponse.safety.level == "urgent" {
                step = .urgentSafety
            } else {
                step = .analyze
            }

            return
        }

        isLoading = true
        errorMessage = nil
        step = .thinking

        do {
            
            let response = try await AIService.shared.analyzeThought(thought: cleanedThought)

            aiResponse = response
            lastAnalyzedThought = cleanedThought
            lastAIResponse = response

            if response.safety.level == "urgent" {
                step = .urgentSafety
            } else {
                step = .analyze
            }
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            step = .input

            #if DEBUG
            print(
                "ANALYZE ERROR:",
                error.localizedDescription
            )
            #endif

            return
        }

        isLoading = false
    }*/
    
    @MainActor
    private func handleAIResponse(
        _ response: AIResponse,
        for cleanedThought: String
    ) {

        thought = cleanedThought

        switch response.inputAssessment {

        case .analyzable:

            aiResponse = response
            lastAnalyzedThought = cleanedThought
            lastAIResponse = response

            errorMessage = nil
            inputGuidanceMessage = nil

            if response.safety.level == "urgent" {
                step = .urgentSafety
            } else {
                step = .analyze
            }

        case .notOverthinking:

            aiResponse = nil
            lastAnalyzedThought = cleanedThought
            lastAIResponse = response

            errorMessage = nil
            inputGuidanceMessage =
                "Write a specific thought that's been bothering you."

            step = .input

        case .tooVague:

            aiResponse = nil
            lastAnalyzedThought = cleanedThought
            lastAIResponse = response

            errorMessage = nil
            inputGuidanceMessage =
                "Tell me a little more about what's on your mind."

            step = .input
        }
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

        let entryID = UUID()

        let entry = ThoughtEntry(
            id: entryID,
            date: Date(),
            thought: thought,
            ai: ai,
            selectedActionLabel: action?.label,
            selectedActionIcon: action?.icon,
            selectedReframe: reframe,
            worthIt: nil,
            note: nil
        )

        entries.insert(entry, at: 0)

        currentCompletedEntryID = entryID
        completionNote = ""

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

    func updateOutcome(
        for entryID: UUID,
        outcome: EntryOutcome?
    ) {
        guard let index = entries.firstIndex(
            where: { $0.id == entryID }
        ) else {
            return
        }

        entries[index].worthIt = outcome
        saveEntry(entries[index])

        let currentEntries = entries

        Task {
            await NotificationManager.shared.refreshTonightNotification(
                reason: onboardingReason,
                thinkerType: onboardingThinkerType,
                need: onboardingNeed,
                entries: currentEntries
            )
        }
    }

    func updateNote(
        for entryID: UUID,
        note: String
    ) {
        guard let index = entries.firstIndex(where: {
            $0.id == entryID
        }) else {
            return
        }

        let cleanedNote = note.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        entries[index].note = cleanedNote.isEmpty
            ? nil
            : note

        if selectedMoment?.id == entryID {
            selectedMoment = entries[index]
        }

        saveEntry(entries[index])
    }
    
    func updateCurrentCompletionNote(_ note: String) {
        completionNote = note

        guard let entryID = currentCompletedEntryID else {
            return
        }

        updateNote(
            for: entryID,
            note: note
        )
    }

    func deleteEntry(_ entryID: UUID) {
        entries.removeAll { $0.id == entryID }
        selectedMoment = nil
        deleteEntryFromFirestore(entryID)

        let currentEntries = entries

        Task {
            await NotificationManager.shared.refreshTonightNotification(
                reason: onboardingReason,
                thinkerType: onboardingThinkerType,
                need: onboardingNeed,
                entries: currentEntries
            )
        }
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
    
    private func refreshDynamicNotifications() {
        let currentEntries = entries

        Task {
            await NotificationManager.shared
                .refreshTonightNotification(
                    reason: UserDefaults.standard.string(
                        forKey: "notification_reason"
                    ),
                    thinkerType: UserDefaults.standard.string(
                        forKey: "notification_thinker_type"
                    ),
                    need: UserDefaults.standard.string(
                        forKey: "notification_need"
                    ),
                    entries: currentEntries
                )
        }
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
        guard let collection = userEntriesCollection() else {
            return
        }

        do {
            let data = try JSONEncoder().encode(entry)

            let json = try JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any] ?? [:]

            collection
                .document(entry.id.uuidString)
                .setData(json) { error in
                    #if DEBUG
                    if let error {
                        print(
                            "Firestore save error:",
                            error.localizedDescription
                        )
                    }
                    #endif
                }

        } catch {
            #if DEBUG
            print(
                "Encode entry error:",
                error.localizedDescription
            )
            #endif
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
                    #if DEBUG
                    print(
                        "Firestore load error:",
                        error.localizedDescription
                    )
                    #endif

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
                            #if DEBUG
                            print(
                                "Decode entry error:",
                                error.localizedDescription
                            )
                            #endif

                            return nil
                        }
                    }

                    self.entries = decodedEntries

                    await NotificationManager.shared.refreshTonightNotification(
                        reason: self.onboardingReason,
                        thinkerType: self.onboardingThinkerType,
                        need: self.onboardingNeed,
                        entries: decodedEntries
                    )
                }
            }
    }

    private func deleteEntryFromFirestore(_ entryID: UUID) {
        guard let collection = userEntriesCollection() else {
            return
        }

        collection
            .document(entryID.uuidString)
            .delete { error in
                #if DEBUG
                if let error {
                    print(
                        "Firestore delete error:",
                        error.localizedDescription
                    )
                }
                #endif
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
            #if DEBUG
            print("PERSONALIZATION: no Firebase user")
            #endif

            return
        }

        #if DEBUG
        print("PERSONALIZATION USER UID:", user.uid)
        #endif

        do {
            let snapshot = try await db
                .collection("users")
                .document(user.uid)
                .getDocument()

            guard
                let data = snapshot.data()?["personalization"] as? [String: Any]
            else {
                #if DEBUG
                print("PERSONALIZATION: document has no personalization field")
                #endif

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

            #if DEBUG
            print("PERSONALIZATION LOADED")
            #endif

        } catch {
            #if DEBUG
            print(
                "LOAD ONBOARDING ERROR:",
                error.localizedDescription
            )
            #endif
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

        #if DEBUG
        print("ONBOARDING ANSWERS SAVED LOCALLY")
        #endif
    }

    func saveCurrentOnboardingAnswersForLoggedInUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            #if DEBUG
            print("PERSONALIZATION SAVE: no logged-in user")
            #endif

            return
        }

        let hasAnswers =
            !onboardingReason.isEmpty ||
            !onboardingTime.isEmpty ||
            !onboardingThinkerType.isEmpty ||
            !onboardingNeed.isEmpty

        guard hasAnswers else {
            #if DEBUG
            print("PERSONALIZATION SAVE: no answers available")
            #endif

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

            #if DEBUG
            print("PERSONALIZATION SAVED TO FIRESTORE")
            #endif

        } catch {
            #if DEBUG
            print(
                "PERSONALIZATION SAVE ERROR:",
                error.localizedDescription
            )
            #endif
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
}
