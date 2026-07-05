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
    
    @State private var paywallFromAlreadySubscribed = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var showLoginAfterLogout = false
    @State private var didCheckPremiumStatus = false
    @State private var lastWelcomeShown = Date.distantPast
    @State private var welcomeHideTask: Task<Void, Never>?
    @State private var backgroundDate: Date?
    
    private let bgColor = Color(red: 0.97, green: 0.96, blue: 0.94)
    private let orange = Color(red: 1.0, green: 0.43, blue: 0.10)
    private let lightOrange = Color(red: 1.0, green: 0.66, blue: 0.32)
    private let welcomeBackgroundDelay: TimeInterval = 300
    
    var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()

            if !hasSeenOnboarding {
                OnboardingScreen(
                    orange: orange,
                    lightOrange: lightOrange,
                    onGetStarted: {
                        hasSeenOnboarding = true
                        vm.goToInput()
                    },
                    onAlreadySubscribed: {
                        Task {
                            await purchaseManager.checkPremiumStatus()

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

            refreshPremiumStatus(showWelcome: true)
        }
        .onChange(of: authVM.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                showLoginAfterLogout = false
                didCheckPremiumStatus = false
                vm.migrateGuestFirstResetToFirestoreIfNeeded()
                vm.resetToHome()

                refreshPremiumStatus(showWelcome: false)

            } else {
                if authVM.hasAuthenticatedBefore {
                    showLoginAfterLogout = true
                    authVM.showSignup = false
                    vm.resetToHome()
                }
            }
        }
        .sheet(isPresented: $vm.showPaywall) {
            PaywallScreen(
                orange: orange,
                lightOrange: lightOrange,
                onSubscribe: { plan in
                    Task {
                        await purchaseManager.purchase(plan: plan)
                        await purchaseManager.checkPremiumStatus()

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
                        await purchaseManager.checkPremiumStatus()

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

                    Task {
                        refreshPremiumStatus(showWelcome: true)
                    }
                }

            default:
                break
            }
        }
        .animation(.easeInOut(duration: 0.55), value: vm.showWelcomeBack)
    }
    
    private func refreshPremiumStatus(showWelcome: Bool = false) {
        Task {
            await purchaseManager.checkPremiumStatus()
            didCheckPremiumStatus = true

            if showWelcome {
                showWelcomeBackIfNeeded()
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
        
    @ViewBuilder
    private var mainAppContent: some View {
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
            HomeScreen( vm: vm, orange: orange, lightOrange: lightOrange) {
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
  
