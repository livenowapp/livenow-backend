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

    @ScaledMetric private var titleSize: CGFloat = 28
    @ScaledMetric private var percentSize: CGFloat = 40
    @ScaledMetric private var bodySize: CGFloat = 14
    @ScaledMetric private var cardRadius: CGFloat = 20
    @ScaledMetric private var dotSize: CGFloat = 8
   
    private var dynamicInsight: String {
        if vm.didNotHappenPercent > 70 {
            return "Most of your worries don’t come true."
        } else if vm.didNotHappenPercent > 50 {
            return "You’re starting to see patterns in your thinking."
        } else {
            return "Keep going — patterns will become clearer."
        }
    }
    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.025, 22)
            let cardVerticalPadding = min(geo.size.height * 0.03, 26)
            let contentTopPadding = min(geo.size.height * 0.026, 22)
            let contentBottomPadding = min(geo.size.height * 0.028, 24)
            let cardSpacing = min(geo.size.height * 0.022, 18)

            VStack(spacing: 0) {
                HStack {
                    Text("your patterns")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.85)

                    Spacer()
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: cardSpacing) {
                        
                        VStack(spacing: 6) {
                            Text("last 7 days")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)

                            Text("\(vm.last7DaysDidNotHappenPercent)% didn’t happen")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(orange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(cardRadius)
                        
                        VStack(spacing: 10) {
                            Text("all time")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Text("\(vm.didNotHappenPercent)%")
                                .font(.system(size: percentSize, weight: .bold))
                                .foregroundColor(orange)
                                .minimumScaleFactor(0.85)

                            Text("of your thoughts didn’t happen")
                                .font(.system(size: bodySize))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, cardVerticalPadding)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(cardRadius)

                        VStack(spacing: 10) {
                            InsightRow(
                                label: "didn't happen",
                                value: vm.didntHappenCount,
                                color: .green,
                                dotSize: dotSize
                            )

                            InsightRow(
                                label: "maybe",
                                value: vm.maybeCount,
                                color: .orange,
                                dotSize: dotSize
                            )

                            InsightRow(
                                label: "happened",
                                value: vm.happenedCount,
                                color: .red,
                                dotSize: dotSize
                            )
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(cardRadius)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("insight")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)

                            Text(dynamicInsight)
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(cardRadius)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("most used reset")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)

                            HStack(spacing: 8) {
                                Image(systemName: vm.mostUsedAction.icon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(orange)
                                    .frame(width: 28, height: 28)
                                    .background(orange.opacity(0.15))
                                    .cornerRadius(8)

                                Text(vm.mostUsedAction.label)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(cardRadius)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, contentTopPadding)
                    .padding(.bottom, contentBottomPadding)
                }

                BottomTabBar(vm: vm, orange: orange)
            }
        }
    }
}
struct InsightRow: View {
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
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer()

            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}
