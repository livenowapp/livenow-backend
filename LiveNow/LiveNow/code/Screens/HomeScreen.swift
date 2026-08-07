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
