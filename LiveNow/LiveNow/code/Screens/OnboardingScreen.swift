//
//  OnboardingScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 20. 6. 2026.
//

import SwiftUI

// MARK: - ONBOARDING

struct OnboardingScreen: View {
    let orange: Color
    let lightOrange: Color
    var onGetStarted: ([String: String]) -> Void
    var onAlreadySubscribed: () -> Void

    @State private var page = 0
    @State private var onboardingAnswers: [String: String] = [:]

    private let pages: [OnboardingStep] = [
        .info(.init(
            title: "welcome to\nLiveNow",
            subtitle: "your space to pause,\nreflect and reset",
            visual: .logo
        )),
        .info(.init(
            title: "reflect in\nthe moment",
            subtitle: "capture your thoughts,\nfeelings and daily resets",
            visual: .orbit
        )),
        .info(.init(
            title: "understand\nyourself",
            subtitle: "get insights and patterns\nto understand what really matters",
            visual: .journal
        )),
        .info(.init(
            title: "grow\nevery day",
            subtitle: "small resets, better habits\nand a calmer mind",
            visual: .leaf
        )),

        .question(.init(
            id: "onboardingReason",
            title: "What brings you\nto LiveNow?",
            subtitle: "choose what feels closest",
            options: [
                "I overthink a lot",
                "I feel anxious often",
                "I want more clarity",
                "I want healthier habits",
                "I want more peace of mind"
            ]
        )),
        .question(.init(
            id: "onboardingTime",
            title: "When do you\noverthink most?",
            subtitle: "choose the one that fits best",
            options: [
                "Morning",
                "During work or school",
                "Evening",
                "Before bed",
                "It happens all day"
            ]
        )),
        .question(.init(
            id: "onboardingThinkerType",
            title: "What kind of\nthinker are you?",
            subtitle: "no wrong answer",
            options: [
                "I replay past conversations",
                "I worry about the future",
                "I overanalyze decisions",
                "I assume the worst",
                "A bit of everything"
            ]
        )),
        .question(.init(
            id: "onboardingNeed",
            title: "What do you need\nmost right now?",
            subtitle: "LiveNow will feel more personal",
            options: [
                "Calm",
                "Confidence",
                "Clarity",
                "Less overthinking",
                "Better habits"
            ]
        )),

        .info(.init(
            title: "track\nyour progress",
            subtitle: "notice how your mind changes over time\nwith simple insights and trends",
            visual: .chart
        )),
        .info(.init(
            title: "you’re not\nalone",
            subtitle: "LiveNow helps you come back\nto yourself every step of the way",
            visual: .people
        ))
    ]
    
    private var canContinue: Bool {
        switch pages[page] {
        case .info:
            return true

        case .question(let question):
            return onboardingAnswers[question.id] != nil
        }
    }

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let topPadding = min(max(screenHeight * 0.025, 18), 24)
            let horizontalPadding = min(screenWidth * 0.06, 28)
            let buttonVerticalPadding = min(max(screenHeight * 0.02, 14), 17)
            let bottomSpacing = min(max(screenHeight * 0.018, 12), 20)

            VStack(spacing: 0) {

                HStack {
                    if page > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                page -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.black.opacity(0.7))
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(width: 32, height: 32)
                    }

                    Spacer()
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)
                
                ZStack {
                    switch pages[page] {
                    case .info(let infoPage):
                        LiveNowOnboardingPageView(
                            page: infoPage,
                            orange: orange,
                            lightOrange: lightOrange
                        )
                        .padding(.horizontal, horizontalPadding)
                        .transition(.opacity)

                    case .question(let question):
                        OnboardingQuestionPageView(
                            question: question,
                            selectedAnswer: onboardingAnswers[question.id],
                            orange: orange
                        ) { selected in
                            onboardingAnswers[question.id] = selected
                        }
                        .padding(.horizontal, horizontalPadding)
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.22), value: page)

                LiveNowOnboardingDots(
                    count: pages.count,
                    current: page,
                    orange: orange
                )
                .padding(.bottom, 24)

                Button {
                    if page < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            page += 1
                        }
                    } else {
                        onGetStarted(onboardingAnswers)
                    }
                } label: {
                    Text(page == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, buttonVerticalPadding)
                        .background(canContinue ? orange : Color.gray.opacity(0.35))
                        .cornerRadius(13)
                }
                .buttonStyle(.plain)
                .disabled(!canContinue)
                .padding(.horizontal, horizontalPadding)
                
                if page == 0 {
                    Button {
                        onAlreadySubscribed()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Already subscribed?")
                                .foregroundColor(.gray)

                            Text("Log in")
                                .foregroundColor(orange)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 18)
                }

                Spacer().frame(height: bottomSpacing)
            }
        }
    }
}

