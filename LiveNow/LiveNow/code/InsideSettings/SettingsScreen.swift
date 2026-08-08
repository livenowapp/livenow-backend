//
//  Settings.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 16. 5. 2026.
//

import SwiftUI
import FirebaseAuth

// MARK: - SETTINGS

struct SettingsScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color
    let isGuestUser: Bool
    
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteAlert = false
    @State private var deleteError: String?
    
    @ScaledMetric private var cardRadius: CGFloat = 24

    private let privacyURL = URL(string: "https://www.livenowapp.net/privacy")!
    private let termsURL = URL(string: "https://www.livenowapp.net/terms")!
    private let faqURL = URL(string: "https://www.livenowapp.net/help")!
    private let subscriptionURL = URL(string:
        "https://apps.apple.com/account/subscriptions")!

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let horizontalPadding = min(geo.size.width * 0.055, 24)
                let topPadding = min(geo.size.height * 0.025, 18)

                ZStack {
                    Color(red: 0.97, green: 0.96, blue: 0.94)
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        header(horizontalPadding: horizontalPadding, topPadding: topPadding)

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 28) {
                                if !isGuestUser {
                                    accountSection
                                    subscriptionSection
                                    preferencesSection
                                }

                                supportSection
                                legalSection

                                if !isGuestUser {
                                    logoutButton
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.top, 28)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
        }
        .alert("Delete account?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                authVM.deleteAccount { error in
                    deleteError = error
                }
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )
        ) {
            Button("OK") { }
        } message: {
            Text(deleteError ?? "")
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }

    private func header(horizontalPadding: CGFloat, topPadding: CGFloat) -> some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black.opacity(0.75))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }

    private var accountSection: some View {
        settingsGroup(title: "ACCOUNT") {
            NavigationLink {
                AccountInfoScreen(authVM: authVM, orange: orange)
            } label: {
                settingsRow(
                    icon: "person",
                    title: "Account info",
                    subtitle: "View and update your information"
                )
            }
            .buttonStyle(.plain)

            sectionDivider

            NavigationLink {
                ChangePasswordScreen(authVM: authVM, orange: orange)
            } label: {
                settingsRow(
                    icon: "lock",
                    title: "Change password",
                    subtitle: "Update your password"
                )
            }
            .buttonStyle(.plain)

            sectionDivider

            Button {
                showDeleteAlert = true
            } label: {
                settingsRow(
                    icon: "trash",
                    title: "Delete account",
                    subtitle: "Permanently delete your account",
                    isDestructive: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var subscriptionSection: some View {
        settingsGroup(title: "SUBSCRIPTION") {
            Link(destination: subscriptionURL) {
                settingsRow(
                    icon: "creditcard",
                    title: "Manage subscription",
                    subtitle: "View, change, or cancel your plan"
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var preferencesSection: some View {
        settingsGroup(title: "PREFERENCES") {
            NavigationLink {
                NotificationSettingsScreen(orange: orange)
            } label: {
                settingsRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Manage reminders and permissions"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var supportSection: some View {
        settingsGroup(title: "SUPPORT") {
            Link(destination: faqURL) {
                settingsRow(
                    icon: "questionmark.circle",
                    title: "Help & FAQ",
                    subtitle: "Get help and find answers"
                )
            }
            .buttonStyle(.plain)

            sectionDivider

            NavigationLink {
                ContactScreen(orange: orange)
            } label: {
                settingsRow(
                    icon: "envelope",
                    title: "Contact us",
                    subtitle: "We’d love to hear from you"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var legalSection: some View {
        settingsGroup(title: "LEGAL") {
            Link(destination: privacyURL) {
                settingsRow(
                    icon: "lock.shield",
                    title: "Privacy Policy",
                    subtitle: "How we protect your data"
                )
            }
            .buttonStyle(.plain)

            sectionDivider

            Link(destination: termsURL) {
                settingsRow(
                    icon: "doc.text",
                    title: "Terms of Use",
                    subtitle: "Read our terms and conditions"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var logoutButton: some View {
        Button(action: {
            authVM.logout()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 22))

                Text("Log out")
                    .font(.system(size: 18, weight: .medium))
            }
            .foregroundColor(orange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(Color.white.opacity(0.72))
            .cornerRadius(cardRadius)
        }
        .buttonStyle(.plain)
    }

    private var sectionDivider: some View {
        Divider().padding(.leading, 76)
    }

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white.opacity(0.72))
            .cornerRadius(cardRadius)
        }
    }

    private func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        isDestructive: Bool = false
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundColor(isDestructive ? .red : .gray)
                .frame(width: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isDestructive ? .red : .black)

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
        .padding(.vertical, 20)
        .contentShape(Rectangle())
    }
}
