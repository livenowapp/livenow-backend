//
//  SharedComponents.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI

// MARK: - TAB BAR

struct BottomTabBar: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
   // let onTabInteraction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            TabItem(
                icon: "house",
                label: "home",
                tab: .home,
                vm: vm,
                orange: orange,
             //   onTap: onTabInteraction
            )

            TabItem(
                icon: "sparkles",
                label: "moments",
                tab: .moments,
                vm: vm,
                orange: orange,
             //   onTap: onTabInteraction
            )

            TabItem(
                icon: "chart.bar",
                label: "insights",
                tab: .insights,
                vm: vm,
                orange: orange,
             //   onTap: onTabInteraction
            )

            TabItem(
                icon: "person",
                label: "profile",
                tab: .profile,
                vm: vm,
                orange: orange,
             //   onTap: onTabInteraction
            )
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color.white)
        .overlay(
            Divider(),
            alignment: .top
        )
    }
}

struct TabItem: View {
    let icon: String
    let label: String
    let tab: MainTab

    @ObservedObject var vm: AppViewModel
    let orange: Color
    //let onTap: () -> Void

    @ScaledMetric private var iconSize: CGFloat = 18
    @ScaledMetric private var labelSize: CGFloat = 11

    var body: some View {
        Button {
           // onTap()

            if vm.isGuestUser && vm.hasCompletedGuestReset {
                switch tab {
                case .moments, .insights:
                    vm.requestPremiumAccess()
                    return

                case .home, .profile:
                    break
                }
            }

            vm.currentTab = tab

        } label: {

            VStack(spacing: 4) {

                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .regular))

                Text(label)
                    .font(.system(size: labelSize, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(vm.currentTab == tab ? orange : .gray)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct LiveNowTopHeader<TrailingContent: View>: View {
    let horizontalPadding: CGFloat
    let trailingContent: TrailingContent

    @ScaledMetric private var logoSize: CGFloat = 24

    init(
        horizontalPadding: CGFloat,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.horizontalPadding = horizontalPadding
        self.trailingContent = trailingContent()
    }

    var body: some View {
        ZStack {
            Text("LiveNow")
                .font(.system(size: logoSize, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack {
                Spacer()

                trailingContent
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 16)
    }
}

extension LiveNowTopHeader where TrailingContent == EmptyView {
    init(horizontalPadding: CGFloat) {
        self.init(horizontalPadding: horizontalPadding) {
            EmptyView()
        }
    }
}

struct OutcomeButton: View {
    let title: String
    let selected: Bool
    let color: Color
    let action: () -> Void

    @ScaledMetric private var textSize: CGFloat = 14

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: textSize, weight: .semibold))
                .foregroundColor(selected ? .white : color)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? color : Color.white.opacity(0.7))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct TopProgressRow: View {
    let stepText: String
    let progress: CGFloat
    let orange: Color
    let showBackButton: Bool
    var onBack: () -> Void

    @ScaledMetric private var iconSize: CGFloat = 18
    @ScaledMetric private var stepSize: CGFloat = 13

    var body: some View {
        HStack(spacing: 14) {
            if showBackButton {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: iconSize, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
                    .frame(width: 32, height: 32)
            }

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.08))
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(orange)
                            .frame(width: geo.size.width * progress, height: 4)
                    }
                }

            Text(stepText)
                .font(.system(size: stepSize))
                .foregroundColor(.black.opacity(0.65))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 46, alignment: .trailing)
        }
    }
}

struct EvidenceRow: View {
    let question: String
    let answer: String

    @ScaledMetric private var textSize: CGFloat = 14

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(question)
                .font(.system(size: textSize))
                .foregroundColor(.black.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(answer)
                .font(.system(size: textSize))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

struct AnalysisCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let orange: Color

    @ScaledMetric private var iconCircleSize: CGFloat = 56
    @ScaledMetric private var iconSize: CGFloat = 24
    @ScaledMetric private var titleSize: CGFloat = 18
    @ScaledMetric private var subtitleSize: CGFloat = 14

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: iconCircleSize, height: iconCircleSize)

                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(orange)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

struct SparkleView: View {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let orange: Color

    @ScaledMetric private var sparkleSize: CGFloat = 12

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: sparkleSize))
            .foregroundColor(orange)
            .offset(x: offsetX, y: offsetY)
    }
}


