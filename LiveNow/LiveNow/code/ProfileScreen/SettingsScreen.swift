//
//  Settings.swift
//  LiveNow
//
//  Created by Maja on 16. 5. 2026.
//

import SwiftUI
import FirebaseAuth

// MARK: - SETTINGS

struct SettingsScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.025, 18)

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24, weight: .regular))
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

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        accountSection

                        settingsSection(
                            title: "PREFERENCES",
                            rows: [
                                ("bell", "Notifications / Reminders", "Choose when and how we remind you", false)
                            ]
                        )

                        supportSection

                        settingsSection(
                            title: "LEGAL",
                            rows: [
                                ("shield", "Privacy Policy", "How we protect your data", false),
                                ("doc.text", "Terms of Use", "Read our terms and conditions", false)
                            ]
                        )

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
                            .cornerRadius(22)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 28)
                    .padding(.bottom, 24)
                }
            }
        }
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ACCOUNT")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            VStack(spacing: 0) {
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

                Divider().padding(.leading, 76)

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

                Divider().padding(.leading, 76)

                Button(action: {}) {
                    settingsRow(
                        icon: "trash",
                        title: "Delete account",
                        subtitle: "Permanently delete your account",
                        isDestructive: true
                    )
                }
                .buttonStyle(.plain)
            }
            .background(Color.white.opacity(0.72))
            .cornerRadius(22)
        }
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SUPPORT")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                Button(action: {
                    // Help & FAQ kasneje
                }) {
                    settingsRow(
                        icon: "questionmark.circle",
                        title: "Help & FAQ",
                        subtitle: "Get help and find answers"
                    )
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 76)

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
            .background(Color.white.opacity(0.72))
            .cornerRadius(22)
        }
    }

    private func settingsSection(
        title: String,
        rows: [(String, String, String, Bool)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    Button(action: {}) {
                        settingsRow(
                            icon: row.0,
                            title: row.1,
                            subtitle: row.2,
                            isDestructive: row.3
                        )
                    }
                    .buttonStyle(.plain)

                    if rowIndex < rows.count - 1 {
                        Divider().padding(.leading, 76)
                    }
                }
            }
            .background(Color.white.opacity(0.72))
            .cornerRadius(22)
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
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray.opacity(0.9))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .contentShape(Rectangle())
    }
}
