//
//  InsightsScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//


import SwiftUI

// MARK: - INSIGHTS

struct InsightsScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color

    @State private var showingLastMonth = false
    @ScaledMetric private var titleSize: CGFloat = 34
    @ScaledMetric private var cardRadius: CGFloat = 22

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
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)

            let horizontalPadding = min(screenWidth * 0.055, 24)
            let topPadding = min(screenHeight * 0.025, 22)

            let adjustedTitleSize = titleSize * scale
            let subtitleSize = min(max(screenWidth * 0.038, 14), 16)

            let progressCircleSize = min(max(screenWidth * 0.26, 86), 126)
            let progressLineWidth = min(max(screenWidth * 0.019, 7), 9)
            let progressPercentSize = min(max(screenWidth * 0.082, 30), 40)
            let progressPercentSymbolSize = min(max(screenWidth * 0.036, 12), 16)
            let progressTextSize = min(max(screenWidth * 0.036, 13), 16)

            let rowDotSize = min(max(screenWidth * 0.026, 9), 11)
            let rowLabelSize = min(max(screenWidth * 0.038, 14), 17)
            let rowValueSize = min(max(screenWidth * 0.055, 20), 25)
            let rowVerticalPadding = min(max(screenHeight * 0.010, 8), 11)

            let cardPadding = min(max(screenWidth * 0.052, 18), 24)
            let cardSpacing = min(max(screenHeight * 0.012, 10), 16)
            let progressMinHeight = min(max(screenHeight * 0.225, 190), 230)

            let bottomStatIconSize = min(max(screenWidth * 0.06, 23), 28)
            let bottomStatValueSize = min(max(screenWidth * 0.065, 24), 30)
            let bottomStatTextSize = min(max(screenWidth * 0.033, 12), 14)
            let bottomStatHeight = min(max(screenHeight * 0.12, 105), 126)

            let mostUsedCardWidth = min(max(screenWidth * 0.28, 105), 120)
            let mostUsedCardHeight = min(max(screenWidth * 0.18, 145), 165)
            let mostUsedTitleSize = min(max(screenWidth * 0.038, 14), 16)
            let mostUsedLabelSize = min(max(screenWidth * 0.05, 18), 22)
            let mostUsedTextSize = min(max(screenWidth * 0.040, 16), 19)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Insights")
                            .font(.system(size: adjustedTitleSize, weight: .bold))
                            .foregroundColor(.black)

                        Text("Your patterns. Your progress.")
                            .font(.system(size: subtitleSize))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)

                    VStack(spacing: 18) {
                        progressCard(
                            circleSize: progressCircleSize,
                            lineWidth: progressLineWidth,
                            percentSize: progressPercentSize,
                            percentSymbolSize: progressPercentSymbolSize,
                            progressTextSize: progressTextSize,
                            rowDotSize: rowDotSize,
                            rowLabelSize: rowLabelSize,
                            rowValueSize: rowValueSize,
                            rowVerticalPadding: rowVerticalPadding,
                            cardPadding: cardPadding,
                            cardSpacing: cardSpacing,
                            progressMinHeight: progressMinHeight,
                            bottomStatIconSize: bottomStatIconSize,
                            bottomStatValueSize: bottomStatValueSize,
                            bottomStatTextSize: bottomStatTextSize,
                            bottomStatHeight: bottomStatHeight
                        )

                        mostUsedResetCard(
                            titleSize: mostUsedTitleSize,
                            labelSize: mostUsedLabelSize,
                            cardPadding: cardPadding,
                            cardWidth: mostUsedCardWidth,
                            cardHeight: mostUsedCardHeight,
                            textSize: mostUsedTextSize
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, min(max(screenHeight * 0.026, 18), 24))
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func progressCard(
        circleSize: CGFloat,
        lineWidth: CGFloat,
        percentSize: CGFloat,
        percentSymbolSize: CGFloat,
        progressTextSize: CGFloat,
        rowDotSize: CGFloat,
        rowLabelSize: CGFloat,
        rowValueSize: CGFloat,
        rowVerticalPadding: CGFloat,
        cardPadding: CGFloat,
        cardSpacing: CGFloat,
        progressMinHeight: CGFloat,
        bottomStatIconSize: CGFloat,
        bottomStatValueSize: CGFloat,
        bottomStatTextSize: CGFloat,
        bottomStatHeight: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            HStack {
                Text("Your progress")
                    .font(.system(size: min(max(circleSize * 0.22, 22), 26), weight: .bold))
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
                    .font(.system(size: min(max(circleSize * 0.12, 13), 15), weight: .semibold))
                    .foregroundColor(orange)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 0) {
                progressCircle(
                    circleSize: circleSize,
                    lineWidth: lineWidth,
                    percentSize: percentSize,
                    percentSymbolSize: percentSymbolSize,
                    textSize: progressTextSize
                )
                .frame(maxWidth: .infinity)

                Divider()
                    .padding(.vertical, 4)

                VStack(spacing: 0) {
                    outcomeRow(
                        label: "Not\nworth it",
                        value: currentNotWorthIt,
                        color: .green,
                        showDivider: true,
                        dotSize: rowDotSize,
                        labelSize: rowLabelSize,
                        valueSize: rowValueSize,
                        verticalPadding: rowVerticalPadding
                    )

                    outcomeRow(
                        label: "Maybe",
                        value: currentMaybe,
                        color: .orange,
                        showDivider: true,
                        dotSize: rowDotSize,
                        labelSize: rowLabelSize,
                        valueSize: rowValueSize,
                        verticalPadding: rowVerticalPadding
                    )

                    outcomeRow(
                        label: "Worth it",
                        value: currentWorthIt,
                        color: .red,
                        showDivider: false,
                        dotSize: rowDotSize,
                        labelSize: rowLabelSize,
                        valueSize: rowValueSize,
                        verticalPadding: rowVerticalPadding
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, min(max(circleSize * 0.08, 8), 14))
            }
            .frame(minHeight: progressMinHeight)

            Divider()

            HStack(spacing: 0) {
                bottomStat(
                    icon: "arrow.clockwise",
                    value: "\(currentNotWorthIt)",
                    title: "worries released",
                    iconSize: bottomStatIconSize,
                    valueSize: bottomStatValueSize,
                    textSize: bottomStatTextSize
                )

                Divider().padding(.vertical, 10)

                bottomStat(
                    icon: "star",
                    value: "\(currentActiveDays)",
                    title: "active days",
                    iconSize: bottomStatIconSize,
                    valueSize: bottomStatValueSize,
                    textSize: bottomStatTextSize
                )

                Divider().padding(.vertical, 10)

                bottomStat(
                    icon: "sparkles",
                    value: "\(currentMoments)",
                    title: "moments",
                    iconSize: bottomStatIconSize,
                    valueSize: bottomStatValueSize,
                    textSize: bottomStatTextSize
                )
            }
            .frame(height: bottomStatHeight)
        }
        .padding(cardPadding)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private func progressCircle(
        circleSize: CGFloat,
        lineWidth: CGFloat,
        percentSize: CGFloat,
        percentSymbolSize: CGFloat,
        textSize: CGFloat
    ) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(orange.opacity(0.16), lineWidth: lineWidth)
                    .frame(width: circleSize, height: circleSize)

                Circle()
                    .trim(from: 0, to: CGFloat(currentPercent) / 100)
                    .stroke(
                        orange,
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(currentPercent)")
                        .font(.system(size: percentSize, weight: .bold))

                    Text("%")
                        .font(.system(size: percentSymbolSize, weight: .bold))
                }
                .foregroundColor(.black)
            }

            Text("not worth\noverthinking")
                .font(.system(size: textSize, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
    }

    private func outcomeRow(
        label: String,
        value: Int,
        color: Color,
        showDivider: Bool,
        dotSize: CGFloat,
        labelSize: CGFloat,
        valueSize: CGFloat,
        verticalPadding: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)

                Text(label)
                    .font(.system(size: labelSize, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text("\(value)")
                    .font(.system(size: valueSize, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.vertical, verticalPadding)

            if showDivider {
                Divider()
            }
        }
    }

    private func bottomStat(
        icon: String,
        value: String,
        title: String,
        iconSize: CGFloat,
        valueSize: CGFloat,
        textSize: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .regular))
                .foregroundColor(orange)
                .frame(height: iconSize + 6)

            Text(value)
                .font(.system(size: valueSize, weight: .bold))
                .foregroundColor(.black)
                .frame(height: valueSize + 10)

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
            .font(.system(size: textSize, weight: .medium))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .frame(height: textSize * 2.7)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func mostUsedResetCard(
        titleSize: CGFloat,
        labelSize: CGFloat,
        cardPadding: CGFloat,
        cardWidth: CGFloat,
        cardHeight: CGFloat,
        textSize: CGFloat
    ) -> some View {
        HStack(spacing: 14) {
            VStack(spacing: 14) {
                Text("most used\naction")
                    .font(.system(size: titleSize, weight: .medium))
                    .foregroundColor(.gray)

                Circle()
                    .fill(ActionStyle.color(vm.mostUsedAction.icon))
                    .frame(width: ActionIconStyle.size,
                           height: ActionIconStyle.size)
                    .overlay(
                        MomentIconImage(
                            icon: ActionStyle.iconName(vm.mostUsedAction.icon),
                            size: ActionIconStyle.size * ActionIconStyle.imageScale
                        )
                    )
            }
            .frame(width: cardWidth,
                   height: cardHeight)
            .background(Color.white.opacity(0.78))
            .cornerRadius(cardRadius)

            VStack(alignment: .leading, spacing: 10) {
                Text("Positive effect")
                    .font(.system(size: titleSize, weight: .medium))
                    .foregroundColor(.gray)

                Text(mostUsedPositiveText(for: vm.mostUsedAction.icon))
                    .font(.system(size: textSize, weight: .semibold))
                    .foregroundColor(.black.opacity(0.78))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .leading)
            .background(Color.white.opacity(0.78))
            .cornerRadius(cardRadius)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func mostUsedPositiveText(for icon: String) -> String {
        switch icon {
        case "action_breath":
            return "Slow breaths help your mind settle before the thought takes over."
        case "action_walk":
            return "A short walk helps break the loop and bring you back to the moment."
        case "action_chat":
            return "Reaching out reminds you that you don’t have to carry it alone."
        case "action_pencil":
            return "Writing it down makes the thought feel clearer and less heavy."
        case "action_leaf":
            return "Noticing what’s around you gently pulls your attention back to now."
        case "action_music":
            return "Calming music can soften the noise and help your mood shift."
        case "action_sleep":
            return "A few minutes of rest gives your mind space to reset."
        case "action_sunlight":
            return "Daylight can refresh your energy and change your perspective."
        case "action_handraised":
            return "Pausing gives you space to respond instead of react."
        case "action_meditation":
            return "Meditation helps you return to yourself, one quiet moment at a time."
        case "action_book":
            return "Reading gives your mind a calmer place to land."
        case "action_nophone":
            return "Putting your phone away creates space for your mind to breathe."
        default:
            return "This reset helps you choose presence over overthinking."
        }
    }
}
