//
//  FlowScreens.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI

// MARK: - RESPONSIVE HELPERS

private func screenScales(_ geo: GeometryProxy) -> (
    width: CGFloat,
    height: CGFloat,
    scale: CGFloat
) {
    let widthScale = min(max(geo.size.width / 393, 0.88), 1.16)
    let heightScale = min(max(geo.size.height / 852, 0.88), 1.12)

    return (
        widthScale,
        heightScale,
        min(widthScale, heightScale)
    )
}

// MARK: - INPUT

struct InputScreen: View {
    @ObservedObject var vm: AppViewModel

    let orange: Color

    var onBack: () -> Void
    var onAnalyze: () -> Void

    @ScaledMetric private var titleSize: CGFloat = 29
    @ScaledMetric private var bodySize: CGFloat = 15
    @ScaledMetric private var buttonSize: CGFloat = 18

    @FocusState private var isThoughtFocused: Bool

    @State private var stableScreenHeight: CGFloat?

    private let examples = [
        "why haven’t they replied to my message?",
        "what if I embarrassed myself in front of everyone?",
        "what if I made the wrong decision?"
    ]

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width

            // Height ostane enak tudi ko se odpre keyboard.
            let screenHeight = stableScreenHeight ?? geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)

            let horizontalPadding = min(screenWidth * 0.06, 28)
            let topPadding = min(max(screenHeight * 0.025, 18), 24)
            let titleTopSpacing = min(max(screenHeight * 0.04, 26), 42)
            let editorHeight = min(max(screenHeight * 0.19, 150), 220)
            let buttonVerticalPadding = min(max(screenHeight * 0.02, 13), 17)
            let bottomSpacing = min(max(screenHeight * 0.018, 12), 22)

            let editorFontSize = 18 * scale
            let exampleTextSize = 15 * scale
            let avatarSize = min(max(screenWidth * 0.31, 105), 130)

            ZStack(alignment: .bottom) {

                // MARK: - FIXED SCREEN CONTENT

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Progress

                    TopProgressRow(
                        stepText: "1 of 4",
                        progress: 0.25,
                        orange: orange,
                        showBackButton: true,
                        onBack: {
                            isThoughtFocused = false
                            onBack()
                        }
                    )
                    .padding(.top, topPadding)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {

                            Spacer()
                                .frame(height: titleTopSpacing)

                            // MARK: Title

                            VStack(alignment: .leading, spacing: 8) {
                                Text("what’s on\nyour mind?")
                                    .font(
                                        .system(
                                            size: titleSize,
                                            weight: .bold
                                        )
                                    )
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )

                                Text("write freely, no filter.")
                                    .font(.system(size: bodySize))
                                    .foregroundColor(.gray)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isThoughtFocused = false
                            }

                            Spacer()
                                .frame(
                                    height: min(
                                        max(screenHeight * 0.025, 18),
                                        28
                                    )
                                )

                            // MARK: Thought editor + avatar

                            ZStack(alignment: .topTrailing) {
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.55))

                                    TextEditor(text: $vm.thought)
                                        .focused($isThoughtFocused)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .padding(
                                            min(
                                                max(
                                                    screenWidth * 0.045,
                                                    14
                                                ),
                                                18
                                            )
                                        )
                                        .font(
                                            .system(
                                                size: editorFontSize
                                            )
                                        )
                                        .foregroundColor(
                                            .black.opacity(0.82)
                                        )

                                    if vm.thought.isEmpty {
                                        Text("type your thought...")
                                            .foregroundColor(
                                                .black.opacity(0.30)
                                            )
                                            .autocorrectionDisabled()
                                            .font(
                                                .system(
                                                    size: editorFontSize
                                                )
                                            )
                                            .padding(.top, 25)
                                            .padding(.leading, 24)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .frame(height: editorHeight)

                                // MARK: Thinking avatar

                                Image("avatar_think")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: avatarSize,
                                        height: avatarSize
                                    )
                                    .offset(
                                        x: -12,
                                        y: -avatarSize * 0.80
                                    )
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }

                            Spacer()
                                .frame(
                                    height: min(
                                        max(screenHeight * 0.025, 18),
                                        30
                                    )
                                )
                            
                            // MARK: Input guidance

                            if let guidanceMessage = vm.inputGuidanceMessage {

                                HStack(alignment: .top, spacing: 10) {

                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(orange)

                                    Text(guidanceMessage)
                                        .font(.system(size: 13))
                                        .foregroundColor(.black.opacity(0.62))
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )

                                    Spacer()
                                }
                                .padding(14)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .background(
                                    Color.white.opacity(0.65)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            orange.opacity(0.14),
                                            lineWidth: 1
                                        )
                                }
                                .cornerRadius(14)

                                Spacer()
                                    .frame(
                                        height: min(
                                            max(screenHeight * 0.022, 16),
                                            24
                                        )
                                    )
                            }

                            // MARK: Examples title

                            Text("examples")
                                .font(
                                    .system(
                                        size: 15 * scale,
                                        weight: .medium
                                    )
                                )
                                .foregroundColor(.gray)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isThoughtFocused = false
                                }

                            Spacer()
                                .frame(
                                    height: min(
                                        max(screenHeight * 0.012, 8),
                                        12
                                    )
                                )

                            // MARK: Examples

                            VStack(
                                alignment: .leading,
                                spacing: min(
                                    max(screenHeight * 0.012, 8),
                                    12
                                )
                            ) {
                                ForEach(examples, id: \.self) { example in
                                    Button {
                                        isThoughtFocused = false
                                        vm.thought = example
                                    } label: {
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(
                                                    Color.orange.opacity(
                                                        0.12
                                                    )
                                                )
                                                .frame(
                                                    width: 44,
                                                    height: 44
                                                )
                                                .overlay(
                                                    Image("cloud")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(
                                                            width: 32,
                                                            height: 32
                                                        )
                                                )

                                            Text(example)
                                                .font(
                                                    .system(
                                                        size:
                                                            exampleTextSize
                                                    )
                                                )
                                                .foregroundColor(
                                                    .black.opacity(0.72)
                                                )

                                            Spacer()
                                        }
                                        .padding(
                                            .horizontal,
                                            min(max(screenWidth * 0.045,  16),20)
                                        )
                                        .padding(
                                            .vertical,
                                            min(max(screenHeight * 0.014, 11),14)
                                        )
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            Color.white.opacity(0.55)
                                        )
                                        .cornerRadius(16)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // MARK: Error

                            if let errorMessage = vm.errorMessage {
                                Spacer()
                                    .frame(height: 12)

                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(
                                        .red.opacity(0.8)
                                    )
                            }

                            // Pustimo prostor za spodnji del screena.
                            Spacer()
                                .frame(height: 120)
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .frame(maxHeight: .infinity)

                    // MARK: Disclaimer

                    HStack(spacing: 7) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)

                        Text(
                            "AI-generated reflection. Not professional advice."
                        )
                        .font(.system(size: 12 * scale))
                        .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isThoughtFocused = false
                    }

                    // Ko keyboard NI odprt, tukaj pustimo prostor za gumb.
                    if !isThoughtFocused {
                        Spacer()
                            .frame(
                                height:
                                    buttonVerticalPadding * 2
                                    + buttonSize
                                    + bottomSpacing
                                    + 8
                            )
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .ignoresSafeArea(.keyboard, edges: .bottom)

                // MARK: - ANALYZE BUTTON

                VStack(spacing: 0) {
                    Button {
                        isThoughtFocused = false
                        onAnalyze()
                    } label: {
                        HStack(spacing: 12) {
                            if vm.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(
                                        .system(
                                            size: buttonSize,
                                            weight: .semibold
                                        )
                                    )
                                    .foregroundColor(.white)
                            }

                            Text(
                                vm.isLoading
                                    ? "analyzing..."
                                    : "analyze"
                            )
                            .font(
                                .system(
                                    size: buttonSize,
                                    weight: .semibold
                                )
                            )
                            .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(
                            .vertical,
                            buttonVerticalPadding
                        )
                        .background(orange)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        vm.isLoading ||
                        vm.thought
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )

                    Spacer()
                        .frame(height: bottomSpacing)
                }
                .padding(.horizontal, horizontalPadding)
            }
            .onAppear {
                if stableScreenHeight == nil {
                    stableScreenHeight = geo.size.height
                }
            }
        }
    }
}

