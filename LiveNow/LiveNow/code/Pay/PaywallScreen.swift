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
            let isCompact = geo.size.height < 780
            let isVeryCompact = geo.size.height < 720
            let bottomFlexibleSpace: CGFloat = geo.size.height > 900 ? 26 : (geo.size.height > 840 ? 14 : 6)

            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding: CGFloat = isVeryCompact ? 2 : 6
            let logoSize: CGFloat = isVeryCompact ? 68 : (isCompact ? 86 : 108)
            let titleSize: CGFloat = isVeryCompact ? 27 : (isCompact ? 29 : 31)
            let subtitleSize: CGFloat = isVeryCompact ? 13 : 15
            let buttonSize: CGFloat = 18
            let buttonVerticalPadding: CGFloat = isVeryCompact ? 13 : 15

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.75))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                Image("LogoPaywall")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .padding(.top, isVeryCompact ? -18 : -12)

                Spacer().frame(height: isVeryCompact ? 8 : (isCompact ? 14 : 18))

                VStack(spacing: isVeryCompact ? 4 : 7) {
                    Text("unlock LiveNow")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("reset your mind anytime, save your progress,\nand build calmer patterns.")
                        .font(.system(size: isCompact ? 14 : subtitleSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer().frame(height: isVeryCompact ? 10 : (isCompact ? 16 : 22))

                VStack(spacing: isVeryCompact ? 5 : (isCompact ? 8 : 10)) {
                    PaywallFeatureRow(
                        icon: "brain.head.profile",
                        title: "Unlimited resets",
                        subtitle: "Analyze thoughts whenever your mind feels stuck.",
                        orange: orange,
                        isCompact: isCompact
                    )

                    PaywallFeatureRow(
                        icon: "sparkles",
                        title: "Personal reframes",
                        subtitle: "Get calmer, more realistic thoughts back.",
                        orange: orange,
                        isCompact: isCompact
                    )

                    /*
                    PaywallFeatureRow(
                        icon: "calendar",
                        title: "Moment history",
                        subtitle: "Save your resets and track your growth.",
                        orange: orange,
                        isCompact: isCompact
                    )
                    */

                    PaywallFeatureRow(
                        icon: "chart.bar",
                        title: "Personal insights",
                        subtitle: "Discover patterns behind your overthinking.",
                        orange: orange,
                        isCompact: isCompact
                    )
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: isVeryCompact ? 8 : 10)

                VStack(spacing: isVeryCompact ? 6 : (isCompact ? 8 : 10)) {
                    PaywallPlanCard(
                        title: "LiveNow Yearly",
                        price: "€49.99 / year",
                        subtitle: "Save 68%",
                        badge: "MOST POPULAR",
                        isSelected: selectedPlan == .yearly,
                        orange: orange,
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
                        isCompact: isCompact
                    ) {
                        selectedPlan = .weekly
                    }
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: isVeryCompact ? 8 : 10)

                Button {
                    onSubscribe(selectedPlan)
                } label: {
                    Text("continue")
                        .font(.system(size: buttonSize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, buttonVerticalPadding)
                        .background(orange)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: isVeryCompact ? 5 : 8)

                Button(action: onRestore) {
                    Text("restore purchase")
                        .font(.system(size: isVeryCompact ? 13 : 15, weight: .medium))
                        .foregroundColor(orange)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: isVeryCompact ? 4 : 6)

                Text("AI-generated reflection. Not professional advice.")
                    .font(.system(size: isVeryCompact ? 9.5 : 11))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer()
                    .frame(height: bottomFlexibleSpace)
            }
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
    let isCompact: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
                    Text(title)
                        .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                        .foregroundColor(.black)

                    Text(price)
                        .font(.system(size: isCompact ? 20 : 22, weight: .bold))
                        .foregroundColor(orange)

                    Text(subtitle)
                        .font(.system(size: isCompact ? 11 : 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                if let badge {
                    Text(badge)
                        .font(.system(size: isCompact ? 9 : 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, isCompact ? 7 : 9)
                        .padding(.vertical, isCompact ? 4 : 5)
                        .background(orange)
                        .cornerRadius(9)
                }

                Circle()
                    .stroke(isSelected ? orange : Color.gray.opacity(0.35), lineWidth: 2)
                    .frame(width: isCompact ? 20 : 22, height: isCompact ? 20 : 22)
                    .overlay(
                        Circle()
                            .fill(isSelected ? orange : Color.clear)
                            .frame(width: isCompact ? 10 : 12, height: isCompact ? 10 : 12)
                    )
            }
            .padding(isCompact ? 10 : 11)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.92) : Color.white.opacity(0.62))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? orange.opacity(0.55) : Color.black.opacity(0.05), lineWidth: 1.2)
            )
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let orange: Color
    let isCompact: Bool

    var body: some View {
        HStack(spacing: isCompact ? 12 : 14) {
            Circle()
                .fill(orange.opacity(0.13))
                .frame(width: isCompact ? 44 : 52, height: isCompact ? 44 : 52)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 20 : 23, weight: .medium))
                        .foregroundColor(orange)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: isCompact ? 16 : 17, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: isCompact ? 12.5 : 13.5))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()
        }
        .padding(.horizontal, isCompact ? 13 : 15)
        .padding(.vertical, isCompact ? 10 : 14)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.62))
        .cornerRadius(20)
    }
}
