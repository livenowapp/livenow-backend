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

    private let privacyURL = URL(string: "https://www.livenowapp.net/privacy")!
    private let termsURL = URL(string: "https://www.livenowapp.net/terms")!

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.84), 1.12)
            let scale = min(widthScale, heightScale)

            let isCompact = screenHeight < 780
            let isVeryCompact = screenHeight < 720

            let horizontalPadding = min(screenWidth * 0.06, 24)
            let topPadding = min(screenHeight * 0.025, 18)

            let closeSize = min(max(screenWidth * 0.095, 36), 44)

            let logoSize = isVeryCompact
                ? min(max(screenWidth * 0.17, 58), 76)
                : min(max(screenWidth * 0.21, 72), 104)

            let titleSize = min(max(32 * scale, 26), 38)
            let subtitleSize = min(max(15.5 * scale, 13), 18)

            let headerSpacing = min(max(screenHeight * 0.014, 8), 16)

            let featureSpacing = min(max(screenHeight * 0.009, 6), 10)
            let planSpacing = min(max(screenHeight * 0.010, 7), 11)

            let buttonTextSize = min(max(17 * scale, 15), 19)
            let buttonVerticalPadding = isVeryCompact
                ? min(max(screenHeight * 0.016, 11), 14)
                : min(max(screenHeight * 0.019, 13), 18)

            ZStack {
                Color(red: 0.97, green: 0.96, blue: 0.94)
                    .ignoresSafeArea()

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

                    Spacer().frame(height: isVeryCompact ? 4 : 10)

                    Image("LogoCircle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)

                    Spacer().frame(height: headerSpacing)

                    VStack(spacing: min(screenHeight * 0.007, 8)) {
                        Text("unlock LiveNow")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Text("reset your mind anytime & save your progress.")
                            .font(.system(size: subtitleSize))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                    }
                    .padding(.horizontal, horizontalPadding)

                    Spacer()

                    VStack(spacing: featureSpacing) {
                        PaywallFeatureRow(
                            icon: "brain.head.profile",
                            title: "Reset whenever you need",
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

                    Spacer()

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

                    Spacer().frame(height: min(max(screenHeight * 0.017, 10), 20))

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

                    Spacer().frame(height: min(max(screenHeight * 0.009, 6), 10))

                    Button(action: onRestore) {
                        Text("restore purchase")
                            .font(.system(size: min(max(15 * scale, 13), 16), weight: .medium))
                            .foregroundColor(orange)
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: min(max(screenHeight * 0.008, 5), 9))

                    HStack(spacing: 6) {
                        Link(destination: privacyURL) {
                            Text("Privacy Policy")
                                .font(.system(size: min(max(12.5 * scale, 11), 14)))
                                .foregroundColor(.gray)
                        }

                        Text("•")
                            .font(.system(size: min(max(12.5 * scale, 11), 14)))
                            .foregroundColor(.gray.opacity(0.6))

                        Link(destination: termsURL) {
                            Text("Terms of Use")
                                .font(.system(size: min(max(12.5 * scale, 11), 14)))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
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
        let cardPadding = isCompact
            ? min(max(screenWidth * 0.028, 10), 13)
            : min(max(screenWidth * 0.034, 12), 16)

        let cornerRadius = min(max(screenWidth * 0.046, 18), 22)

        let titleSize = min(max(15 * scale, 14), 17)
        let priceSize = min(max(22 * scale, 19), 26)
        let subtitleSize = min(max(13 * scale, 12), 15)

        let badgeTextSize = min(max(10 * scale, 8.5), 11)
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
                        .minimumScaleFactor(0.82)

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
                        .padding(.horizontal, min(max(screenWidth * 0.020, 7), 10))
                        .padding(.vertical, min(max(screenHeight * 0.005, 4), 6))
                        .background(orange)
                        .cornerRadius(9)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
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
        let iconCircleSize = isCompact
            ? min(max(screenWidth * 0.125, 46), 58)
            : min(max(screenWidth * 0.145, 54), 68)

        let iconSize = min(max(iconCircleSize * 0.50, 23), 34)

        let horizontalPadding = min(max(screenWidth * 0.036, 13), 17)

        let verticalPadding = isCompact
            ? min(max(screenHeight * 0.013, 10), 15)
            : min(max(screenHeight * 0.017, 14), 20)

        let cornerRadius = min(max(screenWidth * 0.05, 19), 23)

        let titleSize = min(max(17 * scale, 15), 19)
        let subtitleSize = min(max(13.5 * scale, 11.5), 15)

        HStack(spacing: min(max(screenWidth * 0.032, 11), 15)) {
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
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
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