// MARK: - MODEL

struct LiveNowOnboardingPage {
    let title: String
    let subtitle: String
    let visual: LiveNowOnboardingVisual
}

enum OnboardingStep {
    case info(LiveNowOnboardingPage)
    case question(OnboardingQuestion)
}

struct OnboardingQuestion {
    let id: String
    let title: String
    let subtitle: String
    let options: [String]
}

enum LiveNowOnboardingVisual {
    case logo
    case orbit
    case journal
    case leaf
    case chart
    case people
}

// MARK: - PAGE

struct LiveNowOnboardingPageView: View {
    let page: LiveNowOnboardingPage
    let orange: Color
    let lightOrange: Color

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let titleSize = min(max(screenWidth * 0.078, 28), 44)
            let subtitleSize = min(max(screenWidth * 0.042, 14), 20)

            let visualSize = min(max(screenWidth * 0.48, 150), 260)
            let visualBoxHeight = min(max(screenHeight * 0.34, 255), 340)

            let topSpacing = min(max(screenHeight * 0.07, 50), 86)
            let titleSpacing = min(max(screenHeight * 0.04, 30), 52)

            VStack(spacing: 0) {
                Spacer().frame(height: topSpacing)

                ZStack {
                    visual(size: visualSize)
                }
                .frame(maxWidth: .infinity)
                .frame(height: visualBoxHeight)

                Spacer().frame(height: titleSpacing)

                Text(page.title)
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity)
                    .frame(height: titleSize * 2.25, alignment: .center)

                Spacer().frame(height: 18)

                Text(page.subtitle)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity)
                    .frame(height: subtitleSize * 3.2, alignment: .top)

                Spacer()
            }
            .frame(width: screenWidth, height: screenHeight)
        }
    }

    @ViewBuilder
    private func visual(size: CGFloat) -> some View {
        switch page.visual {
        case .logo:
            LiveNowLogoVisual(
                orange: orange,
                lightOrange: lightOrange,
                size: size
            )

        case .orbit:
            LiveNowOrbitVisual(
                orange: orange,
                lightOrange: lightOrange,
                size: size
            )

        case .journal:
            LiveNowIconVisual(
                icon: "book.closed",
                accentIcon: "pencil",
                orange: orange,
                size: size
            )

        case .leaf:
            LiveNowLeafVisual(
                orange: orange,
                size: size
            )

        case .chart:
            LiveNowChartVisual(
                orange: orange,
                size: size
            )

        case .people:
            LiveNowPeopleVisual(
                orange: orange,
                size: size
            )
        }
    }
}

// MARK: - DOTS

struct LiveNowOnboardingDots: View {
    let count: Int
    let current: Int
    let orange: Color

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? orange : Color.gray.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - VISUALS

struct LiveNowLogoVisual: View {
    let orange: Color
    let lightOrange: Color
    let size: CGFloat

    var body: some View {
        Image("LogoCircle")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

struct LiveNowOrbitVisual: View {
    let orange: Color
    let lightOrange: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    orange.opacity(0.35),
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 5])
                )
                .frame(width: size * 1.38, height: size * 1.38)

            Image("LogoCircle")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)

            Circle()
                .fill(orange)
                .frame(width: 11, height: 11)
                .offset(x: -size * 0.68, y: size * 0.22)

            Image(systemName: "sparkle")
                .font(.system(size: 22))
                .foregroundColor(orange.opacity(0.55))
                .offset(x: -size * 0.62, y: -size * 0.48)

            Image(systemName: "sparkle")
                .font(.system(size: 14))
                .foregroundColor(orange.opacity(0.45))
                .offset(x: size * 0.72, y: -size * 0.36)
        }
        .frame(width: size * 1.6, height: size * 1.6)
    }
}

struct LiveNowIconVisual: View {
    let icon: String
    let accentIcon: String
    let orange: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.72))
                .frame(width: size * 1.35, height: size * 1.35)

            Image(systemName: icon)
                .font(.system(size: size * 0.55, weight: .regular))
                .foregroundColor(.black.opacity(0.78))

            Image(systemName: accentIcon)
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundColor(orange)
                .offset(x: size * 0.34, y: size * 0.22)
        }
        .frame(width: size * 1.45, height: size * 1.45)
    }
}

