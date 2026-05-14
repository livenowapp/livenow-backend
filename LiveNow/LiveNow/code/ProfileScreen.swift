//
//  ProfileScreen.swift
//  LiveNow
//
//  Created by Maja on 13. 5. 2026.
//

import SwiftUI
import StoreKit

struct ProfilePlaceholderScreen: View {
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var vm: AppViewModel

    private let orange = Color(red: 1.0, green: 0.43, blue: 0.10)

    @ScaledMetric private var logoSize: CGFloat = 24
    @ScaledMetric private var topButtonSize: CGFloat = 40
    @ScaledMetric private var nameSize: CGFloat = 34

    @State private var showSettings = false
    @State private var showContact = false
    @State private var showShare = false
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let horizontalPadding = min(screenWidth * 0.06, 24)
            let topPadding = min(screenHeight * 0.025, 18)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        HStack {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: topButtonSize, height: topButtonSize)

                            Spacer()

                            Text("LiveNow")
                                .font(.system(size: logoSize, weight: .semibold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Spacer()

                            Circle()
                                .fill(Color.clear)
                                .frame(width: topButtonSize, height: topButtonSize)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, topPadding)
                        
                        HStack(spacing: 18) {
                            Circle()
                                .fill(orange.opacity(0.14))
                                .frame(width: 86, height: 86)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(orange)
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                Text(authVM.displayName)
                                    .font(.system(size: nameSize, weight: .bold))
                                    .foregroundColor(.black)

                                Text("Focus on what matters.\nLive in the now.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                            }

                            Spacer()
                        }

                        progressCard

                        menuCard
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 28)
                }

