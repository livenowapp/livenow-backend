//
//  ContentView.swift
//  LiveNow
//
//  Created by Maja on 23. 4. 2026.
//

import SwiftUI
import Combine

// MARK: - ROOT

struct ContentView: View {
    @StateObject private var vm = AppViewModel()
    @StateObject private var authVM = AuthViewModel()
    
    private let bgColor = Color(red: 0.97, green: 0.96, blue: 0.94)
    private let orange = Color(red: 1.0, green: 0.43, blue: 0.10)
    private let lightOrange = Color(red: 1.0, green: 0.66, blue: 0.32)
    
    var body: some View {
        if authVM.isLoggedIn {
            ZStack {
            bgColor
                .ignoresSafeArea()
            
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
            .sheet(item: $vm.selectedMoment) { moment in
                MomentDetailScreen(
                    vm: vm,
                    entry: moment,
                    orange: orange,
                    lightOrange: lightOrange,
                    onClose: {
                        vm.selectedMoment = nil
                    }
                )
            }
        } else {
            if authVM.showSignup {
                SignupScreen(authVM: authVM, orange: orange)
            } else {
                LoginScreen(authVM: authVM, orange: orange)
                    .onAppear {
                        vm.currentTab = .home
                        vm.step = .home
                    }
            }
        }
    }
    
    @ViewBuilder
    private var homeFlow: some View {
        switch vm.step {
        case .home:
            HomeScreen(
                vm: vm,
                orange: orange,
                lightOrange: lightOrange,
                onStart: {
                    vm.goToInput()
                }
            )
            
        case .input:
            InputScreen(
                vm: vm,
                orange: orange,
                onBack: {
                    vm.goBack()
                },
                onAnalyze: {
                    Task {
                        await vm.analyze()
                    }
                }
            )
            
        case .analyze:
            AnalyzeScreen(
                vm: vm,
                orange: orange,
                onBack: {
                    vm.goBack()
                },
                onContinue: {
                    vm.goNext()
                }
            )
            
        case .reframe:
            ReframeScreen(
                vm: vm,
                orange: orange,
                onBack: {
                    vm.goBack()
                },
                onContinue: {
                    vm.goNext()
                }
            )
            
        case .action:
            ActionScreen(
                vm: vm,
                orange: orange,
                onBack: {
                    vm.goBack()
                },
                onFinish: {
                    vm.goNext()
                }
            )
            
        case .complete:
            CompleteScreen(
                vm: vm,
                orange: orange,
                lightOrange: lightOrange,
                onClose: {
                    vm.resetToHome()
                },
                onNewReset: {
                    vm.goToInput()
                }
            )
        }
    }
}
    
  
