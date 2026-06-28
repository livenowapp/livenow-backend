//
//  PaywallScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 31. 5. 2026.
//

import SwiftUI

enum PaywallPlan {
    case yearly
    case weekly
}

struct PaywallScreen: View {
    let orange: Color
    let lightOrange: Color
    var onSubscribe: (PaywallPlan) -> Void
    var onRestore: () -> Void
    var onClose: () -> Void

    @State private var selectedPlan: PaywallPlan = .yearly

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.84), 1.14)
            let scale = min(widthScale, heightScale)

            let isCompact = screenHeight < 780
            let isVeryCompact = screenHeight < 720

            let horizontalPadding = min(max(screenWidth * 0.06, 20), 28)
            let topPadding = min(max(screenHeight * 0.018, 8), 18)

            let closeSize = min(max(screenWidth * 0.095, 36), 44)
            let logoSize = min(max(screenWidth * 0.22, 72), 112)

            let titleSize = min(max(32 * scale, 26), 38)
            let subtitleSize = min(max(15.5 * scale, 13), 18)

            let headerSpacing = min(max(screenHeight * 0.014, 8), 16)
            let sectionSpacing = min(max(screenHeight * 0.018, 12), 24)
            let featureSpacing = min(max(screenHeight * 0.011, 7), 12)
            let planSpacing = min(max(screenHeight * 0.011, 7), 12)

            let buttonTextSize = min(max(17 * scale, 15), 19)
            let buttonVerticalPadding = min(max(screenHeight * 0.019, 13), 18)

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: closeSize * 0.40, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: closeSize, height: closeSize)
                            .background(Color.white.opacity(0.78))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                Spacer(minLength: isVeryCompact ? 2 : 8)

                Image("LogoCircle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)

                Spacer().frame(height: headerSpacing)

                VStack(spacing: min(max(screenHeight * 0.007, 5), 8)) {
                    Text("unlock LiveNow")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text("reset your mind anytime & save your progress.")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: sectionSpacing)

                VStack(spacing: featureSpacing) {
                    PaywallFeatureRow(
                        icon: "brain.head.profile",
                        title: "Unlimited resets",
                        subtitle: "Analyze thoughts whenever your mind feels stuck.",
                        orange: orange,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        scale: scale,
                        isCompact: isCompact
                    )

                    PaywallFeatureRow(
                        icon: "sparkles",
                        title: "Personal reframes",
                        subtitle: "Get calmer, more realistic thoughts back.",
                        orange: orange,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        scale: scale,
                        isCompact: isCompact
                    )

                    PaywallFeatureRow(
                        icon: "chart.bar",
                        title: "Personal insights",
                        subtitle: "Discover patterns behind your overthinking.",
                        orange: orange,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        scale: scale,
                        isCompact: isCompact
                    )
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: sectionSpacing)

                VStack(spacing: planSpacing) {
                    PaywallPlanCard(
                        title: "LiveNow Yearly",
                        price: "€49.99 / year",
                        subtitle: "Save 68%",
                        badge: "MOST POPULAR",
                        isSelected: selectedPlan == .yearly,
                        orange: orange,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        scale: scale,
                        isCompact: isCompact
                    ) {
                        selectedPlan = .yearly
                    }

                    PaywallPlanCard(
                        title: "LiveNow Weekly",
                        price: "€2.99 / week",
                        subtitle: "Cancel anytime",
                        badge: nil,
                        isSelected: selectedPlan == .weekly,
                        orange: orange,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        scale: scale,
                        isCompact: isCompact
                    ) {
                        selectedPlan = .weekly
                    }
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: min(max(screenHeight * 0.018, 12), 22))

                Button {
                    onSubscribe(selectedPlan)
                } label: {
                    Text("Start 3-day free trial")
                        .font(.system(size: buttonTextSize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, buttonVerticalPadding)
                        .background(orange)
                        .cornerRadius(min(max(screenWidth * 0.04, 15), 18))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: min(max(screenHeight * 0.009, 6), 11))

                Button(action: onRestore) {
                    Text("restore purchase")
                        .font(.system(size: min(max(15 * scale, 13), 16), weight: .medium))
                        .foregroundColor(orange)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: min(max(screenHeight * 0.008, 5), 10))

                Text("AI-generated reflection. Not professional advice.")
                    .font(.system(size: min(max(12.5 * scale, 11), 14)))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: isVeryCompact ? 6 : 14)
            }
            .frame(width: screenWidth, height: screenHeight)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }
}

struct PaywallPlanCard: View {
    let title: String
    let price: String
    let subtitle: String
    let badge: String?
    let isSelected: Bool
    let orange: Color
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let scale: CGFloat
    let isCompact: Bool
    let action: () -> Void

    var body: some View {
        let cardPadding = min(max(screenWidth * 0.032, 11), 16)
        let cornerRadius = min(max(screenWidth * 0.046, 18), 22)

        let titleSize = min(max(15 * scale, 14), 17)
        let priceSize = min(max(22 * scale, 20), 26)
        let subtitleSize = min(max(13 * scale, 12), 15)

        let badgeTextSize = min(max(10 * scale, 9), 11)
        let checkSize = min(max(screenWidth * 0.056, 21), 26)

        Button(action: action) {
            HStack(spacing: min(max(screenWidth * 0.025, 9), 13)) {
                VStack(alignment: .leading, spacing: isCompact ? 3 : 5) {
                    Text(title)
                        .font(.system(size: titleSize, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(price)
                        .font(.system(size: priceSize, weight: .bold))
                        .foregroundColor(orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(subtitle)
                        .font(.system(size: subtitleSize, weight: .semibold))
                        .foregroundColor(.black.opacity(0.82))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer()

                if let badge {
                    Text(badge)
                        .font(.system(size: badgeTextSize, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, min(max(screenWidth * 0.022, 8), 11))
                        .padding(.vertical, min(max(screenHeight * 0.006, 4), 6))
                        .background(orange)
                        .cornerRadius(9)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Circle()
                    .stroke(isSelected ? orange : Color.gray.opacity(0.35), lineWidth: 2)
                    .frame(width: checkSize, height: checkSize)
                    .overlay(
                        Circle()
                            .fill(isSelected ? orange : Color.clear)
                            .frame(width: checkSize * 0.52, height: checkSize * 0.52)
                    )
            }
            .padding(cardPadding)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.94) : Color.white.opacity(0.64))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isSelected ? orange.opacity(0.55) : Color.black.opacity(0.05), lineWidth: 1.2)
            )
            .cornerRadius(cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let orange: Color
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let scale: CGFloat
    let isCompact: Bool

    var body: some View {
        let iconCircleSize = min(max(screenWidth * 0.125, 46), 60)
        let iconSize = min(max(iconCircleSize * 0.45, 20), 27)

        let horizontalPadding = min(max(screenWidth * 0.038, 14), 18)
        let verticalPadding = min(max(screenHeight * 0.014, 11), 17)
        let cornerRadius = min(max(screenWidth * 0.05, 19), 23)

        let titleSize = min(max(17 * scale, 15), 19)
        let subtitleSize = min(max(13.5 * scale, 12), 15)

        HStack(spacing: min(max(screenWidth * 0.034, 12), 16)) {
            Circle()
                .fill(orange.opacity(0.13))
                .frame(width: iconCircleSize, height: iconCircleSize)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(orange)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: titleSize, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(subtitle)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.64))
        .cornerRadius(cornerRadius)
    }
}
