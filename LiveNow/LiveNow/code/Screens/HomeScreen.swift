//
//  HomeScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI

// MARK: - HOME

struct HomeScreen: View {
    @ObservedObject var vm: AppViewModel

    let orange: Color
    let lightOrange: Color

    var onStart: () -> Void

    @State private var isBreathing = false

    @ScaledMetric private var heroSize: CGFloat = 43
    @ScaledMetric private var subtitleSize: CGFloat = 16

    var body: some View {
        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)
            let horizontalPadding = min(max(screenWidth * 0.06, 20), 28)
            let adjustedHeroSize = min(max(heroSize * scale, 36), 50)
            let subtitleSize = min(max(18 * scale, 15), 22)
            let isCompactHeight = screenHeight < 760

            let resetSize = isCompactHeight
                ? min(screenWidth * 0.46, 185)
                : min(screenWidth * 0.52,
                    screenHeight * 0.24, 230 * scale
                )

            let spacingAfterHeader = min(max(screenHeight * 0.026, 16), 26)
            let spacingAfterHero = min(max(screenHeight * 0.11, 65), 105)
            let spacingAfterReset = min(max(screenHeight * 0.11, 65), 105)
            let bottomSpacing = min(max(screenHeight * 0.04, 22), 42)

            let isGuestAfterFirstReset =
                vm.isGuestUser &&
                vm.hasCompletedGuestReset

