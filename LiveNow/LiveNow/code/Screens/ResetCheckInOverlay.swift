//
//  ResetCheckInScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 21. 7. 2026.
//

import SwiftUI

// MARK: - RESET CHECK-IN OVERLAY

struct ResetCheckInOverlay: View {

    @State private var selectedAnswer: SelectedAnswer?
    @State private var isSubmittingAnswer = false
    @State private var answerTask: Task<Void, Never>?

    let entry: ThoughtEntry
    let remainingCount: Int
    let orange: Color

    let onNotWorthIt: () -> Void
    let onMaybe: () -> Void
    let onWorthIt: () -> Void
    let onSkip: () -> Void
    let onSkipAll: () -> Void

    private enum SelectedAnswer {
        case no
        case maybe
        case yes
    }

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let horizontalPadding = min(max(screenWidth * 0.055, 16), 24)
            let cardHorizontalPadding = min(max(screenWidth * 0.052, 18), 22)
            let cardVerticalPadding = min(max(screenHeight * 0.022, 16), 20)
            let sectionSpacing = min(max(screenHeight * 0.026, 18), 22)
            let answerHeight = min(max(screenHeight * 0.062, 46), 52)
            let cardRadius = min(max(screenWidth * 0.06, 20), 24)

            ZStack {
                Color.black
                    .opacity(0.14)
                    .ignoresSafeArea()

                checkInCard(
                    cardHorizontalPadding: cardHorizontalPadding,
                    cardVerticalPadding: cardVerticalPadding,
                    sectionSpacing: sectionSpacing,
                    answerHeight: answerHeight,
                    cardRadius: cardRadius
                )
                .id(entry.id)
                .padding(.horizontal, horizontalPadding)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .transition(
                    .asymmetric(
                        insertion:
                            .move(edge: .trailing)
                            .combined(with: .opacity),

                        removal:
                            .move(edge: .leading)
                            .combined(with: .opacity)
                    )
                )
            }
        }
        .onChange(of: entry.id) { _, _ in
            resetAnswerState()
        }
        .onDisappear {
            answerTask?.cancel()
            answerTask = nil
        }
    }

    // MARK: - CARD

    private func checkInCard(
        cardHorizontalPadding: CGFloat,
        cardVerticalPadding: CGFloat,
        sectionSpacing: CGFloat,
        answerHeight: CGFloat,
        cardRadius: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            dateSection

            thoughtSection

            if hasSelectedAction {
                actionSection
            }

            Divider()
                .opacity(0.6)
                .padding(.vertical, sectionSpacing)

            outcomeSection(
                answerHeight: answerHeight
            )

            Divider()
                .opacity(0.6)
                .padding(.top, sectionSpacing)
                .padding(.bottom, 12)

            bottomActions
        }
        .padding(.horizontal, cardHorizontalPadding)
        .padding(.top, cardVerticalPadding)
        .padding(.bottom, max(cardVerticalPadding - 2, 14))
        .frame(maxWidth: 520)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: cardRadius,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.10),
            radius: 20,
            x: 0,
            y: 8
        )
    }

    // MARK: - DATE

    private var dateSection: some View {
        ZStack {
            Text(formattedDate(entry.date))
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            HStack {
                Spacer()

                if remainingCount > 1 {
                    Text("\(remainingCount) left")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }

    // MARK: - THOUGHT

    private var thoughtSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Your thought")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            Text(entry.thought)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.78))
                .lineSpacing(3)
                .lineLimit(4)
                .minimumScaleFactor(0.88)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(Color(red: 0.95, green: 0.89, blue: 0.84))
        .cornerRadius(18)
    }

    // MARK: - ACTION

    private var actionSection: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        ActionStyle.color(
                            entry.selectedActionIcon
                        )
                    )
                    .frame(width: 42, height: 42)

                MomentIconImage(
                    icon: ActionStyle.iconName(
                        entry.selectedActionIcon
                    ),
                    size: 32
                )
            }

            if let label = entry.selectedActionLabel,
               !label.isEmpty {

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.70))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer()
        }
        .padding(.top, 18)
    }

    // MARK: - OUTCOME

    private func outcomeSection(
        answerHeight: CGFloat
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text("Was it worth overthinking?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(2)
                .minimumScaleFactor(0.86)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            HStack(spacing: 10) {
                outcomeButton(
                    title: "no",
                    color: .green,
                    answer: .no,
                    height: answerHeight
                ) {
                    submitAnswer(
                        .no,
                        action: onNotWorthIt
                    )
                }

                outcomeButton(
                    title: "maybe",
                    color: .orange,
                    answer: .maybe,
                    height: answerHeight
                ) {
                    submitAnswer(
                        .maybe,
                        action: onMaybe
                    )
                }

                outcomeButton(
                    title: "yes",
                    color: .red,
                    answer: .yes,
                    height: answerHeight
                ) {
                    submitAnswer(
                        .yes,
                        action: onWorthIt
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private func outcomeButton(
        title: String,
        color: Color,
        answer: SelectedAnswer,
        height: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        let isSelected = selectedAnswer == answer

        return Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(
                    isSelected
                        ? .white
                        : color
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                    .fill(
                        isSelected
                            ? color
                            : Color.clear
                    )
                )
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                )
        }
        .buttonStyle(.plain)
        .disabled(isSubmittingAnswer)
    }

    // MARK: - BOTTOM ACTIONS

    private var bottomActions: some View {
        HStack {
            Button {
                guard !isSubmittingAnswer else {
                    return
                }

                onSkip()
            } label: {
                Text("Skip")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(
                        minWidth: 60,
                        minHeight: 40,
                        alignment: .leading
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isSubmittingAnswer)

            Spacer()

            Button {
                guard !isSubmittingAnswer else {
                    return
                }

                onSkipAll()
            } label: {
                Text("Skip all")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(orange)
                    .frame(
                        minWidth: 70,
                        minHeight: 40,
                        alignment: .trailing
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isSubmittingAnswer)
        }
    }

    // MARK: - ANSWER

    private func submitAnswer(
        _ answer: SelectedAnswer,
        action: @escaping () -> Void
    ) {
        guard !isSubmittingAnswer else {
            return
        }

        answerTask?.cancel()

        isSubmittingAnswer = true

        withAnimation(
            .easeInOut(duration: 0.18)
        ) {
            selectedAnswer = answer
        }

        answerTask = Task {
            try? await Task.sleep(
                nanoseconds: 400_000_000
            )

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                selectedAnswer = nil
                isSubmittingAnswer = false
                answerTask = nil

                action()
            }
        }
    }

    private func resetAnswerState() {
        answerTask?.cancel()
        answerTask = nil
        selectedAnswer = nil
        isSubmittingAnswer = false
    }

    // MARK: - HELPERS

    private var hasSelectedAction: Bool {
        let hasIcon =
            !(entry.selectedActionIcon ?? "")
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty

        let hasLabel =
            !(entry.selectedActionLabel ?? "")
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty

        return hasIcon || hasLabel
    }

    private func formattedDate(
        _ date: Date
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}
