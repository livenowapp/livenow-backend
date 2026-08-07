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
                        notificationAccessSection
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

    // MARK: - HEADER

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
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

    // MARK: - NOTIFICATION ACCESS

    private var notificationAccessSection: some View {
        settingsGroup(title: "NOTIFICATION ACCESS") {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 23, weight: .medium))
                        .foregroundColor(statusColor)
                        .frame(width: 42, height: 42)
                        .background(
                            statusColor.opacity(0.12)
                        )
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 5) {
                        Text(statusTitle)
                            .font(.system(size: 17, weight: .semibold))
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
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(18)
        }
    }

    // MARK: - GROUP

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            content()
                .background(
                    Color.white.opacity(0.72)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: cardRadius,
                        style: .continuous
                    )
                )
        }
    }

    // MARK: - STATUS

    private var statusTitle: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Notifications are on"

        case .denied:
            return "Notifications are off"

        case .notDetermined:
            return "Notifications are not enabled"

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

        case .notDetermined:
            return "bell"

        @unknown default:
            return "bell"
        }
    }

    private var statusColor: Color {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .green

        case .denied:
            return .red

        case .notDetermined:
            return orange

        @unknown default:
            return .gray
        }
    }

    private var settingsButtonTitle: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Open notification settings"

        case .denied:
            return "Turn on notifications"

        case .notDetermined:
            return "Manage notification access"

        @unknown default:
            return "Open notification settings"
        }
    }

    // MARK: - ACTIONS

    private func loadAuthorizationStatus() async {
        let status =
            await NotificationManager.shared
                .authorizationStatus()

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
