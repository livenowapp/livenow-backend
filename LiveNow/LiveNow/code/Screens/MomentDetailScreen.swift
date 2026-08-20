//
//  MomentDetailScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI

// MARK: - MOMENT DETAIL

struct MomentDetailScreen: View {
    @ObservedObject var vm: AppViewModel
    let entry: ThoughtEntry
    let orange: Color
    let lightOrange: Color
    var onClose: () -> Void

    @State private var noteText: String = ""
    @State private var showDeleteConfirmation = false

    private var currentEntry: ThoughtEntry {
        vm.entries.first(where: { $0.id == entry.id }) ?? entry
    }

    @ScaledMetric private var titleSize: CGFloat = 30
    @ScaledMetric private var bodySize: CGFloat = 15
    @ScaledMetric private var cardRadius: CGFloat = 22
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()

            GeometryReader { geo in
                let screenWidth = geo.size.width
                let screenHeight = geo.size.height

                let horizontalPadding = min(screenWidth * 0.055, 24)
                let topPadding = min(screenHeight * 0.025, 22)

                VStack(spacing: 0) {
                    header(horizontalPadding: horizontalPadding, topPadding: topPadding)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            heroCard
                            outcomeCard
                            thoughtCard
                            analysisCard
                            askYourselfCard
                            reframeCard
                            noteCard
                            deleteButton
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, min(max(screenHeight * 0.026, 18), 24))
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear {
            noteText = currentEntry.note ?? ""
        }
        .onChange(of: noteText) { _, newValue in
            vm.updateNote(for: entry.id, note: newValue)
        }
        .alert("Delete reset?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}

            Button("Delete", role: .destructive) {
                vm.deleteEntry(entry.id)
                onClose()
            }
        } message: {
            Text("This reset will be permanently deleted.")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isNoteFocused = false
        }
    }