            VStack(spacing: 0) {

                // MARK: Header

                LiveNowTopHeader(
                    horizontalPadding: horizontalPadding
                )

                Spacer()
                    .frame(height: spacingAfterHeader)

                // MARK: Hero

                VStack(spacing: 0) {
                    Text(
                        isGuestAfterFirstReset
                            ? "your first reset"
                            : "get out of"
                    )
                    .font(
                        .system(
                            size: adjustedHeroSize,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                    Text(
                        isGuestAfterFirstReset
                            ? "is complete"
                            : "your head"
                    )
                    .font(
                        .system(
                            size: adjustedHeroSize,
                            weight: .bold
                        )
                    )
                    .foregroundColor(orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, horizontalPadding)

                Spacer()
                    .frame(height: spacingAfterHero)

                // MARK: Reset button

                Button(action: onStart) {
                    ZStack {
                        Circle()
                            .fill(orange.opacity(0.16))
                            .frame(
                                width: resetSize * 1.14,
                                height: resetSize * 1.14
                            )
                            .scaleEffect(
                                isBreathing ? 1.08 : 0.92
                            )
                            .opacity(
                                isBreathing ? 0.15 : 0.35
                            )

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        lightOrange,
                                        orange
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: resetSize,
                                height: resetSize
                            )
                            .shadow(
                                color: orange.opacity(
                                    isBreathing ? 0.38 : 0.22
                                ),
                                radius: isBreathing ? 26 : 16,
                                x: 0,
                                y: 9
                            )
                            .scaleEffect(
                                isBreathing ? 1.055 : 0.975
                            )

                        VStack(
                            spacing: resetSize * 0.035
                        ) {
                            Text("RESET")
                                .font(
                                    .system(
                                        size: resetSize * 0.165,
                                        weight: .bold
                                    )
                                )
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text("clear your mind")
                                .font(
                                    .system(
                                        size: resetSize * 0.075
                                    )
                                )
                                .foregroundColor(
                                    .white.opacity(0.95)
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .offset(y: -resetSize * 0.01)
                        .scaleEffect(
                            isBreathing ? 1.01 : 0.99
                        )
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reset")
                .accessibilityHint("Start a new reset")
                .onAppear {
                    guard !isBreathing else { return }

                    withAnimation(
                        .easeInOut(duration: 1.35)
                            .repeatForever(
                                autoreverses: true
                            )
                    ) {
                        isBreathing = true
                    }
                }

                Spacer()
                    .frame(height: spacingAfterReset)

                // MARK: Message

                Text(
                    isGuestAfterFirstReset
                        ? "save your reset and\nkeep your progress going"
                        : vm.homeMessage
                )
                .font(
                    .system(size: subtitleSize)
                )
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.75)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(maxWidth: 340)
                .padding(.horizontal, horizontalPadding)

                Spacer(minLength: bottomSpacing)
            }
            .frame(
                width: screenWidth,
                height: screenHeight,
                alignment: .top
            )
            .sheet(
                isPresented: $vm.showSelectedDateEntries
            ) {
                SelectedDateEntriesSheet(
                    vm: vm,
                    orange: orange
                )
            }
        }
    }
}

/*import SwiftUI

// MARK: - HOME

struct HomeScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    let lightOrange: Color
    var onStart: () -> Void

    @State private var isBreathing = false

    @ScaledMetric private var logoSize: CGFloat = 24
    @ScaledMetric private var heroSize: CGFloat = 43
    @ScaledMetric private var subtitleSize: CGFloat = 16
    @ScaledMetric private var topButtonSize: CGFloat = 40
    @ScaledMetric private var cardRadius: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)

            let horizontalPadding = min(screenWidth * 0.06, 24)
            let topPadding = min(screenHeight * 0.025, 18)

            let adjustedHeroSize = heroSize * scale
            let adjustedSubtitleSize = subtitleSize * min(max(scale, 0.92), 1.08)

            let isCompactHeight = screenHeight < 760

            let resetSize = isCompactHeight
                ? min(screenWidth * 0.46, 185)
                : min(screenWidth * 0.52, screenHeight * 0.24, 230 * scale)

            let spacingAfterHeader = min(max(screenHeight * 0.018, 10), 18)
            let spacingAfterSubtitle = min(max(screenHeight * 0.032, 20), 36)
            let spacingAfterReset = min(max(screenHeight * 0.04, 28), 48)

            let titleSize = min(max(screenWidth * 0.038, 14), 16)
            let last7CircleSize = min(max(screenWidth * 0.21, 80), 120)
            let last7LineWidth = min(max(screenWidth * 0.019, 7), 9)
            let last7PercentSize = min(max(screenWidth * 0.070, 26), 36)
            let last7PercentSymbolSize = min(max(screenWidth * 0.036, 12), 16)
            let last7TextSize = min(max(screenWidth * 0.036, 13), 16)
            let last7RowValueSize = min(max(screenWidth * 0.055, 20), 25)
            let last7RowLabelSize = min(max(screenWidth * 0.038, 14), 17)
            let cardPadding = min(max(screenWidth * 0.052, 18), 24)
            let last7RowVerticalPadding = min(max(screenHeight * 0.009, 7), 9)
            let last7DotSize = min(max(screenWidth * 0.024, 8), 10)
            
            let isGuestAfterFirstReset = vm.isGuestUser && vm.hasCompletedGuestReset

            VStack(spacing: 0) {
                VStack(spacing: 0) {

                    ZStack {
                        Text("LiveNow")
                            .font(.system(size: logoSize, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: topButtonSize)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)

                    Spacer().frame(height: spacingAfterHeader)

                    VStack(spacing: 0) {
                        Text(isGuestAfterFirstReset ? "your first reset" : "get out of")
                            .font(.system(size: adjustedHeroSize, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Text(isGuestAfterFirstReset ? "is complete" : "your head")
                            .font(.system(size: adjustedHeroSize, weight: .bold))
                            .foregroundColor(orange)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .multilineTextAlignment(.center)

                    Spacer().frame(height: min(screenHeight * 0.018, 14))

                    VStack(spacing: min(screenHeight * 0.006, 6)) {
                        if isGuestAfterFirstReset {
                            Text("save your reset and")
                            Text("keep your progress going")
                        } else {
                            Text("you don’t need to figure")
                            Text("everything out right now")
                        }
                    }
                    .font(.system(size: adjustedSubtitleSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                    Spacer().frame(height: spacingAfterSubtitle)

                    Button(action: onStart) {
                        ZStack {
                            Circle()
                                .fill(orange.opacity(0.16))
                                .frame(width: resetSize * 1.14, height: resetSize * 1.14)
                                .scaleEffect(isBreathing ? 1.08 : 0.92)
                                .opacity(isBreathing ? 0.15 : 0.35)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [lightOrange, orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: resetSize, height: resetSize)
                                .shadow(
                                    color: orange.opacity(isBreathing ? 0.38 : 0.22),
                                    radius: isBreathing ? 26 : 16,
                                    x: 0,
                                    y: 9
                                )
                                .scaleEffect(isBreathing ? 1.055 : 0.975)

                            VStack(spacing: resetSize * 0.035) {
                                Text("RESET")
                                    .font(.system(size: resetSize * 0.165, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)

                                Text("clear your mind")
                                    .font(.system(size: resetSize * 0.075))
                                    .foregroundColor(.white.opacity(0.95))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .offset(y: -resetSize * 0.01)
                            .scaleEffect(isBreathing ? 1.01 : 0.99)
                        }
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.35)
                            .repeatForever(autoreverses: true)
                        ) {
                            isBreathing = true
                        }
                    }

                    Spacer().frame(height: spacingAfterReset)

                    
                    if isGuestAfterFirstReset {
                        let firstResetIcon = vm.guestFirstReset?.selectedActionIcon ?? "action_leaf"
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            VStack(alignment: .leading, spacing: min(max(screenHeight * 0.012, 9), 12)) {
                                Text("your first reset")
                                    .font(.system(size: titleSize))
                                    .foregroundColor(.gray)

                                HStack(alignment: .top, spacing: 16) {
                                    Circle()
                                        .fill(ActionStyle.color(firstResetIcon))
                                        .frame(width: ActionIconStyle.size,
                                               height: ActionIconStyle.size)
                                        .overlay(
                                            MomentIconImage(
                                                icon: ActionStyle.iconName(firstResetIcon),
                                                size: ActionIconStyle.size * ActionIconStyle.imageScale
                                            )
                                        )

                                    VStack(alignment: .leading, spacing: 6) {

                                        Text(vm.guestFirstReset?.ai.shortTitle ?? "")
                                            .font(.system(size: last7RowLabelSize, weight: .semibold))
                                            .foregroundColor(.black)
                                            .lineLimit(2)

                                        Text(vm.guestFirstReset?.thought ?? "")
                                            .font(.system(size: last7TextSize))
                                            .foregroundColor(.gray)
                                            .lineLimit(3)
                                    }

                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(cardPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.78))
                            .cornerRadius(cardRadius)
                        }
                        .padding(.horizontal, horizontalPadding)

                    } else {
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: min(max(screenHeight * 0.012, 9), 12)) {
                           
                            Text("last 7 days")
                                .font(.system(size: titleSize))
                                .foregroundColor(.gray)

                            HStack(spacing: 0) {
                                VStack(spacing: min(max(screenHeight * 0.011, 8), 11)) {
                                    ZStack {
                                        Circle()
                                            .stroke(orange.opacity(0.16), lineWidth: last7LineWidth)
                                            .frame(width: last7CircleSize, height: last7CircleSize)

                                        Circle()
                                            .trim(from: 0, to: CGFloat(vm.last7DaysNotWorthItPercent) / 100)
                                            .stroke(
                                                orange,
                                                style: StrokeStyle(
                                                    lineWidth: last7LineWidth,
                                                    lineCap: .round
                                                )
                                            )
                                            .frame(width: last7CircleSize, height: last7CircleSize)
                                            .rotationEffect(.degrees(-90))

                                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                                            Text("\(vm.last7DaysNotWorthItPercent)")
                                                .font(.system(size: last7PercentSize, weight: .bold))

                                            Text("%")
                                                .font(.system(size: last7PercentSymbolSize, weight: .bold))
                                        }
                                        .foregroundColor(.black)
                                    }

                                    Text("not worth\noverthinking")
                                        .font(.system(size: last7TextSize, weight: .semibold))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)

                                Divider()
                                    .padding(.vertical, 6)

                                VStack(spacing: 0) {
                                    homeOutcomeRow(
                                        label: "Not\nworth it",
                                        value: vm.last7DaysNotWorthItCount,
                                        color: .green,
                                        showDivider: true,
                                        dotSize: last7DotSize,
                                        labelSize: last7RowLabelSize,
                                        valueSize: last7RowValueSize,
                                        verticalPadding: last7RowVerticalPadding
                                    )

                                    homeOutcomeRow(
                                        label: "Maybe",
                                        value: vm.last7DaysMaybeCount,
                                        color: .orange,
                                        showDivider: true,
                                        dotSize: last7DotSize,
                                        labelSize: last7RowLabelSize,
                                        valueSize: last7RowValueSize,
                                        verticalPadding: last7RowVerticalPadding
                                    )

                                    homeOutcomeRow(
                                        label: "Worth it",
                                        value: vm.last7DaysWorthItCount,
                                        color: .red,
                                        showDivider: false,
                                        dotSize: last7DotSize,
                                        labelSize: last7RowLabelSize,
                                        valueSize: last7RowValueSize,
                                        verticalPadding: last7RowVerticalPadding
                                    )
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.leading, min(max(screenWidth * 0.026, 9), 16))
                            }
                        }
                        .padding(cardPadding)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.78))
                        .cornerRadius(cardRadius)
                        .padding(.horizontal, horizontalPadding)
                    }

                    Spacer(minLength: min(screenHeight * 0.015, 12))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sheet(isPresented: $vm.showSelectedDateEntries) {
                    SelectedDateEntriesSheet(vm: vm, orange: orange)
                }
            }
        }
    }

    private func homeOutcomeRow(
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
}*/

/*import SwiftUI

// MARK: - HOME

struct HomeScreen: View {
    @ObservedObject var vm: AppViewModel

    let orange: Color
    let lightOrange: Color

    var onStart: () -> Void

    @State private var isBreathing = false
    @State private var selectedReminder =
        HomeScreen.reminders.randomElement()
        ?? "You don’t need to solve everything today."

    @ScaledMetric private var logoSize: CGFloat = 24
    @ScaledMetric private var heroSize: CGFloat = 43
    @ScaledMetric private var subtitleSize: CGFloat = 16
    @ScaledMetric private var topButtonSize: CGFloat = 40
    @ScaledMetric private var cardRadius: CGFloat = 22

    private static let reminders = [
        "You don’t need to solve everything today.",
        "Take one thing at a time.",
        "Not every thought needs an answer.",
        "Give your mind permission to slow down.",
        "You can pause before figuring it all out.",
        "A thought is not always a fact.",
        "Come back to what is happening right now.",
        "You are allowed to leave some questions unanswered.",
        "One calm moment can change your perspective.",
        "Your mind deserves a little space.",
        "Focus on what you can control today.",
        "You don’t have to believe every thought."
    ]

    var body: some View {
        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(
                max(screenWidth / 393, 0.88),
                1.16
            )

            let heightScale = min(
                max(screenHeight / 852, 0.88),
                1.12
            )

            let scale = min(widthScale, heightScale)

            let horizontalPadding = min(
                screenWidth * 0.06,
                24
            )

            let topPadding = min(
                screenHeight * 0.025,
                18
            )

            let adjustedHeroSize = heroSize * scale

            let adjustedSubtitleSize =
                subtitleSize * min(max(scale, 0.92), 1.08)

            let isCompactHeight = screenHeight < 760

            let resetSize = isCompactHeight
                ? min(screenWidth * 0.42, 170)
                : min(
                    screenWidth * 0.47,
                    screenHeight * 0.215,
                    205 * scale
                )

            let spacingAfterHeader = min(
                max(screenHeight * 0.014, 9),
                15
            )

            let spacingAfterSubtitle = min(
                max(screenHeight * 0.025, 17),
                28
            )

            let spacingAfterReset = min(
                max(screenHeight * 0.024, 16),
                25
            )

            let titleSize = min(
                max(screenWidth * 0.038, 14),
                16
            )

            let cardTitleSize = min(
                max(screenWidth * 0.038, 14),
                17
            )

            let bodyTextSize = min(
                max(screenWidth * 0.035, 13),
                16
            )

            let reminderTextSize = min(
                max(screenWidth * 0.04, 15),
                18
            )

            let cardPadding = min(
                max(screenWidth * 0.045, 16),
                21
            )

            let cardSpacing = min(
                max(screenHeight * 0.012, 9),
                12
            )

            let previewIconSize = min(
                max(screenWidth * 0.15, 56),
                68
            )

            let isGuestAfterFirstReset =
                vm.isGuestUser &&
                vm.hasCompletedGuestReset

            VStack(spacing: 0) {

                // MARK: Header

                Text("LiveNow")
                    .font(
                        .system(
                            size: logoSize,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                    .frame(height: topButtonSize)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)

                Spacer()
                    .frame(height: spacingAfterHeader)

                // MARK: Hero title

                VStack(spacing: 0) {
                    Text(
                        isGuestAfterFirstReset
                            ? "your first reset"
                            : "get out of"
                    )
                    .font(
                        .system(
                            size: adjustedHeroSize,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                    Text(
                        isGuestAfterFirstReset
                            ? "is complete"
                            : "your head"
                    )
                    .font(
                        .system(
                            size: adjustedHeroSize,
                            weight: .bold
                        )
                    )
                    .foregroundColor(orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                }
                .multilineTextAlignment(.center)

                Spacer()
                    .frame(
                        height: min(
                            screenHeight * 0.015,
                            12
                        )
                    )

                // MARK: Subtitle

                VStack(
                    spacing: min(
                        screenHeight * 0.005,
                        5
                    )
                ) {
                    if isGuestAfterFirstReset {
                        Text("save your reset and")
                        Text("keep your progress going")
                    } else {
                        Text("you don’t need to figure")
                        Text("everything out right now")
                    }
                }
                .font(
                    .system(
                        size: adjustedSubtitleSize
                    )
                )
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

                Spacer()
                    .frame(height: spacingAfterSubtitle)

                // MARK: Reset button

                Button(action: onStart) {
                    ZStack {
                        Circle()
                            .fill(orange.opacity(0.16))
                            .frame(
                                width: resetSize * 1.14,
                                height: resetSize * 1.14
                            )
                            .scaleEffect(
                                isBreathing ? 1.08 : 0.92
                            )
                            .opacity(
                                isBreathing ? 0.15 : 0.35
                            )

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        lightOrange,
                                        orange
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: resetSize,
                                height: resetSize
                            )
                            .shadow(
                                color: orange.opacity(
                                    isBreathing
                                        ? 0.38
                                        : 0.22
                                ),
                                radius: isBreathing
                                    ? 26
                                    : 16,
                                x: 0,
                                y: 9
                            )
                            .scaleEffect(
                                isBreathing
                                    ? 1.055
                                    : 0.975
                            )

                        VStack(
                            spacing: resetSize * 0.035
                        ) {
                            Text("RESET")
                                .font(
                                    .system(
                                        size: resetSize * 0.165,
                                        weight: .bold
                                    )
                                )
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text("clear your mind")
                                .font(
                                    .system(
                                        size: resetSize * 0.075
                                    )
                                )
                                .foregroundColor(
                                    .white.opacity(0.95)
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .offset(y: -resetSize * 0.01)
                        .scaleEffect(
                            isBreathing
                                ? 1.01
                                : 0.99
                        )
                    }
                }
                .buttonStyle(.plain)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.35)
                            .repeatForever(
                                autoreverses: true
                            )
                    ) {
                        isBreathing = true
                    }
                }

                Spacer()
                    .frame(height: spacingAfterReset)

                // MARK: Bottom content

                if isGuestAfterFirstReset {

                    guestFirstResetCard(
                        titleSize: titleSize,
                        cardTitleSize: cardTitleSize,
                        bodyTextSize: bodyTextSize,
                        cardPadding: cardPadding,
                        previewIconSize: previewIconSize
                    )
                    .padding(.horizontal, horizontalPadding)

                } else {

                    VStack(spacing: cardSpacing) {

                        if let lastReset = vm.entries.first {
                            lastResetCard(
                                entry: lastReset,
                                titleSize: titleSize,
                                cardTitleSize: cardTitleSize,
                                bodyTextSize: bodyTextSize,
                                cardPadding: cardPadding,
                                previewIconSize: previewIconSize
                            )
                        }

                        reminderCard(
                            titleSize: titleSize,
                            reminderTextSize: reminderTextSize,
                            cardPadding: cardPadding
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                }

                Spacer(
                    minLength: min(
                        screenHeight * 0.012,
                        10
                    )
                )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .sheet(
                isPresented:
                    $vm.showSelectedDateEntries
            ) {
                SelectedDateEntriesSheet(
                    vm: vm,
                    orange: orange
                )
            }
        }
    }

    // MARK: - Last reset card

    private func lastResetCard(
        entry: ThoughtEntry,
        titleSize: CGFloat,
        cardTitleSize: CGFloat,
        bodyTextSize: CGFloat,
        cardPadding: CGFloat,
        previewIconSize: CGFloat
    ) -> some View {

        let actionIcon =
            entry.selectedActionIcon
            ?? "action_leaf"

        return VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("last reset")
                .font(
                    .system(size: titleSize)
                )
                .foregroundColor(.gray)

            HStack(
                alignment: .center,
                spacing: 14
            ) {
                Circle()
                    .fill(
                        ActionStyle.color(
                            actionIcon
                        )
                    )
                    .frame(
                        width: previewIconSize,
                        height: previewIconSize
                    )
                    .overlay(
                        MomentIconImage(
                            icon: ActionStyle.iconName(
                                actionIcon
                            ),
                            size:
                                previewIconSize
                                * ActionIconStyle.imageScale
                        )
                    )

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text(entry.ai.shortTitle)
                        .font(
                            .system(
                                size: cardTitleSize,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(entry.thought)
                        .font(
                            .system(
                                size: bodyTextSize
                            )
                        )
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(cardPadding)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.white.opacity(0.78)
        )
        .cornerRadius(cardRadius)
        .contentShape(Rectangle())
        .onTapGesture {
            vm.selectedMoment = entry
        }
    }

    // MARK: - Reminder card

    private func reminderCard(
        titleSize: CGFloat,
        reminderTextSize: CGFloat,
        cardPadding: CGFloat
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack {
                Text("today’s reminder")
                    .font(
                        .system(size: titleSize)
                    )
                    .foregroundColor(.gray)

                Spacer()

                Image(systemName: "sparkles")
                    .font(
                        .system(
                            size: 14,
                            weight: .medium
                        )
                    )
                    .foregroundColor(orange)
            }

            Text(selectedReminder)
                .font(
                    .system(
                        size: reminderTextSize,
                        weight: .medium
                    )
                )
                .foregroundColor(.black)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .padding(cardPadding)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.white.opacity(0.78)
        )
        .cornerRadius(cardRadius)
    }

    // MARK: - Guest first reset card

    private func guestFirstResetCard(
        titleSize: CGFloat,
        cardTitleSize: CGFloat,
        bodyTextSize: CGFloat,
        cardPadding: CGFloat,
        previewIconSize: CGFloat
    ) -> some View {

        let firstResetIcon =
            vm.guestFirstReset?
                .selectedActionIcon
            ?? "action_leaf"

        return VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("your first reset")
                .font(
                    .system(size: titleSize)
                )
                .foregroundColor(.gray)

            HStack(
                alignment: .center,
                spacing: 14
            ) {
                Circle()
                    .fill(
                        ActionStyle.color(
                            firstResetIcon
                        )
                    )
                    .frame(
                        width: previewIconSize,
                        height: previewIconSize
                    )
                    .overlay(
                        MomentIconImage(
                            icon: ActionStyle.iconName(
                                firstResetIcon
                            ),
                            size:
                                previewIconSize
                                * ActionIconStyle.imageScale
                        )
                    )

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text(
                        vm.guestFirstReset?
                            .ai.shortTitle
                        ?? ""
                    )
                    .font(
                        .system(
                            size: cardTitleSize,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                    Text(
                        vm.guestFirstReset?
                            .thought
                        ?? ""
                    )
                    .font(
                        .system(
                            size: bodyTextSize
                        )
                    )
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(cardPadding)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.white.opacity(0.78)
        )
        .cornerRadius(cardRadius)
    }
}*/
