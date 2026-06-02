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

    @ScaledMetric private var titleSize: CGFloat = 31
    @ScaledMetric private var subtitleSize: CGFloat = 15
    @ScaledMetric private var buttonSize: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.018, 16)
            let logoSize = min(geo.size.width * 0.32, 125)
            let buttonVerticalPadding = min(geo.size.height * 0.019, 16)

            VStack(spacing: 0) {

                HStack {
                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.75))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                Spacer(minLength: 4)

                Image("LogoPaywall")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .shadow(color: orange.opacity(0.20), radius: 14, x: 0, y: 7)

                Spacer().frame(height: min(geo.size.height * 0.018, 14))

                VStack(spacing: 7) {
                    Text("unlock LiveNow")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("reset your mind anytime, save your progress,\nand build calmer patterns.")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }

                Spacer().frame(height: min(geo.size.height * 0.020, 16))

                VStack(spacing: 9) {
                    PaywallFeatureRow(
                        icon: "brain.head.profile",
                        title: "Unlimited resets",
                        subtitle: "Analyze thoughts whenever your mind feels stuck.",
                        orange: orange
                    )

                    PaywallFeatureRow(
                        icon: "sparkles",
                        title: "Personal reframes",
                        subtitle: "Get calmer, more realistic thoughts back.",
                        orange: orange
                    )

                    PaywallFeatureRow(
                        icon: "calendar",
                        title: "Moment history",
                        subtitle: "Save your resets and track your growth.",
                        orange: orange
                    )

                    PaywallFeatureRow(
                        icon: "chart.bar",
                        title: "Personal insights",
                        subtitle: "Discover patterns behind your overthinking.",
                        orange: orange
                    )
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: min(geo.size.height * 0.014, 12))

                VStack(spacing: 10) {
                    PaywallPlanCard(
                        title: "LiveNow Yearly",
                        price: "€49.99 / year",
                        subtitle: "Save 68%",
                        badge: "MOST POPULAR",
                        isSelected: selectedPlan == .yearly,
                        orange: orange
                    ) {
                        selectedPlan = .yearly
                    }

                    PaywallPlanCard(
                        title: "LiveNow Weekly",
                        price: "€2.99 / week",
                        subtitle: "Cancel anytime",
                        badge: nil,
                        isSelected: selectedPlan == .weekly,
                        orange: orange
                    ) {
                        selectedPlan = .weekly
                    }
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: min(geo.size.height * 0.014, 12))

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

                Spacer().frame(height: 9)

                Button(action: onRestore) {
                    Text("restore purchase")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(orange)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: 7)

                Text("AI-generated reflection. Not professional advice.")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 8)
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)

                        Text(price)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(orange)

                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    if let badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(orange)
                            .cornerRadius(9)
                    }

                    Circle()
                        .stroke(isSelected ? orange : Color.gray.opacity(0.35), lineWidth: 2)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .fill(isSelected ? orange : Color.clear)
                                .frame(width: 12, height: 12)
                        )
                }
            }
            .padding(14)
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

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(orange.opacity(0.13))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(orange)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15.5, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 12.5))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer()
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.62))
        .cornerRadius(17)
    }
}