struct LiveNowLeafVisual: View {
    let orange: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(orange.opacity(0.08))
                .frame(width: size * 1.35, height: size * 1.35)

            Image(systemName: "leaf")
                .font(.system(size: size * 0.62, weight: .regular))
                .foregroundColor(orange)

        }
    }
}

struct LiveNowChartVisual: View {
    let orange: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(orange.opacity(0.08))
                .frame(width: size * 1.35, height: size * 1.35)

            Path { path in
                path.move(to: CGPoint(x: size * 0.18, y: size * 0.82))
                path.addLine(to: CGPoint(x: size * 0.42, y: size * 0.62))
                path.addLine(to: CGPoint(x: size * 0.66, y: size * 0.70))
                path.addLine(to: CGPoint(x: size * 0.92, y: size * 0.38))
            }
            .stroke(
                orange,
                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            )
            .frame(width: size, height: size)

            ForEach([0.18, 0.42, 0.66, 0.92], id: \.self) { x in
                Circle()
                    .fill(Color.white)
                    .frame(width: 11, height: 11)
                    .overlay(Circle().stroke(orange, lineWidth: 3))
                    .offset(
                        x: (x - 0.5) * size,
                        y: pointY(for: x) * size
                    )
            }
        }
        .frame(width: size * 1.35, height: size * 1.35)
    }

    private func pointY(for x: CGFloat) -> CGFloat {
        switch x {
        case 0.18: return 0.32
        case 0.42: return 0.12
        case 0.66: return 0.20
        default: return -0.12
        }
    }
}

struct LiveNowPeopleVisual: View {
    let orange: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.72))
                .frame(width: size * 1.35, height: size * 1.35)

            HStack(spacing: -size * 0.08) {
                person(color: .white, outline: .black.opacity(0.75), size: size * 0.42)
                person(color: orange, outline: orange, size: size * 0.52)
                person(color: .white, outline: .black.opacity(0.75), size: size * 0.42)
            }
        }
        .frame(width: size * 1.55, height: size * 1.25)
    }

    private func person(color: Color, outline: Color, size: CGFloat) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .overlay(Circle().stroke(outline, lineWidth: 3))
                .frame(width: size * 0.48, height: size * 0.48)

            RoundedRectangle(cornerRadius: size * 0.16)
                .fill(color)
                .overlay(RoundedRectangle(cornerRadius: size * 0.16).stroke(outline, lineWidth: 3))
                .frame(width: size * 0.72, height: size * 0.52)
        }
    }
}

// MARK: - QUESTIONS

struct OnboardingQuestionPageView: View {
    let question: OnboardingQuestion
    let selectedAnswer: String?
    let orange: Color
    let onSelect: (String) -> Void

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let titleSize = min(max(screenWidth * 0.07, 27), 36)
            let subtitleSize = min(max(screenWidth * 0.038, 14), 17)
            let optionTextSize = min(max(screenWidth * 0.04, 15), 17)

            VStack(spacing: 0) {
                Spacer().frame(height: min(screenHeight * 0.13, 110))

                Text(question.title)
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)

                Spacer().frame(height: 14)

                Text(question.subtitle)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: min(screenHeight * 0.045, 38))

                VStack(spacing: 12) {
                    ForEach(question.options, id: \.self) { option in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                onSelect(option)
                            }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.system(size: optionTextSize, weight: .medium))
                                    .foregroundColor(.black.opacity(0.82))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.85)

                                Spacer()

                                Circle()
                                    .stroke(
                                        selectedAnswer == option ? orange : Color.gray.opacity(0.35),
                                        lineWidth: 2
                                    )
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Circle()
                                            .fill(selectedAnswer == option ? orange : Color.clear)
                                            .frame(width: 11, height: 11)
                                    )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(
                                selectedAnswer == option
                                ? Color.white.opacity(0.95)
                                : Color.white.opacity(0.62)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        selectedAnswer == option ? orange.opacity(0.5) : Color.black.opacity(0.05),
                                        lineWidth: 1.2
                                    )
                            )
                            .cornerRadius(18)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .frame(width: screenWidth, height: screenHeight)
        }
    }
}
