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
    @ScaledMetric private var bodySize: CGFloat = 15
    @ScaledMetric private var buttonSize: CGFloat = 18

    private let examples = [
        "they think I’m weird",
        "I said something stupid",
        "I’m not good enough"
    ]

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.06, 28)
            let topPadding = min(max(geo.size.height * 0.028, 22), 26)
            let editorHeight = min(max(geo.size.height * 0.18, 170), 220)
            let buttonVerticalPadding = min(geo.size.height * 0.022, 17)
            let bottomSpacing = min(geo.size.height * 0.025, 22)

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

                        Spacer().frame(height: min(geo.size.height * 0.055, 48))

                        FlowTitleHeader(
                            title: "what’s on\nyour mind?",
                            subtitle: "write freely, no filter."
                        )
                        .frame(maxWidth: .infinity, alignment: .center)

                        Spacer().frame(height: min(max(geo.size.height * 0.02, 12), 24))

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.55))

                            TextEditor(text: $vm.thought)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .padding(18)
                                .font(.system(size: 18))
                                .foregroundColor(.black.opacity(0.82))

                            if vm.thought.isEmpty {
                                Text("type your thought...")
                                    .foregroundColor(.black.opacity(0.30))
                                    .autocorrectionDisabled()
                                    .font(.system(size: 18))
                                    .padding(.top, 25)
                                    .padding(.leading, 24)
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(height: editorHeight)

                        Spacer().frame(height: 30)

                        Text("examples")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)

                        Spacer().frame(height: 12)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(examples, id: \.self) { example in
                                Button {
                                    vm.thought = example
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: "bubble.left")
                                            .font(.system(size: 18))
                                            .foregroundColor(.orange)

                                        Text(example)
                                            .font(.system(size: 15))
                                            .foregroundColor(.black.opacity(0.72))

                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.55))
                                    .cornerRadius(16)
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

                        Spacer().frame(height: 28)
                    }
                }
                .frame(maxHeight: .infinity)
                
                HStack(spacing: 7){
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
                    HStack(spacing: 12) {
                        if vm.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
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

// MARK: - THINKING

struct ThinkingScreen: View {
    let orange: Color
    var onBack: () -> Void

    @State private var activeIndex = 0
    @State private var pulse = false
    @State private var dots = ""

    private let steps = [
        "Analyzing your thought",
        "Finding thinking patterns",
        "Checking the evidence",
        "Creating realistic reframes",
        "Finding a small next step"
    ]

    @ScaledMetric private var titleSize: CGFloat = 29
    @ScaledMetric private var bodySize: CGFloat = 15

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.06, 28)
            let topPadding = min(max(geo.size.height * 0.028, 22), 26)

            VStack(alignment: .leading, spacing: 0) {

                HStack(spacing: 14) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                    
                }
                .padding(.top, topPadding)

                Spacer()

                VStack(spacing: 26) {
                    ZStack {
                        Circle()
                            .fill(orange.opacity(0.10))
                            .frame(width: 122, height: 122)
                            .scaleEffect(pulse ? 1.12 : 0.92)
                            .opacity(pulse ? 0.45 : 0.9)

                        Circle()
                            .fill(orange.opacity(0.16))
                            .frame(width: 90, height: 90)

                        Image(systemName: "sparkles")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundColor(orange)
                    }

                    VStack(spacing: 6) {

                        Text("your thought")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(.black)

                        Text("is being analyzed\(dots)")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(orange)

                        Text("we’re turning it into something clearer")
                            .font(.system(size: bodySize))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(index <= activeIndex ? orange.opacity(0.14) : Color.white.opacity(0.7))
                                        .frame(width: 30, height: 30)

                                    if index < activeIndex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(orange)
                                    } else if index == activeIndex {
                                        ProgressView()
                                            .scaleEffect(0.65)
                                            .tint(orange)
                                    } else {
                                        Circle()
                                            .fill(Color.gray.opacity(0.25))
                                            .frame(width: 7, height: 7)
                                    }
                                }

                                Text(step)
                                    .font(.system(size: 15, weight: index == activeIndex ? .semibold : .regular))
                                    .foregroundColor(index <= activeIndex ? .black.opacity(0.82) : .gray)

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(index == activeIndex ? 0.82 : 0.55))
                            .cornerRadius(16)
                        }
                    }
                }

                Spacer()

                Text("AI-generated reflection. Not professional advice.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, horizontalPadding)
            .onAppear {
                pulse = true
                startDots()
                startSteps()
            }
            .animation(
                .easeInOut(duration: 1.25)
                .repeatForever(autoreverses: true),
                value: pulse
            )
        }
    }

    private func startDots() {
        Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in
            if dots.count >= 3 {
                dots = ""
            } else {
                dots += "."
            }
        }
    }

    private func startSteps() {
        Timer.scheduledTimer(withTimeInterval: 1.35, repeats: true) { timer in
            if activeIndex < steps.count - 1 {
                activeIndex += 1
            } else {
                timer.invalidate()
            }
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
            let topPadding = min(max(geo.size.height * 0.028, 22), 26)
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
            let topPadding = min(max(geo.size.height * 0.028, 22), 26)
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

                        /*
                         Text("choose one that feels true:")
                            .font(.system(size: bodySize))
                            .foregroundColor(.gray)

                        Spacer().frame(height: optionSpacing)
                         */

                        VStack(spacing: optionSpacing) {
                            ForEach(Array((ai?.reframes ?? []).enumerated()), id: \.offset) { index, line in
                                Button {
                                    vm.selectedReframeIndex = index
                                } label: {
                                    HStack(alignment: .center, spacing: 14) {
                                        Image(systemName: vm.selectedReframeIndex == index ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 24, weight: .regular))
                                            .foregroundColor(vm.selectedReframeIndex == index ? orange : Color.gray.opacity(0.35))

                                        Text(line)
                                            .font(.system(size: 17, weight: vm.selectedReframeIndex == index ? .semibold : .regular))
                                            .foregroundColor(.black.opacity(0.86))
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)

                                        Spacer()
                                    }
                                    .padding(cardPadding)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(vm.selectedReframeIndex == index ? Color.white : Color.white.opacity(0.55))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(vm.selectedReframeIndex == index ? orange.opacity(0.35) : Color.black.opacity(0.05), lineWidth: 1)
                                    )
                                    .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Spacer()
                        
                        Text("Choose the response that feels most believable right now.")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
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
            let topPadding = min(max(geo.size.height * 0.028, 22), 26)
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
                                        Image(systemName: vm.selectedActionIndex == index ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 24, weight: .regular))
                                            .foregroundColor(vm.selectedActionIndex == index ? orange : Color.gray.opacity(0.35))

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
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)

                                        Spacer()
                                    }                                    .padding(.horizontal, 14)
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

