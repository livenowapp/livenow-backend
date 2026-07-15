//
//  NotificationsScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 15. 7. 2026.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsScreen: View {
    let orange: Color

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var authorizationStatus:
        UNAuthorizationStatus = .notDetermined

    @ScaledMetric private var cardRadius: CGFloat = 24

    private let backgroundColor =
        Color(red: 0.97, green: 0.96, blue: 0.94)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        statusSection
                        scheduleSection
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 28)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadAuthorizationStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await loadAuthorizationStatus()
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundColor(.black.opacity(0.75))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Notifications")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
    }

    private var statusSection: some View {
        settingsGroup(title: "NOTIFICATION ACCESS") {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 24))
                        .foregroundColor(statusColor)
                        .frame(width: 42)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusTitle)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black)

                        Text(statusSubtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }

                    Spacer()
                }

                Button {
                    openNotificationSettings()
                } label: {
                    Text(settingsButtonTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(orange)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
        }
    }

    private var scheduleSection: some View {
        settingsGroup(title: "DAILY REMINDERS") {
            VStack(alignment: .leading, spacing: 18) {
                reminderRow(
                    icon: "sun.max",
                    title: "Morning",
                    time: "9:30 AM"
                )

                Divider()

                reminderRow(
                    icon: "sun.haze",
                    title: "Afternoon",
                    time: "3:00 PM"
                )

                Divider()

                reminderRow(
                    icon: "moon.stars",
                    title: "Evening",
                    time: "8:30 PM"
                )

                Text(
                    "Reminder messages are personalized using your onboarding answers."
                )
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
    }

    private func reminderRow(
        icon: String,
        title: String,
        time: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(orange)
                .frame(width: 42)

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)

            Spacer()

            Text(time)
                .font(.system(size: 15))
                .foregroundColor(.gray)
        }
    }

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            content()
                .background(Color.white.opacity(0.72))
                .cornerRadius(cardRadius)
        }
    }

    private var statusTitle: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Notifications are on"

        case .denied:
            return "Notifications are off"

        case .notDetermined:
            return "Notifications not enabled"

        @unknown default:
            return "Notification status unavailable"
        }
    }

    private var statusSubtitle: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "LiveNow can send your personalized daily reminders."

        case .denied:
            return "Turn notifications on in Settings to receive reminders."

        case .notDetermined:
            return "Enable notifications to receive personalized reminders."

        @unknown default:
            return "Open Settings to review your notification preferences."
        }
    }

    private var statusIcon: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "bell.fill"

        case .denied:
            return "bell.slash.fill"

        default:
            return "bell"
        }
    }

    private var statusColor: Color {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .green

        case .denied:
            return .red

        default:
            return orange
        }
    }

    private var settingsButtonTitle: String {
        authorizationStatus == .authorized
            ? "Open notification settings"
            : "Manage notification access"
    }

    private func loadAuthorizationStatus() async {
        let status =
            await NotificationManager.shared.authorizationStatus()

        await MainActor.run {
            authorizationStatus = status
        }
    }

    private func openNotificationSettings() {
        guard let url = URL(
            string: UIApplication
                .openNotificationSettingsURLString
        ) else {
            return
        }

        UIApplication.shared.open(url)
    }
}