                BottomTabBar(vm: vm, orange: orange)
                    .sheet(isPresented: $showSettings) {
                        SettingsScreen(authVM: authVM, orange: orange)
                    }
                    .sheet(isPresented: $showContact) {
                        ContactScreen(orange: orange)
                    }
            }
        }
    }

    private var progressCard: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let isSmall = cardWidth < 350
            let circleColumnWidth: CGFloat = isSmall ? 105 : 120
            let cardPadding: CGFloat = isSmall ? 14 : 18
            let statHeight: CGFloat = isSmall ? 128 : 148

            VStack(spacing: isSmall ? 14 : 18) {
                HStack {
                    Text("Your progress")
                        .font(.system(size: isSmall ? 18 : 20, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    HStack(spacing: 5) {
                        Text("View all")
                            .font(.system(size: isSmall ? 14 : 16, weight: .medium))
                            .foregroundColor(orange)

                        Image(systemName: "chevron.right")
                            .font(.system(size: isSmall ? 15 : 18, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }

                HStack(spacing: 0) {
                    progressCircle(cardWidth: cardWidth)
                        .frame(width: circleColumnWidth)

                    Divider().padding(.vertical, 8)

                    statItem(
                        icon: "arrow.clockwise",
                        value: "\(vm.last7DaysEntries.count)",
                        title: "resets",
                        subtitle: "this week",
                        cardWidth: cardWidth
                    )

                    Divider().padding(.vertical, 8)

                    statItem(
                        icon: "leaf",
                        value: "\(vm.activeDaysCount)",
                        title: "active days",
                        subtitle: "this week",
                        cardWidth: cardWidth
                    )

                    Divider().padding(.vertical, 8)

                    statItem(
                        icon: "star",
                        value: "\(vm.entries.count)",
                        title: "moments",
                        subtitle: "saved",
                        cardWidth: cardWidth
                    )
                }
                .frame(height: statHeight)

                HStack(spacing: isSmall ? 10 : 14) {
                    Circle()
                        .fill(orange.opacity(0.12))
                        .frame(width: isSmall ? 42 : 50, height: isSmall ? 42 : 50)
                        .overlay(
                            Image(systemName: "bolt.fill")
                                .font(.system(size: isSmall ? 18 : 22))
                                .foregroundColor(orange)
                        )

                    VStack(alignment: .leading, spacing: 5) {
                        Text("You’ve broken the loop \(vm.last7DaysEntries.count) times this week.")
                            .font(.system(size: isSmall ? 14 : 16, weight: .semibold))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Keep going.")
                            .font(.system(size: isSmall ? 13 : 15))
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal, isSmall ? 12 : 16)
                .padding(.vertical, isSmall ? 13 : 16)
                .background(orange.opacity(0.045))
                .cornerRadius(isSmall ? 16 : 18)
            }
            .padding(cardPadding)
            .background(Color.white.opacity(0.78))
            .cornerRadius(24)
        }
        .frame(height: 310)
    }

    private func progressCircle(cardWidth: CGFloat) -> some View {
        let isSmall = cardWidth < 350
        let circleSize: CGFloat = isSmall ? 78 : 96
        let percentSize: CGFloat = isSmall ? 25 : 31
        let percentSymbolSize: CGFloat = isSmall ? 14 : 17

        return VStack(spacing: isSmall ? 6 : 8) {
            ZStack {
                Circle()
                    .stroke(orange.opacity(0.16), lineWidth: isSmall ? 7 : 8)
                    .frame(width: circleSize, height: circleSize)

                Circle()
                    .trim(from: 0, to: CGFloat(vm.last7DaysDidNotHappenPercent) / 100)
                    .stroke(orange, style: StrokeStyle(lineWidth: isSmall ? 7 : 8, lineCap: .round))
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(vm.last7DaysDidNotHappenPercent)")
                        .font(.system(size: percentSize, weight: .bold))
                        .foregroundColor(.black)

                    Text("%")
                        .font(.system(size: percentSymbolSize, weight: .bold))
                        .foregroundColor(.black)
                }
            }

            VStack(spacing: 1) {
                Text("less")
                Text("overthinking")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .lineLimit(1)

            Text("this week")
                .font(.system(size: isSmall ? 12 : 14))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func statItem(icon: String, value: String, title: String, subtitle: String, cardWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 25, weight: .regular))
                .foregroundColor(orange)
                .frame(height: 30)

            Text(value)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)
                .frame(height: 36)

            VStack(spacing: 1) {
                if title == "active days" {
                    Text("active")
                    Text("days")
                } else {
                    Text(title)
                    Text(" ")
                        .hidden()
                }
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .frame(height: 34)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(height: 18)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var menuCard: some View {
        VStack(spacing: 0) {
            Button {
                showSettings = true
            } label: {
                menuRow(icon: "gearshape", title: "Settings", subtitle: "Manage your account and app", orangeIcon: true)
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 74)

            Button {
                showContact = true
            } label: {
                menuRow(icon: "envelope", title: "Contact us", subtitle: "We’d love to hear from you")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 74)

            Button {
                requestReview()
            } label: {
                menuRow(icon: "star", title: "Rate LiveNow", subtitle: "If LiveNow helps you, leave a review")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 74)

            ShareLink(item: "Check out LiveNow") {
                menuRow(icon: "square.and.arrow.up", title: "Share LiveNow", subtitle: "Help others live more in the now")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 74)

            Button {
                authVM.logout()
            } label: {
                menuRow(icon: "rectangle.portrait.and.arrow.right", title: "Log out", subtitle: "Sign out of your account")
            }
            .buttonStyle(.plain)
        }
        .background(Color.white.opacity(0.75))
        .cornerRadius(22)
    }

    private func menuRow(icon: String, title: String, subtitle: String, orangeIcon: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(orangeIcon ? orange : .gray)
                .frame(width: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
    }
  
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
    
}
struct SettingsScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                Text("Account")
                    .font(.system(size: 24, weight: .bold))

                Text(authVM.email)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(orange)
            }
        }
    }
}

struct ContactScreen: View {
    let orange: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                Text("Contact us")
                    .font(.system(size: 24, weight: .bold))

                Text("livenowapp@outlook.com")
                    .font(.system(size: 16))
                    .foregroundColor(orange)

                Text("Send us feedback, questions, or anything that could help improve LiveNow.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Contact us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(orange)
            }
        }
    }
}