// MARK: - COMPLETE

struct CompleteScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    let lightOrange: Color
    var onClose: () -> Void
    var onNewReset: () -> Void

    @State private var animateComplete = false
    @State private var particles: [SparkleParticle] = []

    @ScaledMetric private var iconCircleSize: CGFloat = 142
    @ScaledMetric private var titleSize: CGFloat = 32
    @ScaledMetric private var buttonSize: CGFloat = 18
    @ScaledMetric private var logoSize: CGFloat = 24
    @ScaledMetric private var topButtonSize: CGFloat = 40

    var body: some View {
        GeometryReader { geo in
            let selectedAction = vm.aiResponse?.actions.indices.contains(vm.selectedActionIndex) == true
            ? vm.aiResponse?.actions[vm.selectedActionIndex]
            : nil

            let horizontalPadding = min(geo.size.width * 0.06, 24)
            let topPadding = min(geo.size.height * 0.025, 18)
            let iconSize = min(iconCircleSize, geo.size.width * 0.38)
            let sectionSpacing = min(geo.size.height * 0.025, 20)
            let buttonVerticalPadding = min(geo.size.height * 0.022, 17)
            let bottomSpacing = min(geo.size.height * 0.025, 20)

            VStack(spacing: 0) {
                header(
                    horizontalPadding: horizontalPadding,
                    topPadding: topPadding
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: sectionSpacing) {
                        completeAnimation(iconSize: iconSize)
                            .padding(.top, min(geo.size.height * 0.04, 32))

                        titleSection

                        nextStepCard(selectedAction: selectedAction)

                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 18)
                }
                .frame(maxHeight: .infinity)

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
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: 12)
                
                Button(action: {
                    vm.step = .home
                    vm.currentTab = .moments
                }) {
                    Text("view moments")
                        .font(.system(size: 16))
                        .foregroundColor(orange)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: bottomSpacing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                particles = SparkleParticle.makeParticles(iconSize: iconSize)

                withAnimation(.spring(response: 0.38, dampingFraction: 0.58)) {
                    animateComplete = true
                }
            }
        }
    }

    private func header(horizontalPadding: CGFloat, topPadding: CGFloat) -> some View {
        ZStack {
            Text("LiveNow")
                .font(.system(size: logoSize, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack {
                Spacer()

                Button("Done") {
                    onClose()
                }
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(orange)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: topButtonSize)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }

    private func completeAnimation(iconSize: CGFloat) -> some View {
        ZStack {
            ForEach(particles) { particle in
                CompleteSparkle(
                    particle: particle,
                    orange: orange,
                    iconSize: iconSize
                )
            }

            Circle()
                .fill(
                    LinearGradient(
                        colors: [lightOrange, orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: iconSize, height: iconSize)
                .shadow(color: orange.opacity(0.32), radius: 22, x: 0, y: 12)
                .scaleEffect(animateComplete ? 1.0 : 0.72)

            Image(systemName: "checkmark")
                .font(.system(size: iconSize * 0.37, weight: .medium))
                .foregroundColor(.white)
                .scaleEffect(animateComplete ? 1.0 : 0.4)
                .opacity(animateComplete ? 1 : 0)
        }
        .frame(width: iconSize * 2.35, height: iconSize * 2.05)
        .frame(maxWidth: .infinity)
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("you’re back in control")
                .font(.system(size: titleSize, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            Text("keep going")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func nextStepCard(selectedAction: AIActionItem?) -> some View {
        HStack(alignment: .center, spacing: 14) {
            if let selectedAction {
                Circle()
                    .fill(ActionStyle.color(selectedAction.icon))
                    .frame(width: 64, height: 64)
                    .overlay(
                        MomentIconImage(
                            icon: ActionStyle.iconName(selectedAction.icon),
                            size: 58
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("your next step")
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.48))

                if let selectedAction {
                    Text(selectedAction.label)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("do this now, before your mind pulls you back in")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("take one small action now")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black.opacity(0.82))
                }
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .cornerRadius(18)
    }
}

// MARK: - COMPLETE SPARKLES

struct SparkleParticle: Identifiable {
    let id = UUID()
    let size: CGFloat
    let startDelay: Double

    static func makeParticles(iconSize: CGFloat) -> [SparkleParticle] {
        (0..<14).map { index in
            SparkleParticle(
                size: CGFloat.random(in: 10...20),
                startDelay: Double(index) * 0.18
            )
        }
    }
}

struct CompleteSparkle: View {
    let particle: SparkleParticle
    let orange: Color
    let iconSize: CGFloat
    
    @State private var x: CGFloat = 0
    @State private var y: CGFloat = 0
    @State private var scale: CGFloat = 0.2
    @State private var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: particle.size, weight: .medium))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.34, blue: 0.05),
                        orange
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .offset(x: x, y: y)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + particle.startDelay) {
                    animateLoop()
                }
            }
    }
    
    private func animateLoop() {
        let angle = Double.random(in: 0...(Double.pi * 2))
        
        let startDistance = CGFloat.random(in: iconSize * 0.45...iconSize * 0.58)
        let endDistance = CGFloat.random(in: iconSize * 0.85...iconSize * 1.45)
        
        let startX = cos(angle) * startDistance
        let startY = sin(angle) * startDistance
        
        let endX = cos(angle) * endDistance
        let endY = sin(angle) * endDistance
        
        let duration = Double.random(in: 0.85...1.25)
        let pause = Double.random(in: 0.25...0.85)
        
        x = startX
        y = startY
        scale = 0.55
        opacity = 0
        
        withAnimation(.easeOut(duration: 0.12)) {
            opacity = 1.0
            scale = 0.85
        }
        
        withAnimation(.easeOut(duration: duration)) {
            x = endX
            y = endY
            scale = 1.15
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + pause) {
            animateLoop()
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
