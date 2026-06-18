//
//  InsightsScreen.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

// MARK: - INSIGHTS

struct InsightsScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color

    @State private var showingLastMonth = false
    @ScaledMetric private var titleSize: CGFloat = 34
    @ScaledMetric private var cardRadius: CGFloat = 28
    @ScaledMetric private var iconSize: CGFloat = 58

    private var currentPercent: Int {
        showingLastMonth ? vm.lastMonthNotWorthItPercent : vm.thisMonthNotWorthItPercent
    }

    private var currentNotWorthIt: Int {
        showingLastMonth ? vm.lastMonthNotWorthItCount : vm.thisMonthNotWorthItCount
    }

    private var currentMaybe: Int {
        showingLastMonth ? vm.lastMonthMaybeCount : vm.thisMonthMaybeCount
    }

    private var currentWorthIt: Int {
        showingLastMonth ? vm.lastMonthWorthItCount : vm.thisMonthWorthItCount
    }

    private var currentMoments: Int {
        showingLastMonth ? vm.lastMonthResetCount : vm.thisMonthResetCount
    }

    private var currentActiveDays: Int {
        showingLastMonth ? vm.lastMonthActiveDaysCount : vm.thisMonthActiveDaysCount
    }

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.025, 22)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Insights")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(.black)

                        Text("Your patterns. Your progress.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)

                    VStack(spacing: 18) {
                        progressCard
                        mostUsedResetCard
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 22)
                    .padding(.bottom, 24)
                }

                BottomTabBar(vm: vm, orange: orange)
            }
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 22) {

            HStack {
                Text("Your progress")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingLastMonth.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text(showingLastMonth ? "Last month" : "This month")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(orange)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 0) {
                progressCircle
                    .frame(maxWidth: .infinity)

                Divider()
                    .padding(.vertical, 4)

                VStack(spacing: 0) {
                    outcomeRow(
                        label: "Not\nworth it",
                        value: currentNotWorthIt,
                        color: .green,
                        showDivider: true
                    )

                    outcomeRow(
                        label: "Maybe",
                        value: currentMaybe,
                        color: .orange,
                        showDivider: true
                    )

                    outcomeRow(
                        label: "Worth it",
                        value: currentWorthIt,
                        color: .red,
                        showDivider: false
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 8)
            }
            .frame(minHeight: 210)

            Divider()

            HStack(spacing: 0) {
                bottomStat(
                    icon: "arrow.clockwise",
                    value: "\(currentNotWorthIt)",
                    title: "worries released"
                )

                Divider().padding(.vertical, 10)

                bottomStat(
                    icon: "star",
                    value: "\(currentActiveDays)",
                    title: "active days"
                )

                Divider().padding(.vertical, 10)

                bottomStat(
                    icon: "sparkles",
                    value: "\(currentMoments)",
                    title: "moments"
                )
            }
            .frame(height: 118)
        }
        .padding(22)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private var progressCircle: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(orange.opacity(0.16), lineWidth: 9)
                    .frame(width: 108, height: 108)

                Circle()
                    .trim(from: 0, to: CGFloat(currentPercent) / 100)
                    .stroke(
                        orange,
                        style: StrokeStyle(
                            lineWidth: 9,
                            lineCap: .round
                        )
                    )
                    .frame(width: 108, height: 108)
                    .rotationEffect(.degrees(-90))

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(currentPercent)")
                        .font(.system(size: 32, weight: .bold))

                    Text("%")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.black)
            }

            VStack(spacing: 2) {
                Text("of your thoughts weren't worth overthinking")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
        }
    }

    private func outcomeRow(
        label: String,
        value: Int,
        color: Color,
        showDivider: Bool
    ) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(color)
                    .frame(width: 11, height: 11)

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text("\(value)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 14)

            if showDivider {
                Divider()
            }
        }
    }

    private func bottomStat(
        icon: String,
        value: String,
        title: String
    ) -> some View {
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
                } else if title == "worries released" {
                    Text("worries")
                    Text("released")
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
        }
        .frame(maxWidth: .infinity)
    }

    private var mostUsedResetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("most used reset")
                .font(.system(size: 15))
                .foregroundColor(.gray)

            HStack(spacing: 14) {
                Circle()
                    .fill(ActionStyle.color(vm.mostUsedAction.icon))
                    .frame(width: iconSize, height: iconSize)
                    .overlay(
                        MomentIconImage(
                            icon: ActionStyle.iconName(vm.mostUsedAction.icon),
                            size: iconSize * 0.92
                        )
                    )

                Text(vm.mostUsedAction.label)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }
}