// MARK: - THINKING

struct ThinkingScreen: View {
    let orange: Color
    var onBack: () -> Void
    @ObservedObject var vm: AppViewModel
    
    @State private var activeIndex = 0
    @State private var stepTask: Task<Void, Never>?
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
    @ScaledMetric private var iconSize: CGFloat = 18
    
    var body: some View {
        GeometryReader { geo in
            let scales = screenScales(geo)
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let horizontalPadding = min(screenWidth * 0.06, 28)
            let topPadding = min(max(screenHeight * 0.025, 18), 24)
            
            let avatarSize = min(max(screenWidth * 0.36, 125), 155)
            
            let titleFont = titleSize * scales.scale
            let bodyFont = bodySize * scales.scale
            let stepFont = min(max(screenWidth * 0.038, 14), 16)
            let stepPaddingY = min(max(screenHeight * 0.012, 9), 12)
            
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(
                                .system(
                                    size: iconSize,
                                    weight: .regular
                                )
                            )
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.top, topPadding)

                Spacer()
                    
                VStack(spacing: min(max(screenHeight * 0.028, 22), 28)) {
                    
                    // MARK: Computer avatar
                    
                    Image("avatar_computer")
                        .resizable()
                        .scaledToFit()
                        .frame(width: avatarSize, height: avatarSize)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    
                    VStack(spacing: 6) {
                        Text("your thought")
                            .font(.system(size: titleFont, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("is being analyzed\(dots)")
                            .font(.system(size: titleFont, weight: .bold))
                            .foregroundColor(orange)
                        
                        Text("this may take a few seconds")
                            .font(.system(size: bodyFont))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .multilineTextAlignment(.center)
                    
                    VStack(spacing: min(max(screenHeight * 0.012, 9), 12)) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            index <= activeIndex
                                            ? orange.opacity(0.14)
                                            : Color.white.opacity(0.7)
                                        )
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
                                    .font(
                                        .system(
                                            size: stepFont,
                                            weight: index == activeIndex
                                            ? .semibold
                                            : .regular
                                        )
                                    )
                                    .foregroundColor(
                                        index <= activeIndex
                                        ? .black.opacity(0.82)
                                        : .gray
                                    )
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, stepPaddingY)
                            .background(
                                Color.white.opacity(
                                    index == activeIndex ? 0.82 : 0.55
                                )
                            )
                            .cornerRadius(16)
                        }
                    }
                }
                