    private func header(horizontalPadding: CGFloat, topPadding: CGFloat) -> some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black.opacity(0.75))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Date

            Text(formattedDate(currentEntry.date))
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Spacer()
                .frame(height: 18)

            // MARK: Short title + Avatar

            HStack(
                alignment: .center,
                spacing: 16
            ) {

                Text(currentEntry.ai.shortTitle)
                    .font(
                        .system(
                            size: 24,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Image(momentDetailAvatarName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 105,
                        height: 105
                    )
                    .offset(x: 6)
                    .shadow(
                        color: Color.black.opacity(0.10),
                        radius: 8,
                        x: 0,
                        y: 6
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            // MARK: Status

            Spacer()
                .frame(height: 10)

            HStack {
                Text(statusText)
                    .font(
                        .system(
                            size: 18,
                            weight: .medium
                        )
                    )
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        statusColor.opacity(0.12)
                    )
                    .cornerRadius(14)

                Spacer()
            }

            Spacer()
                .frame(height: 22)

            // MARK: Selected action

            HStack(
                alignment: .center,
                spacing: 14
            ) {

                ZStack {
                    Circle()
                        .fill(
                            ActionStyle.color(
                                currentEntry.selectedActionIcon
                            )
                        )
                        .frame(
                            width: ActionIconStyle.detailSize,
                            height: ActionIconStyle.detailSize
                        )
                        .shadow(
                            color:
                                ActionStyle.color(
                                    currentEntry.selectedActionIcon
                                )
                                .opacity(0.25),
                            radius: 14,
                            x: 0,
                            y: 8
                        )

                    MomentIconImage(
                        icon:
                            ActionStyle.iconName(
                                currentEntry.selectedActionIcon
                            ),
                        size:
                            ActionIconStyle.detailSize
                            * ActionIconStyle.imageScale
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text("chosen action")
                        .font(
                            .system(
                                size: 12,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.gray)

                    Text(
                        currentEntry.selectedActionLabel ?? ""
                    )
                    .font(
                        .system(
                            size: 16,
                            weight: .medium
                        )
                    )
                    .foregroundColor(
                        .black.opacity(0.78)
                    )
                    .multilineTextAlignment(.leading)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }

                Spacer(minLength: 0)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .padding(24)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.white.opacity(0.78)
        )
        .cornerRadius(cardRadius)
        .shadow(
            color: Color.black.opacity(0.045),
            radius: 18,
            x: 0,
            y: 8
        )
    }

    private var outcomeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Was it worth overthinking?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()
            }

            HStack(spacing: 10) {
                OutcomeButton(title: "no", selected: currentEntry.worthIt == .no, color: .green) {

                    if currentEntry.worthIt == .no {
                        vm.updateOutcome(for: entry.id, outcome: nil)
                    } else {
                        vm.updateOutcome(for: entry.id, outcome: .no)
                    }
                }

                OutcomeButton(title: "maybe", selected: currentEntry.worthIt == .maybe, color: .orange) {

                    if currentEntry.worthIt == .maybe {
                        vm.updateOutcome(for: entry.id, outcome: nil)
                    } else {
                        vm.updateOutcome(for: entry.id, outcome: .maybe)
                    }
                }

                OutcomeButton(title: "yes", selected: currentEntry.worthIt == .yes, color: .red) {

                    if currentEntry.worthIt == .yes {
                        vm.updateOutcome(for: entry.id, outcome: nil)
                    } else {
                        vm.updateOutcome(for: entry.id, outcome: .yes)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private var thoughtCard: some View {
        premiumTextCard(
            eyebrow: "your thought",
            title: "What was on your mind",
            text: currentEntry.thought,
            icon: "quote.opening",
            color: orange
        )
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 14) {
        
                Text("What your mind was doing")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

            ForEach(Array(currentEntry.ai.analysis.prefix(3).enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(orange.opacity(0.12))
                            .frame(width: 42, height: 42)

                        Image(systemName: analysisIcon(for: index))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(orange)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.label)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)

                        Text(item.sub)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }

                if index < min(currentEntry.ai.analysis.count, 3) - 1 {
                    Divider().opacity(0.16)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }
    
    private var askYourselfCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                eyebrow: "reflection",
                title: "Ask yourself",
                icon: "questionmark.bubble",
                color: orange
            )

            ForEach(
                Array(currentEntry.ai.evidence.enumerated()),
                id: \.offset
            ) { index, item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.q)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.a)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                if index < currentEntry.ai.evidence.count - 1 {
                    Divider()
                        .opacity(0.16)
                        .padding(.vertical, 6)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private var reframeCard: some View {
        premiumTextCard(
            eyebrow: "chosen reframe",
            title: "A more realistic thought",
            text: currentEntry.selectedReframe ?? "No reframe saved",
            icon: "lightbulb",
            color: orange
        )
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                eyebrow: "note",
                title: "What did you learn?",
                icon: "pencil",
                color: orange
            )

            ZStack(alignment: .topLeading) {
                if noteText.isEmpty {
                    Text("write a small note...")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.top, 18)
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $noteText)
                    .focused($isNoteFocused)
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.82))
                    .padding(12)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .frame(minHeight: 120)
            .background(Color.white.opacity(0.82))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .padding(20)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private var deleteButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            Text("delete reset")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.78))
                .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }

    private func premiumTextCard(
        eyebrow: String,
        title: String,
        text: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                eyebrow: eyebrow,
                title: title,
                icon: icon,
                color: color
            )

            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black.opacity(0.78))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private func sectionHeader(
        eyebrow: String,
        title: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }

            Spacer()
        }
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 21))
                .foregroundColor(orange)

            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(Color.black.opacity(0.08))
            .frame(width: 1, height: 62)
    }

    private var statusText: String {
        switch currentEntry.worthIt {
        case .no:
            return "Not worth it"

        case .maybe:
            return "Maybe"

        case .yes:
            return "Worth it"

        default:
            return "Waiting for outcome"
        }
    }
    
    private var momentDetailAvatarName: String {
        switch currentEntry.worthIt {
        case .no:
            return "avatar_happy"

        case .maybe:
            return "avatar_think"

        case .yes:
            return "avatar_sad"

        case .none:
            return "avatar_smile"
        }
    }

    private var statusColor: Color {
        switch currentEntry.worthIt {
        case .no:
            return .green
        case .maybe:
            return .orange
        case .yes:
            return .red
        case .none:
            return orange
        }
    }

    private var outcomeShortText: String {
        switch currentEntry.worthIt {
        case .no:
            return "no"
        case .maybe:
            return "maybe"
        case .yes:
            return "yes"
        case .none:
            return "open"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy • h:mm a"
        return f.string(from: date)
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

/*import SwiftUI

// MARK: - MOMENT DETAIL

struct MomentDetailScreen: View {
    @ObservedObject var vm: AppViewModel
    let entry: ThoughtEntry
    let orange: Color
    let lightOrange: Color
    var onClose: () -> Void

    @State private var noteText: String = ""
    @State private var showDeleteConfirmation = false

    private var currentEntry: ThoughtEntry {
        vm.entries.first(where: { $0.id == entry.id }) ?? entry
    }

    @ScaledMetric private var titleSize: CGFloat = 30
    @ScaledMetric private var bodySize: CGFloat = 15
    @ScaledMetric private var cardRadius: CGFloat = 22
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()

            GeometryReader { geo in
                let screenWidth = geo.size.width
                let screenHeight = geo.size.height

                let horizontalPadding = min(screenWidth * 0.055, 24)
                let topPadding = min(screenHeight * 0.025, 22)

                VStack(spacing: 0) {
                    header(horizontalPadding: horizontalPadding, topPadding: topPadding)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            heroCard
                            outcomeCard
                            thoughtCard
                            analysisCard
                            askYourselfCard
                            reframeCard
                            noteCard
                            deleteButton
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, min(max(screenHeight * 0.026, 18), 24))
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear {
            noteText = currentEntry.note ?? ""
        }
        .onChange(of: noteText) { _, newValue in
            vm.updateNote(for: entry.id, note: newValue)
        }
        .alert("Delete reset?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}

            Button("Delete", role: .destructive) {
                vm.deleteEntry(entry.id)
                onClose()
            }
        } message: {
            Text("This reset will be permanently deleted.")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isNoteFocused = false
        }
    }

    private func header(horizontalPadding: CGFloat, topPadding: CGFloat) -> some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black.opacity(0.75))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }

    private var heroCard: some View {
        VStack(spacing: 0) {

            Text(formattedDate(currentEntry.date))
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Spacer()
                .frame(height: 16)

            ZStack {
                Circle()
                    .fill(ActionStyle.color(currentEntry.selectedActionIcon))
                    .frame(
                        width: ActionIconStyle.detailSize,
                        height: ActionIconStyle.detailSize
                    )
                    .shadow(
                        color: ActionStyle.color(currentEntry.selectedActionIcon).opacity(0.25),
                        radius: 18,
                        x: 0,
                        y: 10
                    )

                MomentIconImage(
                    icon: ActionStyle.iconName(currentEntry.selectedActionIcon),
                    size: ActionIconStyle.detailSize * ActionIconStyle.imageScale
                )
            }

            Spacer()
                .frame(height: 12)

            Text(currentEntry.selectedActionLabel ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
                .frame(height: 8)

            Text(currentEntry.ai.shortTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 300)

            Spacer()
                .frame(height: 12)

            Text(statusText)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(statusColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(statusColor.opacity(0.12))
                .cornerRadius(14)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
        .shadow(color: Color.black.opacity(0.045), radius: 18, x: 0, y: 8)
    }

    private var outcomeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Was it worth overthinking?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()
            }

            HStack(spacing: 10) {
                OutcomeButton(title: "no", selected: currentEntry.worthIt == .no, color: .green) {

                    if currentEntry.worthIt == .no {
                        vm.updateOutcome(for: entry.id, outcome: nil)
                    } else {
                        vm.updateOutcome(for: entry.id, outcome: .no)
                    }
                }

                OutcomeButton(title: "maybe", selected: currentEntry.worthIt == .maybe, color: .orange) {

                    if currentEntry.worthIt == .maybe {
                        vm.updateOutcome(for: entry.id, outcome: nil)
                    } else {
                        vm.updateOutcome(for: entry.id, outcome: .maybe)
                    }
                }

                OutcomeButton(title: "yes", selected: currentEntry.worthIt == .yes, color: .red) {

                    if currentEntry.worthIt == .yes {
                        vm.updateOutcome(for: entry.id, outcome: nil)
                    } else {
                        vm.updateOutcome(for: entry.id, outcome: .yes)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private var thoughtCard: some View {
        premiumTextCard(
            eyebrow: "your thought",
            title: "What was on your mind",
            text: currentEntry.thought,
            icon: "quote.opening",
            color: orange
        )
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 14) {
        
                Text("What your mind was doing")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

            ForEach(Array(currentEntry.ai.analysis.prefix(3).enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(orange.opacity(0.12))
                            .frame(width: 42, height: 42)

                        Image(systemName: analysisIcon(for: index))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(orange)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.label)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)

                        Text(item.sub)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }

                if index < min(currentEntry.ai.analysis.count, 3) - 1 {
                    Divider().opacity(0.16)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }
    
    private var askYourselfCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                eyebrow: "reflection",
                title: "Ask yourself",
                icon: "questionmark.bubble",
                color: orange
            )

            ForEach(
                Array(currentEntry.ai.evidence.enumerated()),
                id: \.offset
            ) { index, item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.q)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.a)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                if index < currentEntry.ai.evidence.count - 1 {
                    Divider()
                        .opacity(0.16)
                        .padding(.vertical, 6)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private var reframeCard: some View {
        premiumTextCard(
            eyebrow: "chosen reframe",
            title: "A more realistic thought",
            text: currentEntry.selectedReframe ?? "No reframe saved",
            icon: "lightbulb",
            color: orange
        )
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                eyebrow: "note",
                title: "What did you learn?",
                icon: "pencil",
                color: orange
            )

            ZStack(alignment: .topLeading) {
                if noteText.isEmpty {
                    Text("write a small note...")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.top, 18)
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $noteText)
                    .focused($isNoteFocused)
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.82))
                    .padding(12)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .frame(minHeight: 120)
            .background(Color.white.opacity(0.82))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .padding(20)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private var deleteButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            Text("delete reset")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.78))
                .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }

    private func premiumTextCard(
        eyebrow: String,
        title: String,
        text: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                eyebrow: eyebrow,
                title: title,
                icon: icon,
                color: color
            )

            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black.opacity(0.78))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .cornerRadius(cardRadius)
    }

    private func sectionHeader(
        eyebrow: String,
        title: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }

            Spacer()
        }
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 21))
                .foregroundColor(orange)

            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(Color.black.opacity(0.08))
            .frame(width: 1, height: 62)
    }

    private var statusText: String {
        switch currentEntry.worthIt {
        case .no:
            return "Not worth it"

        case .maybe:
            return "Maybe"

        case .yes:
            return "Worth it"

        default:
            return "Waiting for outcome"
        }
    }

    private var statusColor: Color {
        switch currentEntry.worthIt {
        case .no:
            return .green
        case .maybe:
            return .orange
        case .yes:
            return .red
        case .none:
            return orange
        }
    }

    private var outcomeShortText: String {
        switch currentEntry.worthIt {
        case .no:
            return "no"
        case .maybe:
            return "maybe"
        case .yes:
            return "yes"
        case .none:
            return "open"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy • h:mm a"
        return f.string(from: date)
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
*/
