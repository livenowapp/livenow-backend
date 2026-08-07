//
//  ProfileScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 13. 5. 2026.
//

import SwiftUI
import StoreKit
import FirebaseAuth

// MARK: - PROFILE SCREEN

struct ProfilePlaceholderScreen: View {
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var vm: AppViewModel

    private let orange = Color(red: 1.0, green: 0.43, blue: 0.10)

    let isSmall = UIScreen.main.bounds.width < 380
    
    private let calmMessages = [
        "Focus on what matters.",
        "Come back to the present.",
        "One moment at a time.",
        "Small resets matter.",
        "You are not your thoughts.",
        "Breathe before you react.",
        "Let this moment be enough.",
        "Slow down your mind.",
        "Choose presence over pressure.",
        "You can pause first.",
        "Notice the thought, then let it pass.",
        "You don’t need to solve everything now.",
        "Return to what is real.",
        "A calm mind starts with one breath.",
        "You are safe in this moment.",
        "Progress can be quiet.",
        "Less reacting. More noticing.",
        "You can begin again.",
        "Stay with what you know.",
        "Let the noise settle.",
        "You are allowed to slow down.",
        "This thought is not the whole story.",
        "Clarity comes after the pause.",
        "Be where your feet are.",
        "You have time to respond.",
        "Not every thought needs action.",
        "Come back to now.",
        "One clear step is enough.",
        "You can trust the next breath.",
        "Keep choosing the present.",
        "Let today be simple.",
        "Pause. Breathe. Continue.",
        "A reset is still progress.",
        "You are doing better than you think.",
        "Return to the moment in front of you."
    ]

    private var dailyCalmMessage: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return calmMessages[day % calmMessages.count]
    }

    @ScaledMetric private var nameSize: CGFloat = 34
    @ScaledMetric private var titleSize: CGFloat = 34
    @ScaledMetric private var cardRadius: CGFloat = 22

    @State private var showSettings = false
    
    var body: some View {
        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let horizontalPadding = min(screenWidth * 0.055, 24)
            let contentTopPadding = min(screenHeight * 0.025, 22)

            let cardSpacing = min(max(screenHeight * 0.022, 16), 22)
            let cardPadding = min(max(screenWidth * 0.052, 18), 24)

            VStack(spacing: 0) {
                
                LiveNowTopHeader(
                    horizontalPadding: horizontalPadding
                )
                
                ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {

                    Text(
                        vm.isGuestUser
                        ? "Hey, friend"
                        : (
                            authVM.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? "Hey, friend"
                            : "Hey, \(authVM.displayName)"
                        )
                    )
                    .font(.system(size: nameSize, weight: .bold))
                    .foregroundColor(.black)

                    Text(dailyCalmMessage)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, contentTopPadding)

                    VStack(spacing: 18) {
                        if vm.isGuestUser {
                            guestProgressCard(
                                cardPadding: cardPadding,
                                cardSpacing: cardSpacing
                                )
                        } else {
                            progressCard(
                                cardPadding: cardPadding,
                                cardSpacing: cardSpacing
                                )
                        }
                        menuCard
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, min(max(screenHeight * 0.026, 18), 24))
                    .padding(.bottom, 24)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsScreen(
                    authVM: authVM,
                    orange: orange,
                    isGuestUser: vm.isGuestUser
                )
            }
               
        }
    }
    
// MARK: - GUEST CARD
    private func guestProgressCard(
        cardPadding: CGFloat,
        cardSpacing: CGFloat
    ) -> some View {
        
        VStack(alignment: .leading, spacing: cardSpacing) {

            Button {
                authVM.showSignup = true
                vm.requestPremiumAccess()
            } label: {
                Text("Create account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(orange)
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)

            Button {
                authVM.showSignup = false
                vm.requestPremiumAccess()
            } label: {
                Text("I already have an account")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(orange)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            if vm.hasCompletedGuestReset {
                Text("Your first reset will be saved after you create an account.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }
    
// MARK: - PROGRESS CARD
    
    private func progressCard(
        cardPadding: CGFloat,
        cardSpacing: CGFloat
    ) -> some View {
        
        VStack(alignment: .leading, spacing: cardSpacing) {
            Text("This month progress")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 1) {
                progressCircle
                    .frame(width: 120)
                
                Divider()
                    .padding(.vertical, 8)
                
                statItem(
                    icon: "arrow.clockwise",
                    value: "\(vm.thisMonthNotWorthItCount)",
                    title: "worries released"
                )
                
                Divider()
                    .padding(.vertical, 8)
                
                statItem(
                    icon: "star",
                    value: "\(vm.thisMonthActiveDaysCount)",
                    title: "active days"
                )
                
                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, isSmall ? 1 : 0)
                
                statItem(
                    icon: "sparkles",
                    value: "\(vm.thisMonthEntries.count)",
                    title: "moments"
                )
            }
            .frame(height: 130)
        }
        .padding(cardPadding)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

// MARK: - PROGRESS CIRCLE
    
    private var progressCircle: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(orange.opacity(0.16), lineWidth: 8)
                    .frame(width: 96, height: 96)

                Circle()
                    .trim(from: 0, to: CGFloat(vm.thisMonthNotWorthItPercent) / 100)
                    .stroke(
                        orange,
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        )
                    )
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(-90))

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(vm.thisMonthNotWorthItPercent)")
                        .font(.system(size: 31, weight: .bold))
                        .foregroundColor(.black)

                    Text("%")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                }
            }

            VStack(spacing: 1) {
                Text("not worth")
                Text("overthinking")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

// MARK: - STATISTIC
    
    private func statItem(icon: String, value: String, title: String) -> some View {
        
        VStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 25, weight: .regular))
                .foregroundColor(orange)
                .frame(height: 30)

            Text(value)
                .font(.system(size: isSmall ? 22 : 26, weight: .bold))
                .foregroundColor(.black)
                .frame(height: 36)

            VStack(spacing: 1) {
                if title == "active days" {
                    Text("active")
                    Text("days")
                } else if title == "worries released" {
                    Text("worries")
                    Text("released")
                } else {
                    Text(title)
                    Text(" ")
                        .hidden()
                }
            }
            .font(.system(size: isSmall ? 11 : 13, weight: .medium))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .frame(height: 34)
        }
        .frame(maxWidth: .infinity)
    }

// MARK: - MENU CARD
    
    private var menuCard: some View {
        VStack(spacing: 0) {
            Button {
                showSettings = true
            } label: {
                menuRow(
                    icon: "gearshape",
                    title: "Settings",
                    subtitle: vm.isGuestUser
                        ? "Help, privacy and legal information"
                        : "Manage your account and app"
                )
            }
            .buttonStyle(.plain)

            if !vm.isGuestUser {
                Divider()
                    .padding(.leading, 74)

                Button {
                    requestReview()
                } label: {
                    menuRow(
                        icon: "star",
                        title: "Rate LiveNow",
                        subtitle: "If LiveNow helps you, leave a review"
                    )
                }
                .buttonStyle(.plain)
            }

            Divider()
                .padding(.leading, 74)

            ShareLink(item: "Check out LiveNow") {
                menuRow(
                    icon: "square.and.arrow.up",
                    title: "Share LiveNow",
                    subtitle: "Help others live more in the now"
                )
            }
            .buttonStyle(.plain)
        }
        .background(Color.white.opacity(0.75))
        .cornerRadius(cardRadius)
    }

    
    private func menuRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(orange)
                .frame(width: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.gray)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
}
