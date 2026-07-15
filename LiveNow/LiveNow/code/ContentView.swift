//
//  ContentView.swift
//  LiveNow
//
//  Created by Maja on 23. 4. 2026.
//

import SwiftUI
import Combine
import FirebaseAuth

// MARK: - ROOT

struct ContentView:
    View {
    
    @StateObject private var vm = AppViewModel()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("didAskNotificationPermission")
    private var didAskNotificationPermission = false
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
    
    private let bgColor = Color(red: 0.97, green: 0.96, blue: 0.94)
    private let orange = Color(red: 1.0, green: 0.43, blue: 0.10)
    private let lightOrange = Color(red: 1.0, green: 0.66, blue: 0.32)
    private let welcomeBackgroundDelay: TimeInterval = 600
    
    var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()

            if !hasSeenOnboarding {
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
                if authVM.showSignup {
                    SignupScreen(authVM: authVM, orange: orange)
                } else {
                    LoginScreen(authVM: authVM, orange: orange)
                }

            } else if purchaseManager.isPremium && !authVM.isLoggedIn {

                if authVM.showSignup {
                    SignupScreen(authVM: authVM, orange: orange)
                } else {
                    LoginScreen(authVM: authVM, orange: orange)
                }

            } else if purchaseManager.isPremium && authVM.isLoggedIn {

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
                        if vm.isGuestUser && !vm.hasCompletedGuestReset && vm.step == .home {
                            vm.goToInput()
                        }
                    }
            }
        }
        .task {
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
                    print("LOGIN LOAD: Firebase user is missing")
                    return
                }

                user.getIDTokenForcingRefresh(true) { token, error in
                    if let error {
                        print(
                            "LOGIN TOKEN REFRESH ERROR:",
                            error.localizedDescription
                        )
                        return
                    }

                    print("LOGIN LOAD UID:", user.uid)
                    print("LOGIN LOAD: Auth token refreshed")

                                            Task {
                                                if vm.hasOnboardingAnswers {
                                                    await vm
                                                        .saveCurrentOnboardingAnswersForLoggedInUser()
                                                }

                                                await vm.loadOnboardingAnswersAsync()

                                                await refreshNotificationScheduleIfNeeded()

                                                vm.reloadEntriesForCurrentUser()
                                                await refreshPremiumStatus(showWelcome: false)
                                            }
                }

            } else if authVM.hasAuthenticatedBefore {
                showLoginAfterLogout = true
                authVM.showSignup = false
                vm.resetToHome()
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

            case .active:
                if let backgroundDate,
                   Date().timeIntervalSince(backgroundDate) > welcomeBackgroundDelay {

                    self.backgroundDate = nil

                    vm.resetToHome()

                    Task {
                        await refreshPremiumStatus(showWelcome: true)
                    }
                }

            default:
                break
            }
        }
        .animation(.easeInOut(duration: 0.55), value: vm.showWelcomeBack)
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
        
    private func showWelcomeBackIfNeeded() {
        guard authVM.isLoggedIn && purchaseManager.isPremium else { return }

        let now = Date()
        guard now.timeIntervalSince(lastWelcomeShown) > 2 else { return }

        lastWelcomeShown = now
        welcomeHideTask?.cancel()

        withAnimation(.easeInOut(duration: 0.2)) {
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
    
    private func requestNotificationsAfterUserActionIfNeeded() {
        guard authVM.isLoggedIn else { return }
        guard !didAskNotificationPermission else { return }

        let hasPersonalization =
            !vm.onboardingReason.isEmpty ||
            !vm.onboardingThinkerType.isEmpty ||
            !vm.onboardingNeed.isEmpty

        guard hasPersonalization else { return }

        Task {
            await NotificationManager.shared.configureNotifications(
                reason: vm.onboardingReason,
                thinkerType: vm.onboardingThinkerType,
                need: vm.onboardingNeed
            )

            let status =
                await NotificationManager.shared.authorizationStatus()

            await MainActor.run {
                switch status {
                case .authorized,
                     .provisional,
                     .ephemeral,
                     .denied:

                    didAskNotificationPermission = true

                case .notDetermined:
                    // Uporabnik še ni odgovoril.
                    // Ob naslednjem kliku lahko vprašamo ponovno.
                    didAskNotificationPermission = false

                @unknown default:
                    didAskNotificationPermission = false
                }
            }
        }
    }
    
                        private func refreshNotificationScheduleIfNeeded() async {
                            let refreshInterval: TimeInterval =
                                7 * 24 * 60 * 60

                            let lastRefreshDate = Date(
                                timeIntervalSince1970:
                                    lastNotificationScheduleRefresh
                            )

                            guard Date().timeIntervalSince(lastRefreshDate)
                                    >= refreshInterval
                            else {
                                return
                            }

                            await NotificationManager.shared
                                .refreshNotificationsIfAuthorized(
                                    reason: vm.onboardingReason,
                                    thinkerType: vm.onboardingThinkerType,
                                    need: vm.onboardingNeed
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
                        
    @ViewBuilder
    private var mainAppContent: some View {
        mainScreen
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if shouldShowTabBar {
                    BottomTabBar(
                        vm: vm,
                        orange: orange,
                        onTabInteraction: {
                            requestNotificationsAfterUserActionIfNeeded()
                        }
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
  