                Spacer()
                
                Text("AI-generated reflection. Not professional advice.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(
                        .bottom,
                        min(max(screenHeight * 0.02, 14), 20)
                    )
            }
            .padding(.horizontal, horizontalPadding)
            .onAppear {
                startDots()
                startRealisticSteps()
            }
            .onDisappear {
                stepTask?.cancel()
                stepTask = nil
            }
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
    
    private func startRealisticSteps() {
        stepTask?.cancel()
        
        stepTask = Task { @MainActor in
            activeIndex = 0
            
            let delays: [UInt64] = [
                900_000_000,
                1_100_000_000,
                1_400_000_000,
                1_600_000_000
            ]
            
            for index in 1..<steps.count {
                let delay = delays[min(index - 1, delays.count - 1)]
                
                try? await Task.sleep(nanoseconds: delay)
                
                guard !Task.isCancelled else {
                    return
                }
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    activeIndex = index
                }
            }
        }
    }
}
    
    // MARK: - SAFETY MESSAGE CARD
    
    struct SafetyMessageCard: View {
        let level: String
        let message: String
        let orange: Color
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black.opacity(0.84))
                    
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.62))
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                
                Spacer()
            }
            .padding(16)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(Color.white.opacity(0.82))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        borderColor,
                        lineWidth: 1
                    )
            }
            .cornerRadius(16)
        }
        
        private var title: String {
            switch level {
            case "urgent":
                return "please get support now"
            case "elevated":
                return "a little extra support may help"
            default:
                return "support"
            }
        }
        
        private var iconName: String {
            switch level {
            case "urgent":
                return "exclamationmark.triangle.fill"
            case "elevated":
                return "heart.fill"
            default:
                return "heart"
            }
        }
        
        private var iconColor: Color {
            switch level {
            case "urgent":
                return .red
            case "elevated":
                return orange
            default:
                return orange
            }
        }
        
        private var iconBackground: Color {
            switch level {
            case "urgent":
                return Color.red.opacity(0.10)
            case "elevated":
                return orange.opacity(0.10)
            default:
                return orange.opacity(0.10)
            }
        }
        
        private var borderColor: Color {
            switch level {
            case "urgent":
                return Color.red.opacity(0.18)
            case "elevated":
                return orange.opacity(0.16)
            default:
                return Color.black.opacity(0.05)
            }
        }
    }
    
// MARK: - URGENT SAFETY

