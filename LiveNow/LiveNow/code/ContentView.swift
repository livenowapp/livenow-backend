//
//  ContentView.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 23. 4. 2026.
//

import SwiftUI
import FirebaseAuth

// MARK: - ROOT

struct ContentView:
    View {
    
    @StateObject private var vm = AppViewModel()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false
    @AppStorage("lastNotificationScheduleRefresh")
    private var lastNotificationScheduleRefresh: Double = 0
    
    @State private var paywallFromAlreadySubscribed = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var showLoginAfterLogout = false
    @State private var didCheckPremiumStatus = false
    @State private var lastWelcomeShown = Date.distantPast
    @State private var welcomeHideTask: Task<Void, Never>?
    @State private var backgroundDate: Date?
    @State private var isCheckingPremiumStatus = false
    @State private var didPrepareCheckInsThisSession = false
    
    private let bgColor = Color(red: 0.97, green: 0.96, blue: 0.94)
    private let orange = Color(red: 1.0, green: 0.43, blue: 0.10)
    private let lightOrange = Color(red: 1.0, green: 0.66, blue: 0.32)
    private let welcomeBackgroundDelay: TimeInterval = 600
    
    var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()

            Group {
                if authVM.isCheckingAuthentication {
                    bgColor
                        .ignoresSafeArea()
                }
                else if !hasSeenOnboarding {
                    OnboardingScreen(
                        orange: orange,
                        lightOrange: lightOrange,
                        onGetStarted: { answers in
                            hasSeenOnboarding = true
                            vm.saveOnboardingAnswers(answers)
                            vm.goToInput()
                        },
                        onAlreadySubscribed: {
                            Task {
                                await refreshPremiumStatus(showWelcome: false)

                                if purchaseManager.isPremium {
                                    hasSeenOnboarding = true
                                    authVM.showSignup = false
                                } else {
                                    paywallFromAlreadySubscribed = true
                                    vm.showPaywall = true
                                }
                            }
                        }
                    )

                } else if authVM.isLoggedIn && !didCheckPremiumStatus {
                    bgColor
                        .ignoresSafeArea()

                } else if showLoginAfterLogout {
                    authFlow

                } else if purchaseManager.isPremium &&
                          !authVM.isLoggedIn {

                    authFlow

                } else if purchaseManager.isPremium &&
                          authVM.isLoggedIn {

                    if vm.showWelcomeBack {
                        WelcomeBackScreen(
                            name: authVM.displayName,
                            orange: orange,
                            lightOrange: lightOrange
                        )
                        .transition(.opacity)

                    } else {
                        mainAppContent
                            .transition(.opacity)
                            .onAppear {
                                vm.reloadEntriesForCurrentUser()
                            }
                    }

                } else {
                    mainAppContent
                        .onAppear {
                            if vm.isGuestUser &&
                                !vm.hasCompletedGuestReset &&
                                vm.step == .home {

                                vm.goToInput()
                            }
                        }
                }
            }

            if shouldShowResetCheckIn,
               let entry = vm.pendingCheckInEntries.first {

                ResetCheckInOverlay(
                    entry: entry,
                    remainingCount: vm.pendingCheckInEntries.count,
                    orange: orange,
                    onNotWorthIt: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.answerPendingCheckIn(
                                entryID: entry.id,
                                outcome: .no
                            )
                        }
                    },
                    onMaybe: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.answerPendingCheckIn(
                                entryID: entry.id,
                                outcome: .maybe
                            )
                        }
                    },
                    onWorthIt: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.answerPendingCheckIn(
                                entryID: entry.id,
                                outcome: .yes
                            )
                        }
                    },
                    onSkip: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.skipPendingCheckIn(
                                entryID: entry.id
                            )
                        }
                    },
                    onSkipAll: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.skipAllPendingCheckIns()
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(20)
            }
        }
        
        .task {
            await setupNotificationsIfNeeded()

            if !hasSeenOnboarding && authVM.isLoggedIn {
                authVM.logout()
                showLoginAfterLogout = false
                didCheckPremiumStatus = true
                vm.resetToHome()
                return
            }

            await refreshPremiumStatus(showWelcome: true)
        }
        
        .onChange(of: authVM.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                showLoginAfterLogout = false
                didCheckPremiumStatus = false

                vm.migrateGuestFirstResetToFirestoreIfNeeded()
                vm.resetToHome()

                guard let user = Auth.auth().currentUser else {
                    #if DEBUG
                    print("LOGIN LOAD: Firebase user is missing")
                    #endif

                    return
                }

                user.getIDTokenForcingRefresh(true) { token, error in
                    if let error {
                        #if DEBUG
                        print(
                            "LOGIN TOKEN REFRESH ERROR:",
                            error.localizedDescription
                        )
                        #endif

                        return
                    }

                    #if DEBUG
                    print("LOGIN LOAD UID:", user.uid)
                    print("LOGIN LOAD: Auth token refreshed")
                    #endif

                    Task {
                        if vm.hasOnboardingAnswers {
                            await vm.saveCurrentOnboardingAnswersForLoggedInUser()
                        }

                        await vm.loadOnboardingAnswersAsync()

                        vm.reloadEntriesForCurrentUser()

                        await refreshPremiumStatus(
                            showWelcome: false
                        )
                    }
                }

            } else if authVM.hasAuthenticatedBefore &&
                      !authVM.needsEmailVerification {

                showLoginAfterLogout = true
                authVM.showSignup = false
                vm.resetToHome()
            }
        }
        
        .onChange(of: vm.entries) { _, _ in
            prepareCheckInsIfPossible()
        }
        
        .onChange(of: vm.showWelcomeBack) { _, isShowing in
            guard !isShowing else {
                return
            }

            prepareCheckInsIfPossible()
        }
        
        .onChange(of: authVM.isCheckingAuthentication) { _, isChecking in
            guard !isChecking else { return }
            guard authVM.isLoggedIn else { return }

            Task {
                await refreshPremiumStatus(showWelcome: true)
            }
        }
        
        .sheet(isPresented: $vm.showPaywall) {
            PaywallScreen(
                orange: orange,
                lightOrange: lightOrange,
                onSubscribe: { plan in
                    Task {
                        await purchaseManager.purchase(plan: plan)
                        await refreshPremiumStatus()

                        if purchaseManager.isPremium {
                            vm.showPaywall = false

                            if paywallFromAlreadySubscribed {
                                hasSeenOnboarding = true
                                authVM.showSignup = false
                                paywallFromAlreadySubscribed = false
                            }
                        }
                    }
                },
                onRestore: {
                    Task {
                        await purchaseManager.restore()
                        await refreshPremiumStatus()

                        if purchaseManager.isPremium {
                            vm.showPaywall = false

                            if paywallFromAlreadySubscribed {
                                hasSeenOnboarding = true
                                authVM.showSignup = false
                                paywallFromAlreadySubscribed = false
                            }
                        }
                    }
                },
                onClose: {
                    vm.showPaywall = false
                    paywallFromAlreadySubscribed = false
                }
            )
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {

            case .background:
                backgroundDate = Date()
                didPrepareCheckInsThisSession = false

            case .active:
                if let backgroundDate,
                   Date().timeIntervalSince(backgroundDate) >
                    welcomeBackgroundDelay {

                    self.backgroundDate = nil
                    vm.resetToHome()

                    Task {
                        await refreshPremiumStatus(
                            showWelcome: true
                        )
                    }
                }

            default:
                break
            }
        }
        .animation(
            .easeInOut(duration: 0.55),
            value: vm.showWelcomeBack
        )
    }
    
    @ViewBuilder
    private var authFlow: some View {
        if authVM.needsEmailVerification {
            EmailVerificationScreen(
                authVM: authVM,
                orange: orange
            )

        } else if authVM.showSignup {
            SignupScreen(
                authVM: authVM,
                orange: orange
            )

        } else {
            LoginScreen(
                authVM: authVM,
                orange: orange
            )
        }
    }
    
    @MainActor
    private func refreshPremiumStatus(
        showWelcome: Bool = false
    ) async {
        guard !isCheckingPremiumStatus else {
            return
        }

        isCheckingPremiumStatus = true
        defer {
            isCheckingPremiumStatus = false
        }

        await purchaseManager.checkPremiumStatus()

        didCheckPremiumStatus = true

        if showWelcome {
            showWelcomeBackIfNeeded()
        }
    }
    
    @MainActor
    private func prepareCheckInsIfPossible() {
        guard !didPrepareCheckInsThisSession else {
            return
        }

        guard hasSeenOnboarding else {
            return
        }

        guard authVM.isLoggedIn else {
            return
        }

        guard purchaseManager.isPremium else {
            return
        }

        guard didCheckPremiumStatus else {
            return
        }

        guard !vm.showWelcomeBack else {
            return
        }

        guard !vm.showPaywall else {
            return
        }

        guard vm.step == .home else {
            return
        }

        guard vm.currentTab == .home else {
            return
        }

        didPrepareCheckInsThisSession = true

        Task {
            try? await Task.sleep(
                nanoseconds: 600_000_000
            )

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.35)) {
                    vm.preparePendingCheckIns()
                }
            }
        }
    }
        
    private func showWelcomeBackIfNeeded() {
        guard authVM.isLoggedIn && purchaseManager.isPremium else { return }

        let now = Date()
        guard now.timeIntervalSince(lastWelcomeShown) > 2 else { return }

        lastWelcomeShown = now
        welcomeHideTask?.cancel()

        withAnimation(.easeInOut(duration: 0.2)) {
            vm.refreshHomeMessage()
            vm.showWelcomeBack = true
        }

        welcomeHideTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.55)) {
                    vm.showWelcomeBack = false
                }
            }
        }
    }
    
    @MainActor
    private func setupNotificationsIfNeeded() async {
        let status =
            await NotificationManager.shared.authorizationStatus()

        switch status {

        case .notDetermined:
            await NotificationManager.shared.configureNotifications(
                reason: vm.onboardingReason,
                thinkerType: vm.onboardingThinkerType,
                need: vm.onboardingNeed,
                entries: vm.entries
            )

            let newStatus =
                await NotificationManager.shared.authorizationStatus()

            if newStatus == .authorized ||
               newStatus == .provisional ||
               newStatus == .ephemeral {

                lastNotificationScheduleRefresh =
                    Date().timeIntervalSince1970
            }

        case .authorized,
             .provisional,
             .ephemeral:

            await refreshNotificationScheduleIfNeeded()

        case .denied:
            break

        @unknown default:
            break
        }
    }
    
    private func refreshNotificationScheduleIfNeeded() async {
        let refreshInterval: TimeInterval =
            7 * 24 * 60 * 60

        let lastRefreshDate = Date(
            timeIntervalSince1970:
                lastNotificationScheduleRefresh
        )

        guard Date().timeIntervalSince(lastRefreshDate) >= refreshInterval else {
            return
        }

        await NotificationManager.shared.configureNotifications(
            reason: vm.onboardingReason,
            thinkerType: vm.onboardingThinkerType,
            need: vm.onboardingNeed,
            entries: vm.entries
        )

        let status =
            await NotificationManager.shared
                .authorizationStatus()

        guard status == .authorized ||
              status == .provisional ||
              status == .ephemeral
        else {
            return
        }

        await MainActor.run {
            lastNotificationScheduleRefresh =
                Date().timeIntervalSince1970
        }
    }
    
    private var shouldShowResetCheckIn: Bool {
        vm.showResetCheckIn &&
        authVM.isLoggedIn &&
        purchaseManager.isPremium &&
        !vm.showWelcomeBack &&
        vm.step == .home &&
        vm.currentTab == .home &&
        !vm.showPaywall
    }
    
    @ViewBuilder
    private var mainAppContent: some View {
        mainScreen
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if shouldShowTabBar {
                    BottomTabBar(
                        vm: vm,
                        orange: orange,
                    )
                }
            }
    }

    private var shouldShowTabBar: Bool {
        vm.step == .home
    }

    @ViewBuilder
    private var mainScreen: some View {
        if vm.currentTab == .home {
            homeFlow
        } else if vm.currentTab == .moments {
            MomentsScreen(
                vm: vm,
                orange: orange,
                lightOrange: lightOrange
            )
        } else if vm.currentTab == .insights {
            InsightsScreen(
                vm: vm,
                orange: orange
            )
        } else {
            ProfilePlaceholderScreen(authVM: authVM, vm: vm)
        }
    }
    
    @ViewBuilder
    private var homeFlow: some View {
        switch vm.step {
            
        case .home:
            HomeScreen(
                vm: vm,
                orange: orange,
                lightOrange: lightOrange
            ) {
                vm.goToInput()
            }
            
        case .input:
            InputScreen(
                vm: vm,
                orange: orange,
                onBack: { vm.goBack() },
                onAnalyze: {
                    Task {
                        await vm.analyze()
                    }
                }
            )
            
        case .thinking:
            ThinkingScreen(
                orange: orange,
                onBack: {
                    vm.goBack()
                },
                vm: vm
            )
            
        case .analyze:
            AnalyzeScreen(
                vm: vm,
                orange: orange,
                onBack: { vm.goBack() },
                onContinue: { vm.goNext() }
            )
            
        case .reframe:
            ReframeScreen(
                vm: vm,
                orange: orange,
                onBack: { vm.goBack() },
                onContinue: { vm.goNext() }
            )
            
        case .action:
            ActionScreen(
                vm: vm,
                orange: orange,
                onBack: { vm.goBack() },
                onFinish: { vm.goNext() }
            )
            
        case .complete:
            CompleteScreen(
                vm: vm,
                orange: orange,
                lightOrange: lightOrange,
                onClose: { vm.resetToHome() },
                onNewReset: { vm.goToInput() }
            )
        }
    }
}
  
