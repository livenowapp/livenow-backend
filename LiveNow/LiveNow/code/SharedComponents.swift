//
//  SharedComponents.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

// MARK: - TAB BAR

struct BottomTabBar: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color

    var body: some View {
        HStack(spacing: 0) {
            TabItem(icon: "house", label: "home", tab: .home, vm: vm, orange: orange)
            TabItem(icon: "sparkles", label: "moments", tab: .moments, vm: vm, orange: orange)
            TabItem(icon: "chart.bar", label: "insights", tab: .insights, vm: vm, orange: orange)
            TabItem(icon: "person", label: "profile", tab: .profile, vm: vm, orange: orange)
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 4)
        )
        .padding(.horizontal, 22)
        .padding(.bottom, 8)
    }
}

struct TabItem: View {
    let icon: String
    let label: String
    let tab: MainTab
    @ObservedObject var vm: AppViewModel
    let orange: Color

    @ScaledMetric private var iconSize: CGFloat = 18
    @ScaledMetric private var labelSize: CGFloat = 11

    var body: some View {
        Button(action: {
            vm.currentTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: iconSize))

                Text(label)
                    .font(.system(size: labelSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(vm.currentTab == tab ? orange : .gray)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct OutcomeButton: View {
    let title: String
    let selected: Bool
    let color: Color
    let action: () -> Void

    @ScaledMetric private var textSize: CGFloat = 14

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: textSize, weight: .semibold))
                .foregroundColor(selected ? .white : color)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? color : Color.white.opacity(0.7))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct TopProgressRow: View {
    let stepText: String
    let progress: CGFloat
    let orange: Color
    var onBack: () -> Void

    @ScaledMetric private var iconSize: CGFloat = 18
    @ScaledMetric private var stepSize: CGFloat = 13

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: iconSize, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.08))
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(orange)
                            .frame(width: geo.size.width * progress, height: 4)
                    }
                }

            Text(stepText)
                .font(.system(size: stepSize))
                .foregroundColor(.black.opacity(0.65))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 46, alignment: .trailing)
        }
    }
}

struct EvidenceRow: View {
    let question: String
    let answer: String

    @ScaledMetric private var textSize: CGFloat = 14

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(question)
                .font(.system(size: textSize))
                .foregroundColor(.black.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(answer)
                .font(.system(size: textSize))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

struct AnalysisCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let orange: Color

    @ScaledMetric private var iconCircleSize: CGFloat = 56
    @ScaledMetric private var iconSize: CGFloat = 24
    @ScaledMetric private var titleSize: CGFloat = 18
    @ScaledMetric private var subtitleSize: CGFloat = 14

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: iconCircleSize, height: iconCircleSize)

                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(orange)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

struct SparkleView: View {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let orange: Color

    @ScaledMetric private var sparkleSize: CGFloat = 12

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: sparkleSize))
            .foregroundColor(orange)
            .offset(x: offsetX, y: offsetY)
    }
}

struct ProfilePlaceholderScreen: View {
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var vm: AppViewModel

    private let orange = Color(red: 1.0, green: 0.43, blue: 0.10)

    @ScaledMetric private var logoSize: CGFloat = 24
    @ScaledMetric private var topButtonSize: CGFloat = 40
    @ScaledMetric private var nameSize: CGFloat = 34

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
                                Text("Jack")
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
            }
        }
    }

    private var progressCard: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Your progress")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                Text("View all")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(orange)

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 0) {
                progressCircle

                Divider().padding(.vertical, 8)

                statItem(icon: "arrow.clockwise", value: "\(vm.last7DaysEntries.count)", title: "resets", subtitle: "this week")

                Divider().padding(.vertical, 8)

                statItem(icon: "flame", value: "\(vm.streakCount)", title: "day streak", subtitle: "current")

                Divider().padding(.vertical, 8)

                statItem(icon: "star", value: "\(vm.entries.count)", title: "moments", subtitle: "saved")
            }

            HStack(spacing: 14) {
                Circle()
                    .fill(orange.opacity(0.12))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "bolt.fill")
                            .foregroundColor(orange)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("You’ve broken the loop \(vm.last7DaysEntries.count) times this week.")
                        .font(.system(size: 15, weight: .semibold))

                    Text("Keep going.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .background(orange.opacity(0.05))
            .cornerRadius(16)
        }
        .padding(18)
        .background(Color.white.opacity(0.75))
        .cornerRadius(22)
    }

    private var progressCircle: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(orange.opacity(0.15), lineWidth: 7)
                    .frame(width: 82, height: 82)

                Circle()
                    .trim(from: 0, to: CGFloat(vm.last7DaysDidNotHappenPercent) / 100)
                    .stroke(orange, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .frame(width: 82, height: 82)
                    .rotationEffect(.degrees(-90))

                Text("\(vm.last7DaysDidNotHappenPercent)%")
                    .font(.system(size: 22, weight: .bold))
            }

            Text("less overthinking")
                .font(.system(size: 13))
                .multilineTextAlignment(.center)

            Text("this week")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private func statItem(icon: String, value: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(orange)

            Text(value)
                .font(.system(size: 22, weight: .bold))

            Text(title)
                .font(.system(size: 13))

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private var menuCard: some View {
        VStack(spacing: 0) {
            menuRow(icon: "gearshape", title: "Settings", subtitle: "Manage your account and app", orangeIcon: true)
            Divider().padding(.leading, 74)

            menuRow(icon: "envelope", title: "Contact us", subtitle: "We’d love to hear from you")
            Divider().padding(.leading, 74)

            menuRow(icon: "star", title: "Rate LiveNow", subtitle: "If LiveNow helps you, leave a review")
            Divider().padding(.leading, 74)

            menuRow(icon: "square.and.arrow.up", title: "Share LiveNow", subtitle: "Help others live more in the now")
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
}