struct UrgentSafetyScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    var onClose: () -> Void
    
    @ScaledMetric private var titleSize: CGFloat = 32
    @ScaledMetric private var bodySize: CGFloat = 16
    @ScaledMetric private var buttonSize: CGFloat = 18
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let horizontalPadding = min(screenWidth * 0.06, 28)
            let iconSize = min(max(screenWidth * 0.20, 72), 88)
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image("avatar_heart")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: iconSize * 1.6,
                                height: iconSize * 1.6
                            )
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                        
                        VStack(spacing: 10) {
                            Text("you deserve real support right now")
                                .font(.system(size: titleSize, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("LiveNow isn't designed to handle immediate danger or a crisis.")
                                .font(.system(size: bodySize))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        if let message = vm.aiResponse?.safety.message,
                           !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                                
                                Text(message)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black.opacity(0.76))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.85))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        Color.red.opacity(0.16),
                                        lineWidth: 1
                                    )
                            }
                            .cornerRadius(18)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            safetyRow(
                                icon: "person.2.fill",
                                text: "Tell someone you trust what is happening and stay with someone if you can."
                            )
                            
                            safetyRow(
                                icon: "cross.case.fill",
                                text: "If you may act on these thoughts or are in immediate danger, contact local emergency or crisis support now."
                            )
                            
                            safetyRow(
                                icon: "location.fill",
                                text: "Move away from anything that could put you or someone else in danger."
                            )
                        }
                        
                        Text("AI-generated information is not a substitute for emergency or professional care.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 30)
                }
                
                Button {
                    onClose()
                } label: {
                    Text("back to home")
                        .font(.system(size: buttonSize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(orange)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                Spacer()
                    .frame(height: 16)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    private func safetyRow(
        icon: String,
        text: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(orange)
            }
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(15)
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
    }
}

// MARK: - ANALYZE

struct AnalyzeScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    var onBack: () -> Void
    var onContinue: () -> Void
    
    @ScaledMetric private var titleSize: CGFloat = 29
    @ScaledMetric private var bodySize: CGFloat = 15
    @ScaledMetric private var iconCircleSize: CGFloat = 56
    @ScaledMetric private var buttonSize: CGFloat = 18
    @ScaledMetric private var cardRadius: CGFloat = 22
    
    var body: some View {
        GeometryReader { geo in
            let ai = vm.aiResponse
            let scales = screenScales(geo)
            
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let horizontalPadding = min(screenWidth * 0.06, 28)
            let topPadding = min(max(screenHeight * 0.025, 18), 24)
            let titleTopSpacing = min(max(screenHeight * 0.04, 26), 42)
            let sectionSpacing = min(max(screenHeight * 0.024, 16), 22)
            let cardSpacing = min(max(screenHeight * 0.016, 12), 16)
            let cardPadding = min(max(screenWidth * 0.052, 18), 22)
            let buttonVerticalPadding = min(max(screenHeight * 0.02, 13), 17)
            let bottomSpacing = min(max(screenHeight * 0.018, 12), 20)
            let avatarSize = min(max(screenWidth * 0.31, 105), 130)
            let mediumSpacing = min(max(screenHeight * 0.026, 18), 24)
            
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                
                // MARK: Progress
                
                TopProgressRow(
                    stepText: "2 of 4",
                    progress: 0.50,
                    orange: orange,
                    showBackButton: true,
                    onBack: onBack
                )
                .padding(.top, topPadding)
                
                ScrollView(
                    showsIndicators: false
                ) {
                    
                    VStack(
                        alignment: .leading, spacing: 0) {
                            
                            Spacer() .frame(height: titleTopSpacing)
                            
                            // MARK: Title
                            
                            VStack(
                                alignment: .leading, spacing: 8) {
                                    
                                    Text("let’s analyze\nthis thought")
                                        .font(
                                            .system(size: titleSize, weight: .bold)
                                        )
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                    
                                    Text("this helps you see clearly.")
                                        .font(
                                            .system(size: bodySize)
                                        )
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            
                            Spacer()
                                .frame(
                                    height: min(
                                        max(screenHeight * 0.035, 24),
                                        34
                                    )
                                )
                            
                            
                            
                            // MARK: Thought card + analyze avatar
                            
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(ai?.shortTitle ?? vm.thought)
                                        .font(
                                            .system(
                                                size: min(
                                                    max(screenWidth * 0.058, 22),
                                                    26
                                                ),
                                                weight: .bold
                                            )
                                        )
                                        .foregroundColor(orange)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    HStack(alignment: .center, spacing: 14) {
                                        Circle()
                                            .fill(Color.white.opacity(0.85))
                                            .frame(
                                                width: iconCircleSize,
                                                height: iconCircleSize
                                            )
                                            .overlay(
                                                Image("cloud")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 42, height: 42)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 7) {
                                            Text("your thought:")
                                                .font(
                                                    .system(
                                                        size: 15 * scales.scale,
                                                        weight: .semibold
                                                    )
                                                )
                                                .foregroundColor(.black.opacity(0.78))
                                            
                                            Text(vm.thought)
                                                .font(
                                                    .system(
                                                        size: min(
                                                            max(screenWidth * 0.036, 13),
                                                            15
                                                        )
                                                    )
                                                )
                                                .foregroundColor(.black.opacity(0.48))
                                                .lineLimit(2)
                                                .minimumScaleFactor(0.85)
                                        }
                                    }
                                }
                                .padding(cardPadding)
                                .padding(.top, avatarSize * 0.05)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    Color(
                                        red: 0.95,
                                        green: 0.89,
                                        blue: 0.84
                                    )
                                )
                                .cornerRadius(cardRadius)
                                
                                // MARK: Analyze avatar
                                
                                Image("avatar_analyze")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: avatarSize,
                                        height: avatarSize
                                    )
                                    .offset(
                                        x: -12,
                                        y: -avatarSize * 0.72
                                    )
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                            
                            Spacer()
                                .frame(height: mediumSpacing)
                            
                            // MARK: Safety
                            
                            if let safety = ai?.safety,
                               safety.level != "normal",
                               let message = safety.message,
                               !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                
                                HStack(alignment: .top, spacing: 12) {
                                    Image(
                                        systemName: safety.level == "urgent"
                                        ? "exclamationmark.triangle.fill"
                                        : "heart.fill"
                                    )
                                    .font(.system(size: 18))
                                    .foregroundColor(orange)
                                    
                                    Text(message)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black.opacity(0.78))
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.82))
                                .cornerRadius(16)
                                
                                Spacer()
                                    .frame(height: mediumSpacing)
                            }
                            
                            // MARK: Analysis cards
                            
                            VStack(spacing: cardSpacing) {
                                ForEach(
                                    Array(
                                        (ai?.analysis ?? [])
                                            .prefix(3)
                                            .enumerated()
                                    ),
                                    id: \.offset
                                ) { index, item in
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
                            
                            // MARK: Evidence
                            
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Ask yourself")
                                    .font(
                                        .system(
                                            size: 15 * scales.scale,
                                            weight: .medium
                                        )
                                    )
                                    .foregroundColor(.black.opacity(0.55))
                                
                                VStack(spacing: 0) {
                                    ForEach(
                                        Array((ai?.evidence ?? []).enumerated()),
                                        id: \.offset
                                    ) { index, item in
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
                                .cornerRadius(cardRadius)
                            }
                            
                            Spacer()
                                .frame(height: 28)
                        }
                }
                .frame(maxHeight: .infinity)
                
                // MARK: Continue button
                
                Button(action: onContinue) {
                    Text("continue")
                        .font(
                            .system(
                                size: buttonSize,
                                weight: .semibold
                            )
                        )
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
            return "brain"
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
    @ScaledMetric private var bodySize: CGFloat = 15
    @ScaledMetric private var buttonSize: CGFloat = 18
    @ScaledMetric private var cardRadius: CGFloat = 22
    
    var body: some View {
        GeometryReader { geo in
            let ai = vm.aiResponse
            let scales = screenScales(geo)
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let horizontalPadding = min(screenWidth * 0.06, 28)
            let topPadding = min(max(screenHeight * 0.025, 18), 24)
            let titleTopSpacing = min(max(screenHeight * 0.04, 26), 42)
            let optionSpacing = min(max(screenHeight * 0.014, 10), 14)
            let cardPadding = min(max(screenWidth * 0.048, 16), 20)
            let buttonVerticalPadding = min(max(screenHeight * 0.02, 13), 17)
            let bottomSpacing = min(max(screenHeight * 0.018, 12), 20)
            let avatarSize = min(max(screenWidth * 0.27, 92), 115)
            let mediumSpacing = min(max(screenHeight * 0.026, 18), 24)
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: Progress
                
                TopProgressRow(
                    stepText: "3 of 4",
                    progress: 0.75,
                    orange: orange,
                    showBackButton: true,
                    onBack: onBack
                )
                .padding(.top, topPadding)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Spacer()
                            .frame(height: titleTopSpacing)
                        
                        // MARK: Title
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("let’s reframe\nthis")
                                .font(.system(size: titleSize, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("here’s a more realistic view")
                                .font(.system(size: bodySize))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                            .frame(
                                height: min(
                                    max(screenHeight * 0.035, 24),
                                    34
                                )
                            )
                        
                        // MARK: Calm card + avatar
                        
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text("a calmer perspective")
                                    .font(
                                        .system(
                                            size: min(
                                                max(screenWidth * 0.058, 22),
                                                26
                                            ),
                                            weight: .bold
                                        )
                                    )
                                    .foregroundColor(orange)
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                                
                                Text("See the thought from a calmer angle.")
                                    .font(
                                        .system(
                                            size: min(
                                                max(screenWidth * 0.036, 13),
                                                15
                                            )
                                        )
                                    )
                                    .foregroundColor(.black.opacity(0.48))
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                                    .padding(.trailing, avatarSize * 0.68)
                            }
                            .padding(cardPadding)
                            .padding(.top, avatarSize * 0.05)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(
                                Color(
                                    red: 0.95,
                                    green: 0.89,
                                    blue: 0.84
                                )
                            )
                            .cornerRadius(cardRadius)
                            
                            Image("avatar_calm")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: avatarSize,
                                    height: avatarSize
                                )
                                .offset(
                                    x: -12,
                                    y: -avatarSize * 0.72
                                )
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                        
                        Spacer()
                            .frame(height: mediumSpacing)
                        
                        // MARK: Reframe options
                        
                        VStack(spacing: optionSpacing) {
                            ForEach(
                                Array((ai?.reframes ?? []).enumerated()),
                                id: \.offset
                            ) { index, line in
                                
                                Button {
                                    vm.selectedReframeIndex = index
                                } label: {
                                    HStack(alignment: .center, spacing: 14) {
                                        Image(
                                            systemName:
                                                vm.selectedReframeIndex == index
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                        )
                                        .font(
                                            .system(
                                                size: min(
                                                    max(screenWidth * 0.058, 22),
                                                    25
                                                ),
                                                weight: .regular
                                            )
                                        )
                                        .foregroundColor(
                                            vm.selectedReframeIndex == index
                                            ? orange
                                            : Color.gray.opacity(0.35)
                                        )
                                        
                                        Text(line)
                                            .font(
                                                .system(
                                                    size: min(
                                                        max(screenWidth * 0.041, 15.5),
                                                        18
                                                    ),
                                                    weight:
                                                        vm.selectedReframeIndex == index
                                                    ? .semibold
                                                    : .regular
                                                )
                                            )
                                            .foregroundColor(.black.opacity(0.86))
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(
                                                horizontal: false,
                                                vertical: true
                                            )
                                        
                                        Spacer()
                                    }
                                    .padding(cardPadding)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    .background(
                                        vm.selectedReframeIndex == index
                                        ? Color.white
                                        : Color.white.opacity(0.55)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                vm.selectedReframeIndex == index
                                                ? orange.opacity(0.35)
                                                : Color.black.opacity(0.05),
                                                lineWidth: 1
                                            )
                                    )
                                    .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Text(
                            "Choose the response that feels most believable right now."
                        )
                        .font(
                            .system(
                                size: 15 * scales.scale,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                        
                        Spacer()
                            .frame(height: 28)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // MARK: Continue button
                
                Button(action: onContinue) {
                    Text("continue")
                        .font(
                            .system(
                                size: buttonSize,
                                weight: .semibold
                            )
                        )
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
}

// MARK: - ACTION

struct ActionScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    var onBack: () -> Void
    var onFinish: () -> Void
    
    @ScaledMetric private var titleSize: CGFloat = 29
    @ScaledMetric private var bodySize: CGFloat = 15
    @ScaledMetric private var buttonSize: CGFloat = 18
    @ScaledMetric private var cardRadius: CGFloat = 22
    
    var body: some View {
        GeometryReader { geo in
            let actions = vm.aiResponse?.actions ?? []
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let horizontalPadding = min(screenWidth * 0.06, 28)
            let topPadding = min(max(screenHeight * 0.025, 18), 24)
            let titleTopSpacing = min(max(screenHeight * 0.04, 26), 42)
            let mediumSpacing = min(max(screenHeight * 0.026, 18), 24)
            let itemSpacing = min(max(screenHeight * 0.012, 9), 12)
            let cardPadding = min(max(screenWidth * 0.048, 16), 20)
            let buttonVerticalPadding = min(max(screenHeight * 0.02, 13), 17)
            let bottomSpacing = min(max(screenHeight * 0.018, 12), 20)
            let actionIconSize = min(max(screenWidth * 0.14, 52), 62)
            let avatarSize = min(max(screenWidth * 0.27, 92), 115)
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: Progress
                
                TopProgressRow(
                    stepText: "4 of 4",
                    progress: 1.0,
                    orange: orange,
                    showBackButton: true,
                    onBack: onBack
                )
                .padding(.top, topPadding)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Spacer()
                            .frame(height: titleTopSpacing)
                        
                        // MARK: Title
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("what’s one small step\nyou can take now?")
                                .font(.system(size: titleSize, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("shift your focus")
                                .font(.system(size: bodySize))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                            .frame(
                                height: min(
                                    max(screenHeight * 0.035, 24),
                                    34
                                )
                            )
                        
                        // MARK: Action card + avatar
                        
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text("one small step")
                                    .font(
                                        .system(
                                            size: min(
                                                max(screenWidth * 0.058, 22),
                                                26
                                            ),
                                            weight: .bold
                                        )
                                    )
                                    .foregroundColor(orange)
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                                
                                Text("Choose one small thing you can do now.")
                                    .font(
                                        .system(
                                            size: min(
                                                max(screenWidth * 0.036, 13),
                                                15
                                            )
                                        )
                                    )
                                    .foregroundColor(.black.opacity(0.48))
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                                    .padding(.trailing, avatarSize * 0.68)
                            }
                            .padding(cardPadding)
                            .padding(.top, avatarSize * 0.05)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(
                                Color(
                                    red: 0.95,
                                    green: 0.89,
                                    blue: 0.84
                                )
                            )
                            .cornerRadius(cardRadius)
                            
                            Image("avatar_actionWalk")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: avatarSize,
                                    height: avatarSize
                                )
                                .offset(
                                    x: -12,
                                    y: -avatarSize * 0.72
                                )
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                        
                        Spacer()
                            .frame(height: mediumSpacing)
                        
                        // MARK: Actions
                        
                        VStack(spacing: itemSpacing) {
                            ForEach(
                                Array(actions.enumerated()),
                                id: \.offset
                            ) { index, item in
                                
                                Button {
                                    vm.selectedActionIndex = index
                                } label: {
                                    HStack(spacing: 14) {
                                        
                                        Image(
                                            systemName:
                                                vm.selectedActionIndex == index
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                        )
                                        .font(
                                            .system(
                                                size: min(
                                                    max(screenWidth * 0.058, 22),
                                                    25
                                                ),
                                                weight: .regular
                                            )
                                        )
                                        .foregroundColor(
                                            vm.selectedActionIndex == index
                                            ? orange
                                            : Color.gray.opacity(0.35)
                                        )
                                        
                                        Circle()
                                            .fill(
                                                ActionStyle.color(item.icon)
                                            )
                                            .frame(
                                                width: actionIconSize,
                                                height: actionIconSize
                                            )
                                            .overlay(
                                                MomentIconImage(
                                                    icon:
                                                        ActionStyle.iconName(
                                                            item.icon
                                                        ),
                                                    size:
                                                        actionIconSize * 0.76
                                                )
                                            )
                                        
                                        Text(item.label)
                                            .font(
                                                .system(
                                                    size: min(
                                                        max(screenWidth * 0.038, 14),
                                                        16
                                                    )
                                                )
                                            )
                                            .foregroundColor(
                                                .black.opacity(0.82)
                                            )
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(
                                                horizontal: false,
                                                vertical: true
                                            )
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(
                                        .vertical,
                                        min(
                                            max(screenHeight * 0.014, 11),
                                            14
                                        )
                                    )
                                    .background(
                                        vm.selectedActionIndex == index
                                        ? Color.white.opacity(0.82)
                                        : Color.white.opacity(0.54)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                vm.selectedActionIndex == index
                                                ? orange.opacity(0.45)
                                                : Color.black.opacity(0.05),
                                                lineWidth: 1
                                            )
                                    )
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 24)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // MARK: Finish
                
                Button(action: onFinish) {
                    Text("finish")
                        .font(
                            .system(
                                size: buttonSize,
                                weight: .semibold
                            )
                        )
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
}

// MARK: - COMPLETE

struct CompleteScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    let lightOrange: Color
    var onClose: () -> Void
    var onNewReset: () -> Void
    
    @FocusState private var isNoteFocused: Bool
    
    @State private var particles: [SparkleParticle] = []
    @State private var burstParticles: [FullScreenBurstParticle] = []
    
    @State private var showBurst = false
    @State private var showAvatar = false
    
    @ScaledMetric private var titleSize: CGFloat = 32
    @ScaledMetric private var buttonSize: CGFloat = 18
    
    var body: some View {
        GeometryReader { geo in
            let selectedAction =
            vm.aiResponse?.actions.indices.contains(vm.selectedActionIndex) == true
            ? vm.aiResponse?.actions[vm.selectedActionIndex]
            : nil
            
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let horizontalPadding = min(screenWidth * 0.06, 24)
            let avatarSize = min(max(screenWidth * 0.40, 145), 175)
            let sectionSpacing = min(max(screenHeight * 0.020, 14), 18)
            let buttonVerticalPadding = min(screenHeight * 0.022, 17)
            
            let bottomSpacing =
            screenHeight < 760
            ? 8
            : min(max(screenHeight * 0.018, 12), 22)
            
            ZStack {
                
                // MARK: Main content
                
                VStack(spacing: 0) {
                    header(horizontalPadding: horizontalPadding)
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: sectionSpacing) {
                            
                            completeAnimation(
                                avatarSize: avatarSize
                            )
                            .onTapGesture {
                                isNoteFocused = false
                            }
                            .padding(
                                .top,
                                min(screenHeight * 0.04, 32)
                            )
                            
                            titleSection
                                .onTapGesture {
                                    isNoteFocused = false
                                }
                            
                            nextStepCard(
                                selectedAction: selectedAction
                            )
                            .onTapGesture {
                                isNoteFocused = false
                            }
                            
                            learningNoteCard
                        }
                        
                        .padding(.horizontal, horizontalPadding)
                        
                        .padding(.bottom, 150)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .frame(maxHeight: .infinity)
                    
                    Button {
                        isNoteFocused = false
                        onNewReset()
                    } label: {
                        Text("New Reset")
                            .font(.system(size: buttonSize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, buttonVerticalPadding)
                            .background(orange)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, horizontalPadding)
                    
                    Spacer()
                        .frame(height: 12)
                    
                    Button {
                        isNoteFocused = false
                        vm.step = .home
                        vm.currentTab = .moments
                    } label: {
                        Text("view moments")
                            .font(.system(size: 16))
                            .foregroundColor(orange)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                        .frame(height: bottomSpacing)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                
                // MARK: Full screen BOOM
                
                if showBurst {
                    ZStack {
                        ForEach(burstParticles) { particle in
                            FullScreenBurstSparkle(
                                particle: particle,
                                orange: orange,
                                screenSize: geo.size
                            )
                        }
                        
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .stroke(
                                    orange.opacity(0.38),
                                    lineWidth: index == 0 ? 12 : 5
                                )
                                .frame(
                                    width: 90,
                                    height: 90
                                )
                                .scaleEffect(
                                    showBurst
                                    ? 7.5 + CGFloat(index) * 1.5
                                    : 0.15
                                )
                                .opacity(
                                    showBurst
                                    ? 0
                                    : 0.8
                                )
                                .animation(
                                    .easeOut(
                                        duration: 0.70
                                    ),
                                    value: showBurst
                                )
                        }
                    }
                    .frame(
                        width: screenWidth,
                        height: screenHeight
                    )
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                }
            }
            .onAppear {
                startCompleteAnimation(
                    screenSize: geo.size,
                    avatarSize: avatarSize
                )
            }
        }
    }
    
    // MARK: - START COMPLETE ANIMATION
    
    private func startCompleteAnimation(
        screenSize: CGSize,
        avatarSize: CGFloat
    ) {
        particles =
        SparkleParticle.makeParticles(
            iconSize: avatarSize
        )
        
        burstParticles =
        FullScreenBurstParticle.makeParticles(
            screenSize: screenSize
        )
        
        showAvatar = false
        showBurst = false
        
        // BOOM takoj
        DispatchQueue.main.async {
            showBurst = true
            
            withAnimation(
                .spring(
                    response: 0.40,
                    dampingFraction: 0.58
                )
            ) {
                showAvatar = true
            }
        }
    }
    
    // MARK: - HEADER
    
    private func header(
        horizontalPadding: CGFloat
    ) -> some View {
        LiveNowTopHeader(
            horizontalPadding: horizontalPadding
        ) {
            Button("Done") {
                isNoteFocused = false
                onClose()
            }
            .font(
                .system(
                    size: 17,
                    weight: .medium
                )
            )
            .foregroundColor(orange)
        }
    }
    
    // MARK: - AVATAR + CONTINUOUS SPARKLES
    
    private func completeAnimation(
        avatarSize: CGFloat
    ) -> some View {
        ZStack {
            
            // Sparkles ostanejo tudi po BOOM-u
            
            if showAvatar {
                ForEach(particles) { particle in
                    CompleteSparkle(
                        particle: particle,
                        orange: orange,
                        iconSize: avatarSize * 0.72
                    )
                }
            }
            
            // Super happy avatar
            
            Image("avatar_happy")
                .resizable()
                .scaledToFit()
                .frame(
                    width: avatarSize,
                    height: avatarSize
                )
                .scaleEffect(
                    showAvatar ? 1 : 0.15
                )
                .opacity(
                    showAvatar ? 1 : 0
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .frame(
            width: avatarSize * 2.0,
            height: avatarSize * 1.55
        )
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - TITLE
    
    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("saved to your journey")
                .font(
                    .system(
                        size: titleSize,
                        weight: .bold
                    )
                )
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("keep going")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - NEXT STEP CARD
    
    private func nextStepCard(
        selectedAction: AIActionItem?
    ) -> some View {
        HStack(
            alignment: .center,
            spacing: 14
        ) {
            if let selectedAction {
                Circle()
                    .fill(
                        ActionStyle.color(
                            selectedAction.icon
                        )
                    )
                    .frame(
                        width: 64,
                        height: 64
                    )
                    .overlay(
                        MomentIconImage(
                            icon:
                                ActionStyle.iconName(
                                    selectedAction.icon
                                ),
                            size: 58
                        )
                    )
            }
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                Text("your next step")
                    .font(.system(size: 12))
                    .foregroundColor(
                        .black.opacity(0.48)
                    )
                
                if let selectedAction {
                    Text(selectedAction.label)
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(
                            .black.opacity(0.82)
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                    
                    Text(
                        "do this now, before your mind pulls you back in"
                    )
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                } else {
                    Text(
                        "take one small action now"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(
                        .black.opacity(0.82)
                    )
                }
            }
            
            Spacer()
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.white.opacity(0.7)
        )
        .cornerRadius(18)
    }
    
    // MARK: - NOTE CARD
    
    private var learningNoteCard: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack(
                alignment: .center,
                spacing: 12
            ) {
                ZStack {
                    Circle()
                        .fill(
                            orange.opacity(0.12)
                        )
                        .frame(
                            width: 42,
                            height: 42
                        )
                    
                    Image(
                        systemName: "pencil"
                    )
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(orange)
                }
                
                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text("note")
                        .font(
                            .system(
                                size: 12,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.gray)
                    
                    Text(
                        "What did you learn?"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.black)
                }
                
                Spacer()
            }
            
            ZStack(
                alignment: .topLeading
            ) {
                if vm.completionNote.isEmpty {
                    Text(
                        "write a small note..."
                    )
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.top, 18)
                    .padding(.leading, 16)
                    .allowsHitTesting(false)
                }
                
                TextEditor(
                    text: Binding(
                        get: {
                            vm.completionNote
                        },
                        set: { newValue in
                            vm.updateCurrentCompletionNote(
                                newValue
                            )
                        }
                    )
                )
                .focused(
                    $isNoteFocused
                )
                .font(.system(size: 15))
                .foregroundColor(
                    .black.opacity(0.82)
                )
                .padding(12)
                .scrollContentBackground(
                    .hidden
                )
                .background(Color.clear)
            }
            .frame(minHeight: 110)
            .background(
                Color.white.opacity(0.82)
            )
            .cornerRadius(18)
            .overlay {
                RoundedRectangle(
                    cornerRadius: 18
                )
                .stroke(
                    isNoteFocused
                    ? orange.opacity(0.30)
                    : Color.black.opacity(0.05),
                    lineWidth: 1
                )
            }
        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.white.opacity(0.70)
        )
        .cornerRadius(18)
    }
}

// MARK: - FULL SCREEN BURST

struct FullScreenBurstParticle: Identifiable {
    let id = UUID()
    
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let rotation: Double
    let delay: Double
    
    static func makeParticles(
        screenSize: CGSize
    ) -> [FullScreenBurstParticle] {
        
        let maxDistance =
        max(
            screenSize.width,
            screenSize.height
        )
        
        return (0..<46).map { _ in
            FullScreenBurstParticle(
                angle: Double.random(
                    in: 0...(Double.pi * 2)
                ),
                distance: CGFloat.random(
                    in: (maxDistance * 0.30)...(maxDistance * 0.72)
                ),
                size: CGFloat.random(
                    in: 9...25
                ),
                rotation: Double.random(
                    in: -80...80
                ),
                delay: Double.random(
                    in: 0...0.08
                )
            )
        }
    }
}

struct FullScreenBurstSparkle: View {
    let particle: FullScreenBurstParticle
    let orange: Color
    let screenSize: CGSize
    
    @State private var explode = false
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(
                .system(
                    size: particle.size,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(
                            red: 1.0,
                            green: 0.34,
                            blue: 0.05
                        ),
                        orange
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .offset(
                x:
                    explode
                ? cos(particle.angle)
                * particle.distance
                : 0,
                
                y:
                    explode
                ? sin(particle.angle)
                * particle.distance
                : 0
            )
            .scaleEffect(
                explode ? 1.55 : 0.15
            )
            .rotationEffect(
                .degrees(
                    explode
                    ? particle.rotation
                    : 0
                )
            )
            .opacity(
                explode ? 0 : 1
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(
                    deadline:
                            .now()
                    + particle.delay
                ) {
                    withAnimation(
                        .easeOut(
                            duration: 0.72
                        )
                    ) {
                        explode = true
                    }
                }
            }
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
    @ScaledMetric private var subtitleSize: CGFloat = 15
    
    var body: some View {
        GeometryReader { geo in
            
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)
            
            VStack(spacing: 8) {
                
                Text(title)
                    .font(.system(size: titleSize * scale, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .top)
                
                Text(subtitle)
                    .font(.system(size: subtitleSize * scale))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: 110)
    }
}

struct BurstParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let delay: Double
    let rotation: Double
    
    static func makeParticles(iconSize: CGFloat) -> [BurstParticle] {
        (0..<24).map { _ in
            BurstParticle(
                angle: Double.random(in: 0...(Double.pi * 2)),
                distance: CGFloat.random(in: iconSize * 0.95...iconSize * 1.85),
                size: CGFloat.random(in: 9...24),
                delay: Double.random(in: 0...0.16),
                rotation: Double.random(in: -35...35)
            )
        }
    }
}

struct CompleteBurstSparkle: View {
    let particle: BurstParticle
    let orange: Color
    let trigger: Bool
    
    @State private var explode = false
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: particle.size, weight: .semibold))
            .foregroundColor(Color(red: 1.0, green: 0.34, blue: 0.05))
            .offset(
                x: explode ? cos(particle.angle) * particle.distance : 0,
                y: explode ? sin(particle.angle) * particle.distance : 0
            )
            .scaleEffect(explode ? 1.4 : 0.15)
            .rotationEffect(.degrees(explode ? particle.rotation : 0))
            .opacity(explode ? 0 : 1)
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                
                explode = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + particle.delay) {
                    withAnimation(.easeOut(duration: 0.75)) {
                        explode = true
                    }
                }
            }
    }
}
