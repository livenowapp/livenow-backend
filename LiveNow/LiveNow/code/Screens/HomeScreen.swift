//
//  HomeScreen.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

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

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let horizontalPadding = min(geo.size.width * 0.06, 24)
            let topPadding = min(geo.size.height * 0.025, 18)

            let resetSize = min(screenWidth * 0.50, screenHeight * 0.23, 210)

            let spacingAfterHeader = min(screenHeight * 0.035, 30)
            let spacingAfterSubtitle = min(screenHeight * 0.04, 34)
            let spacingAfterReset = min(screenHeight * 0.035, 28)

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
                        Text("get out of")
                            .font(.system(size: heroSize, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Text("your head")
                            .font(.system(size: heroSize, weight: .bold))
                            .foregroundColor(orange)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .multilineTextAlignment(.center)

                    Spacer().frame(height: min(screenHeight * 0.018, 14))

                    VStack(spacing: min(screenHeight * 0.006, 6)) {
                        Text("you don’t need to figure")
                        Text("everything out right now.")
                    }
                    .font(.system(size: subtitleSize))
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
                                .shadow(color: orange.opacity(isBreathing ? 0.38 : 0.22), radius: isBreathing ? 26 : 16, x: 0, y: 9)
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

                    VStack(spacing: min(screenHeight * 0.014, 12)) {
                        Text("last 7 days")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        HStack(spacing: 6) {
                            Text("\(vm.last7DaysNotWorthItPercent)%")
                                .font(.system(size: min(screenWidth * 0.075, 28), weight: .bold))
                                .foregroundColor(orange)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Text("of your thoughts weren´t worth overhinking")
                                .font(.system(size: min(screenWidth * 0.04, 15)))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }

                        VStack(spacing: min(screenHeight * 0.009, 8)) {
                            OutcomeRow(
                                label: "Not worth it",
                                value: vm.last7DaysNotWorthItCount,
                                color: Color.green,
                                dotSize: min(screenWidth * 0.018, 7)
                            )

                            OutcomeRow(
                                label: "Maybe",
                                value: vm.last7DaysMaybeCount,
                                color: Color.orange,
                                dotSize: min(screenWidth * 0.018, 7)
                            )

                            OutcomeRow(
                                label: "Worth it",
                                value: vm.last7DaysWorthItCount,
                                color: Color.red,
                                dotSize: min(screenWidth * 0.018, 7)
                            )
                        }
                    }
                    .padding(.vertical, min(screenHeight * 0.018, 16))
                    .padding(.horizontal, min(screenWidth * 0.045, 16))
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(18)
                    .padding(.horizontal, horizontalPadding)

                    Spacer(minLength: min(screenHeight * 0.015, 12))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sheet(isPresented: $vm.showSelectedDateEntries) {
                    SelectedDateEntriesSheet(vm: vm, orange: orange)
                }

                BottomTabBar(vm: vm, orange: orange)
            }
        }
    }
    struct OutcomeRow: View {
        let label: String
        let value: Int
        let color: Color
        let dotSize: CGFloat

        var body: some View {
            HStack(spacing: 10) {
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)

                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.8))

                Spacer()

                Text("\(value)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
    }
}
