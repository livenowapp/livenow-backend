//
//  FlowScreens.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

// MARK: - INPUT

struct InputScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    var onBack: () -> Void
    var onAnalyze: () -> Void

    @ScaledMetric private var titleSize: CGFloat = 29
    @ScaledMetric private var bodySize: CGFloat = 14
    @ScaledMetric private var buttonSize: CGFloat = 18

    private let examples = [
        "they think I’m weird",
        "I said something stupid",
        "I’m not good enough"
    ]

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.06, 28)
            let topPadding = min(geo.size.height * 0.03, 24)
            let titleTopSpacing = min(geo.size.height * 0.045, 36)
            let editorHeight = min(max(geo.size.height * 0.22, 130), 240)
            let buttonVerticalPadding = min(geo.size.height * 0.022, 17)
            let bottomSpacing = min(geo.size.height * 0.025, 20)

            VStack(alignment: .leading, spacing: 0) {
                TopProgressRow(
                    stepText: "1 of 4",
                    progress: 0.25,
                    orange: orange,
                    onBack: onBack
                )
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: titleTopSpacing)

                        FlowTitleHeader(
                            title: "what’s on\nyour mind?",
                            subtitle: "write freely, no filter."
                        )

                        Spacer().frame(height: min(geo.size.height * 0.03, 22))

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.55))

                            TextEditor(text: $vm.thought)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .padding(12)
                                .font(.system(size: 15))

                            if vm.thought.isEmpty {
                                Text("type your thought...")
                                    .foregroundColor(.black.opacity(0.35))
                                    .autocorrectionDisabled()
                                    .font(.system(size: 15))
                                    .padding(.top, 20)
                                    .padding(.leading, 18)
                            }
                        }
                        .frame(height: editorHeight)

                        Spacer().frame(height: 16)

                        Text("examples")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.45))

                        Spacer().frame(height: 10)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(examples, id: \.self) { example in
                                Button {
                                    vm.thought = example
                                } label: {
                                    Text(example)
                                        .font(.system(size: 13))
                                        .foregroundColor(.black.opacity(0.65))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.white.opacity(0.7))
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if let errorMessage = vm.errorMessage {
                            Spacer().frame(height: 12)

                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.red.opacity(0.8))
                        }

                        Spacer().frame(height: 24)
                    }
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    Text("AI-generated reflection. Not professional advice.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)

                Button(action: onAnalyze) {
                    HStack(spacing: 10) {

                        if vm.isLoading {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(vm.isLoading ? "analyzing..." : "analyze")
                            .font(.system(size: buttonSize, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, buttonVerticalPadding)
                    .background(orange)
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .disabled(vm.isLoading || vm.thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer().frame(height: bottomSpacing)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}

// MARK: - ANALYZE

struct AnalyzeScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    var onBack: () -> Void
    var onContinue: () -> Void

    @ScaledMetric private var buttonSize: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let ai = vm.aiResponse

            let horizontalPadding = min(geo.size.width * 0.06, 28)
            let topPadding = min(geo.size.height * 0.03, 24)
            let titleTopSpacing = min(geo.size.height * 0.045, 36)
            let sectionSpacing = min(geo.size.height * 0.026, 22)
            let cardSpacing = min(geo.size.height * 0.018, 16)
            let cardPadding = min(geo.size.width * 0.055, 22)
            let buttonVerticalPadding = min(geo.size.height * 0.022, 17)
            let bottomSpacing = min(geo.size.height * 0.025, 20)

            VStack(alignment: .leading, spacing: 0) {

                TopProgressRow(
                    stepText: "2 of 4",
                    progress: 0.50,
                    orange: orange,
                    onBack: onBack
                )
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 0) {

                        Spacer()
                            .frame(height: titleTopSpacing)

                        FlowTitleHeader(
                            title: "let’s analyze\nthis thought",
                            subtitle: "this helps you see clearly."
                        )

                        Spacer()
                            .frame(height: sectionSpacing)

                        VStack(alignment: .leading, spacing: 12) {

                            Text("your thought")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.black.opacity(0.45))

                            Text(vm.thought)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(orange)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(cardPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color(red: 0.95, green: 0.89, blue: 0.84)
                        )
                        .cornerRadius(22)

                        Spacer()
                            .frame(height: cardSpacing)

                        VStack(spacing: cardSpacing) {

                            ForEach(Array((ai?.analysis ?? []).prefix(3).enumerated()), id: \.offset) { index, item in
                                AnalysisCard(
                                    title: item.label,
                                    subtitle: item.sub,
                                    icon: analysisIcon(for: index),
                                    orange: orange
                                )
                            }
                        }

                        Spacer()
                            .frame(height: sectionSpacing)

                        VStack(alignment: .leading, spacing: 14) {

                            Text("evidence check")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.black.opacity(0.55))

                            VStack(spacing: 0) {

                                ForEach(Array((ai?.evidence ?? []).enumerated()), id: \.offset) { index, item in

                                    VStack(spacing: 0) {

                                        EvidenceRow(
                                            question: item.q,
                                            answer: item.a
                                        )

                                        if index < (ai?.evidence.count ?? 0) - 1 {

                                            Divider()
                                                .opacity(0.12)
                                                .padding(.horizontal, 18)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(22)
                        }

                        Spacer()
                            .frame(height: 28)
                    }
                }
                .frame(maxHeight: .infinity)

                Button(action: onContinue) {

                    Text("continue")
                        .font(.system(size: buttonSize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, buttonVerticalPadding)
                        .background(orange)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)

                Spacer()
                    .frame(height: bottomSpacing)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }

    private func analysisIcon(for index: Int) -> String {

        switch index {

        case 0:
            return "magnifyingglass"

        case 1:
            return "brain.head.profile"

        case 2:
            return "heart"

        default:
            return "sparkles"
        }
    }
}

// MARK: - REFRAME

struct ReframeScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    var onBack: () -> Void
    var onContinue: () -> Void

    @ScaledMetric private var titleSize: CGFloat = 29
    @ScaledMetric private var bodySize: CGFloat = 14
    @ScaledMetric private var buttonSize: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let ai = vm.aiResponse

            let horizontalPadding = min(geo.size.width * 0.06, 28)
            let topPadding = min(geo.size.height * 0.03, 24)
            let titleTopSpacing = min(geo.size.height * 0.045, 36)
            let mediumSpacing = min(geo.size.height * 0.03, 24)
            let optionSpacing = min(geo.size.height * 0.018, 14)
            let cardPadding = min(geo.size.width * 0.05, 20)
            let buttonVerticalPadding = min(geo.size.height * 0.022, 17)
            let bottomSpacing = min(geo.size.height * 0.025, 20)

            VStack(alignment: .leading, spacing: 0) {
                TopProgressRow(
                    stepText: "3 of 4",
                    progress: 0.75,
                    orange: orange,
                    onBack: onBack
                )
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: titleTopSpacing)

                        FlowTitleHeader(
                            title: "let’s reframe\nthis",
                            subtitle: "here’s a more realistic view"
                        )

                        Spacer().frame(height: mediumSpacing)

                        Text("choose one that feels true:")
                            .font(.system(size: bodySize))
                            .foregroundColor(.gray)

                        Spacer().frame(height: optionSpacing)

                        VStack(spacing: optionSpacing) {
                            ForEach(Array((ai?.reframes ?? []).enumerated()), id: \.offset) { index, line in
                                Button {
                                    vm.selectedReframeIndex = index
                                } label: {
                                    Text(line)
                                        .font(.system(size: 17, weight: vm.selectedReframeIndex == index ? .semibold : .regular))
                                        .foregroundColor(.black.opacity(0.86))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(cardPadding)
                                        .background(vm.selectedReframeIndex == index ? Color.white : Color.white.opacity(0.55))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(vm.selectedReframeIndex == index ? orange.opacity(0.35) : Color.black.opacity(0.05), lineWidth: 1)
                                        )
                                        .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }

                            if let ai, ai.reframes.indices.contains(vm.selectedReframeIndex) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "brain")
                                        .font(.system(size: 22))
                                        .foregroundColor(orange)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("reminder")
                                            .font(.system(size: 12))
                                            .foregroundColor(.black.opacity(0.5))

                                        Text(ai.reframes[vm.selectedReframeIndex])
                                            .font(.system(size: 14))
                                            .foregroundColor(.black.opacity(0.75))
                                    }

                                    Spacer()
                                }
                                .padding(cardPadding)
                                .background(Color.white.opacity(0.52))
                                .cornerRadius(16)
                            }

                            Spacer().frame(height: 24)
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                Button(action: onContinue) {
                    Text("continue")
                        .font(.system(size: buttonSize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, buttonVerticalPadding)
                        .background(orange)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: bottomSpacing)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}

// MARK: - ACTION

struct ActionScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    var onBack: () -> Void
    var onFinish: () -> Void

    @ScaledMetric private var titleSize: CGFloat = 29
    @ScaledMetric private var bodySize: CGFloat = 14
    @ScaledMetric private var buttonSize: CGFloat = 18
    @ScaledMetric private var checkSize: CGFloat = 20
    @ScaledMetric private var iconSize: CGFloat = 60

    var body: some View {
        GeometryReader { geo in
            let actions = vm.aiResponse?.actions ?? []

            let horizontalPadding = min(geo.size.width * 0.06, 28)
            let topPadding = min(geo.size.height * 0.03, 24)
            let titleTopSpacing = min(geo.size.height * 0.045, 36)
            let mediumSpacing = min(geo.size.height * 0.03, 24)
            let itemSpacing = min(geo.size.height * 0.018, 12)
            let buttonVerticalPadding = min(geo.size.height * 0.022, 17)
            let bottomSpacing = min(geo.size.height * 0.025, 20)

            VStack(alignment: .leading, spacing: 0) {
                TopProgressRow(
                    stepText: "4 of 4",
                    progress: 1.0,
                    orange: orange,
                    onBack: onBack
                )
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: titleTopSpacing)

                        FlowTitleHeader(
                            title: "what’s one small\nstep you can take\nnow?",
                            subtitle: "shift your focus"
                        )

                        Spacer().frame(height: mediumSpacing)

                        VStack(spacing: itemSpacing) {
                            ForEach(Array(actions.enumerated()), id: \.offset) { index, item in
                                Button {
                                    vm.selectedActionIndex = index
                                } label: {
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(ActionStyle.color(item.icon))
                                            .frame(width: iconSize, height: iconSize)
                                            .overlay(
                                                MomentIconImage(
                                                    icon: ActionStyle.iconName(item.icon),
                                                    size: iconSize * 0.76
                                                )
                                            )

                                        Text(item.label)
                                            .font(.system(size: 15))
                                            .foregroundColor(.black.opacity(0.82))

                                        Spacer()

                                        if vm.selectedActionIndex == index {
                                            Circle()
                                                .fill(orange)
                                                .frame(width: checkSize, height: checkSize)
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .background(vm.selectedActionIndex == index ? Color.white.opacity(0.82) : Color.white.opacity(0.54))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(vm.selectedActionIndex == index ? orange.opacity(0.45) : Color.black.opacity(0.05), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Spacer().frame(height: 24)
                    }
                }
                .frame(maxHeight: .infinity)

                Button(action: onFinish) {
                    Text("finish")
                        .font(.system(size: buttonSize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, buttonVerticalPadding)
                        .background(orange)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: bottomSpacing)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}

// MARK: - COMPLETE

struct CompleteScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    let lightOrange: Color
    var onClose: () -> Void
    var onNewReset: () -> Void

    @ScaledMetric private var closeButtonSize: CGFloat = 40
    @ScaledMetric private var iconCircleSize: CGFloat = 118
    @ScaledMetric private var titleSize: CGFloat = 32
    @ScaledMetric private var buttonSize: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let selectedAction = vm.aiResponse?.actions.indices.contains(vm.selectedActionIndex) == true
            ? vm.aiResponse?.actions[vm.selectedActionIndex]
            : nil

            let horizontalPadding = min(geo.size.width * 0.06, 26)
            let topPadding = min(geo.size.height * 0.03, 22)
            let iconSize = min(iconCircleSize, geo.size.width * 0.32)
            let sectionSpacing = min(geo.size.height * 0.035, 28)
            let smallSpacing = min(geo.size.height * 0.015, 12)
            let buttonVerticalPadding = min(geo.size.height * 0.022, 17)

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: onClose) {
                        Circle()
                            .stroke(Color.black.opacity(0.12), lineWidth: 1.3)
                            .frame(width: closeButtonSize, height: closeButtonSize)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black.opacity(0.65))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: smallSpacing)

                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [lightOrange, orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: iconSize, height: iconSize)
                                .shadow(color: orange.opacity(0.28), radius: 18, x: 0, y: 10)

                            Image(systemName: "checkmark")
                                .font(.system(size: iconSize * 0.35, weight: .medium))
                                .foregroundColor(.white)

                            SparkleView(offsetX: -iconSize * 0.5, offsetY: -iconSize * 0.3, orange: orange)
                            SparkleView(offsetX: iconSize * 0.55, offsetY: -iconSize * 0.1, orange: orange)
                            SparkleView(offsetX: -iconSize * 0.65, offsetY: iconSize * 0.08, orange: orange)
                            SparkleView(offsetX: iconSize * 0.35, offsetY: -iconSize * 0.45, orange: orange)
                        }

                        Spacer().frame(height: sectionSpacing)

                        Text("reset complete")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Spacer().frame(height: smallSpacing)

                        VStack(spacing: 4) {
                            Text("you’re back in control.")
                            Text("keep going.")
                        }
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)

                        Spacer().frame(height: sectionSpacing)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("reflection")
                                .font(.system(size: 12))
                                .foregroundColor(.black.opacity(0.48))

                            if let selectedAction {
                                Text("you challenged the thought\nand chose action:\n\(selectedAction.label)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black.opacity(0.78))
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Text("you challenged the thought\nand chose action.\nthat’s progress.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black.opacity(0.78))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)

                        Spacer().frame(height: sectionSpacing)

                        Button(action: onNewReset) {
                            Text("new reset")
                                .font(.system(size: buttonSize, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, buttonVerticalPadding)
                                .background(orange)
                                .cornerRadius(16)
                        }
                        .buttonStyle(.plain)

                        Spacer().frame(height: smallSpacing)

                        Button(action: {
                            vm.step = .home
                            vm.currentTab = .moments
                        }) {
                            Text("view moments")
                                .font(.system(size: 16))
                                .foregroundColor(orange)
                        }
                        .buttonStyle(.plain)

                        Spacer().frame(height: sectionSpacing)
                    }
                    .padding(.horizontal, horizontalPadding)
                }
            }
        }
    }
}
struct FlowTitleHeader: View {
    let title: String
    let subtitle: String

    @ScaledMetric private var titleSize: CGFloat = 35
    @ScaledMetric private var subtitleSize: CGFloat = 14

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: titleSize, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .top)

            Text(subtitle)
                .font(.system(size: subtitleSize))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
