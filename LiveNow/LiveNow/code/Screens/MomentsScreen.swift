//
//  MomentsScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI

// MARK: - MOMENTS

struct MomentsScreen: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    let lightOrange: Color
    
    @State private var displayedMonth: Date = Date()
    
    @ScaledMetric private var titleSize: CGFloat = 34
    @ScaledMetric private var subtitleSize: CGFloat = 15
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)
            let adjustedTitleSize = titleSize * scale
            let subtitleSize = min(max(screenWidth * 0.038, 14), 16)
            let horizontalPadding = min(screenWidth * 0.055, 24)
            let topPadding = min(screenHeight * 0.025, 22)
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text("Moments")
                            .font(.system(size: adjustedTitleSize, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Real moments. Real progress.")
                            .font(.system(size: subtitleSize))
                            .foregroundColor(.gray)
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)
                    
                    VStack(spacing: 18) {
                        CalendarMiniCard( vm: vm, orange: orange, displayedMonth: $displayedMonth )
                    }
                    
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, min(max(screenHeight * 0.026, 18), 24))
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $vm.showSelectedDateEntries){
        SelectedDateEntriesSheet(vm: vm, orange: orange)
        }
        .onAppear {
            vm.selectedDate = Date()
            displayedMonth = Date()
        }
    }
}

// MARK: - CALENDAR MINI CARD

struct CalendarMiniCard: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    @Binding var displayedMonth: Date
    @State private var selectedPreviewEntry: ThoughtEntry? = nil

    private let calendar = Calendar.current
    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]

    @ScaledMetric private var monthTitleSize: CGFloat = 20
    @ScaledMetric private var dayTextSize: CGFloat = 15
    @ScaledMetric private var dotSize: CGFloat = 5

    var body: some View {
        let cellSize: CGFloat = 40
        let selectedEntries = vm.entries(for: vm.selectedDate)

        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(monthTitle)
                    .font(.system(size: monthTitleSize, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black.opacity(0.75))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black.opacity(0.75))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
            }

            HStack {
                ForEach(Array(weekdays.enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7),
                spacing: 12
            ) {
                ForEach(Array(daysInMonthGrid().enumerated()), id: \.offset) { _, date in
                    if let date {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.selectedDate = date
                            }
                        }) {
                            VStack(spacing: 6) {
                                Text(dayNumber(from: date))
                                    .font(
                                        .system(
                                            size: dayTextSize,
                                            weight: isSelectedDay(date)
                                                ? .semibold
                                                : .regular
                                        )
                                    )
                                    .foregroundColor(
                                        isSelectedDay(date)
                                            ? .white
                                            : .black.opacity(0.78)
                                    )
                                    .frame(
                                        width: cellSize,
                                        height: cellSize
                                    )
                                    .background(
                                        Circle()
                                            .fill(
                                                isSelectedDay(date)
                                                    ? orange
                                                    : Color.clear
                                            )
                                    )

                                Circle()
                                    .fill(
                                        vm.hasEntry(on: date)
                                            ? orange
                                            : Color.clear
                                    )
                                    .frame(
                                        width: dotSize,
                                        height: dotSize
                                    )
                            }
                            .frame(
                                maxWidth: .infinity,
                                minHeight: cellSize + dotSize + 14
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: cellSize + dotSize + 6)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(formattedSelectedDate(vm.selectedDate))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    if !selectedEntries.isEmpty {
                        if selectedEntries.count > 3 {
                            Button(action: {
                                vm.showSelectedDateEntries = true
                            }) {
                                Text("View more")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(orange)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text("\(selectedEntries.count) moments")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                }

                if selectedEntries.isEmpty {
                    VStack(spacing: 6) {
                        Text("No moments yet")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))

                        Text("No reset was saved on this day")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                } else {
                    HStack(spacing: 10) {
                        ForEach(selectedEntries.prefix(3), id: \.id) { entry in
                            Button(action: {
                                selectedPreviewEntry = entry
                            }) {
                                Circle()
                                    .fill(ActionStyle.color(entry.selectedActionIcon))
                                    .frame(
                                        width: ActionIconStyle.previewSize,
                                        height: ActionIconStyle.previewSize
                                    )
                                    .overlay(
                                        MomentIconImage(
                                            icon: ActionStyle.iconName(entry.selectedActionIcon),
                                            size: ActionIconStyle.previewSize * ActionIconStyle.imageScale
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        if selectedEntries.count > 3 {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(
                                    width: ActionIconStyle.previewSize,
                                    height: ActionIconStyle.previewSize
                                )
                                .overlay(
                                    Text("+\(selectedEntries.count - 3)")
                                        .font(.system(
                                            size: ActionIconStyle.previewSize * 0.35,
                                            weight: .semibold
                                        ))
                                        .foregroundColor(.black.opacity(0.7))
                                )
                        }

                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.82))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.78))
        .cornerRadius(22)
        
        .sheet(item: $selectedPreviewEntry) { entry in
            MomentDetailScreen(
                vm: vm,
                entry: entry,
                orange: orange,
                lightOrange: Color(red: 1.0, green: 0.66, blue: 0.32),
                onClose: {
                    selectedPreviewEntry = nil
                }
            )
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }

    private func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func formattedSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private func isSelectedDay(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: vm.selectedDate)
    }

    private func daysInMonthGrid() -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let firstWeekdayInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else {
            return []
        }

        var dates: [Date?] = []
        var current = firstWeekdayInterval.start

        while current < monthInterval.end || dates.count % 7 != 0 {
            if calendar.isDate(current, equalTo: displayedMonth, toGranularity: .month) {
                dates.append(current)
            } else {
                dates.append(nil)
            }

            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next

            if dates.count >= 42 { break }
        }

        return dates
    }
}

// MARK: - MOMENT DISPLAY HELPERS

private enum MomentDisplayStyle {

    static func tagText(for entry: ThoughtEntry) -> String {
        switch entry.worthIt {
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

    static func tagColor(for entry: ThoughtEntry) -> Color {
        switch entry.worthIt {
        case .no:
            return .green

        case .maybe:
            return .orange

        case .yes:
            return .red

        default:
            return .gray
        }
    }

    static func shortTime(from date: Date) -> String {
        date.formatted(
            .dateTime
                .hour()
                .minute()
        )
    }

    static func fullDate(from date: Date) -> String {
        date.formatted(
            .dateTime
                .month(.wide)
                .day()
                .year()
        )
    }
}


// MARK: - SELECTED DATE ENTRIES SHEET

struct SelectedDateEntriesSheet: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color

    @Environment(\.dismiss) private var dismiss

    @State private var path: [ThoughtEntry] = []
    @State private var openEntryID: UUID?
    @State private var isMomentSwipeActive = false

    private var selectedEntries: [ThoughtEntry] {
        vm.entries(for: vm.selectedDate)
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if selectedEntries.isEmpty {
                    emptyState
                } else {
                    entriesScrollView
                }
            }
            .background(screenBackground)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top) {
                topBar
            }
            .navigationDestination(for: ThoughtEntry.self) { entry in
                MomentDetailScreen(
                    vm: vm,
                    entry: entry,
                    orange: orange,
                    lightOrange: Color(
                        red: 1.0,
                        green: 0.66,
                        blue: 0.32
                    ),
                    onClose: {
                        guard !path.isEmpty else { return }
                        path.removeLast()
                    }
                )
                .navigationBarBackButtonHidden(true)
            }
        }
        .onDisappear {
            openEntryID = nil
            isMomentSwipeActive = false
        }
    }

    // MARK: - ENTRIES

    private var entriesScrollView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ForEach(selectedEntries) { entry in
                    MomentSwipeRow(
                        entryID: entry.id,
                        openEntryID: $openEntryID,
                        isSwipeActive: $isMomentSwipeActive,
                        onOpen: {
                            openEntryID = nil
                            isMomentSwipeActive = false
                            path.append(entry)
                        },
                        onDelete: {
                            vm.deleteEntry(entry.id)
                        }
                    ) {
                        entryCard(entry)
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 15)
            .padding(.bottom, 28)
        }
        .scrollDisabled(isMomentSwipeActive)
    }

    // MARK: - ENTRY CARD

    private func entryCard(_ entry: ThoughtEntry) -> some View {
        let tagColor = MomentDisplayStyle.tagColor(for: entry)
        let tagText = MomentDisplayStyle.tagText(for: entry)

        return HStack(alignment: .center, spacing: 14) {
            Circle()
                .fill(
                    ActionStyle.color(
                        entry.selectedActionIcon
                    )
                )
                .frame(
                    width: ActionIconStyle.size,
                    height: ActionIconStyle.size
                )
                .overlay {
                    MomentIconImage(
                        icon: ActionStyle.iconName(
                            entry.selectedActionIcon
                        ),
                        size: ActionIconStyle.size *
                            ActionIconStyle.imageScale
                    )
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(
                    MomentDisplayStyle.shortTime(
                        from: entry.date
                    )
                )
                .font(.system(size: 13))
                .foregroundColor(.gray)

                Text(
                    entry.ai.shortTitle ??
                    entry.thought
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

                Text(tagText)
                    .font(.system(size: 13))
                    .foregroundColor(tagColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        tagColor.opacity(0.12)
                    )
                    .cornerRadius(10)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            minHeight: ActionIconStyle.size + 32,
            alignment: .leading
        )
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    Color(
                        red: 0.995,
                        green: 0.993,
                        blue: 0.989
                    )
                )
        )
        .contentShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - EMPTY STATE

    private var emptyState: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                Text("No resets left for today.")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(
                        .black.opacity(0.75)
                    )

                Text("All resets have been deleted.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
            .padding(.horizontal, 22)
        }
    }

    // MARK: - TOP BAR

    private var topBar: some View {
        ZStack {
            Text(
                MomentDisplayStyle.fullDate(
                    from: vm.selectedDate
                )
            )
            .font(
                .system(
                    size: 20,
                    weight: .semibold
                )
            )
            .foregroundColor(.black)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(
                            .system(
                                size: 20,
                                weight: .regular
                            )
                        )
                        .foregroundColor(
                            .black.opacity(0.75)
                        )
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .background(screenBackground)
    }

    private var screenBackground: Color {
        Color(
            red: 0.97,
            green: 0.96,
            blue: 0.94
        )
    }
}


// MARK: - MOMENT SWIPE ROW

struct MomentSwipeRow<Content: View>: View {
    let entryID: UUID

    @Binding var openEntryID: UUID?
    @Binding var isSwipeActive: Bool

    let onOpen: () -> Void
    let onDelete: () -> Void
    let content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var startingOffset: CGFloat = 0

    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var hideDeleteButton = false

    @State private var dragDirectionLocked = false
    @State private var isHorizontalDrag = false

    private let revealedWidth: CGFloat = 78
    private let deleteCircleSize: CGFloat = 50
    private let openThreshold: CGFloat = 34

    private var rowHeight: CGFloat {
        ActionIconStyle.size + 32
    }

    init(
        entryID: UUID,
        openEntryID: Binding<UUID?>,
        isSwipeActive: Binding<Bool>,
        onOpen: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.entryID = entryID
        self._openEntryID = openEntryID
        self._isSwipeActive = isSwipeActive
        self.onOpen = onOpen
        self.onDelete = onDelete
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                deleteAction

                content()
                    .frame(
                        maxWidth: .infinity,
                        minHeight: rowHeight,
                        alignment: .leading
                    )
                    .offset(x: offset)
                    .allowsHitTesting(false)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: rowHeight
            )
            .contentShape(Rectangle())
            .highPriorityGesture(
                swipeGesture,
                including: .all
            )
            .onTapGesture {
                handleCardTap()
            }
            .clipped()
            .alert(
                "Delete reset?",
                isPresented: $showDeleteAlert
            ) {
                Button("Cancel", role: .cancel) {
                    isSwipeActive = false
                    closeRow()
                }

                Button("Delete", role: .destructive) {
                    isSwipeActive = false

                    animateDeletion(
                        width: geometry.size.width
                    )
                }
            } message: {
                Text(
                    "This reset will be permanently deleted."
                )
            }
        }
        .frame(height: rowHeight)
        .onAppear {
            resetVisualState()
        }
        .onDisappear {
            if openEntryID == entryID {
                openEntryID = nil
            }

            isSwipeActive = false
        }
        .onChange(of: openEntryID) { _, newValue in
            guard !isDeleting else { return }

            if newValue != entryID && offset < 0 {
                closeWithoutChangingOpenEntry()
            }
        }
    }

    // MARK: - DELETE ACTION

    private var deleteAction: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)

            Button {
                guard !isDeleting else { return }

                offset = -revealedWidth
                startingOffset = -revealedWidth
                openEntryID = entryID
                isSwipeActive = false
                showDeleteAlert = true
            } label: {
                Circle()
                    .fill(Color.red.opacity(0.78))
                    .frame(
                        width: deleteCircleSize,
                        height: deleteCircleSize
                    )
                    .overlay {
                        Image(systemName: "trash.fill")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .semibold
                                )
                            )
                            .foregroundColor(.white)
                    }
            }
            .buttonStyle(.plain)
            .frame(width: revealedWidth)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .opacity(
            hideDeleteButton ? 0 : 1
        )
        .allowsHitTesting(
            !isDeleting &&
            offset <= -revealedWidth + 1
        )
    }

    // MARK: - SWIPE GESTURE

    private var swipeGesture: some Gesture {
        DragGesture(
            minimumDistance: 3,
            coordinateSpace: .global
        )
        .onChanged { value in
            guard !isDeleting else { return }

            let horizontal =
                value.translation.width

            let vertical =
                value.translation.height

            if !dragDirectionLocked {
                guard
                    abs(horizontal) > 3 ||
                    abs(vertical) > 3
                else {
                    return
                }

                dragDirectionLocked = true

                isHorizontalDrag =
                    abs(horizontal) > abs(vertical)

                if isHorizontalDrag {
                    isSwipeActive = true
                }
            }

            guard isHorizontalDrag else { return }

            let proposedOffset =
                startingOffset + horizontal

            offset = min(
                0,
                max(
                    -revealedWidth,
                    proposedOffset
                )
            )
        }
        .onEnded { value in
            defer {
                dragDirectionLocked = false
                isHorizontalDrag = false
                isSwipeActive = false
            }

            guard !isDeleting else { return }
            guard isHorizontalDrag else { return }

            let predictedOffset =
                startingOffset +
                value.predictedEndTranslation.width

            let shouldOpen =
                offset < -openThreshold ||
                predictedOffset <
                -(revealedWidth * 0.52)

            if shouldOpen {
                openRow()
            } else {
                closeRow()
            }
        }
    }

    // MARK: - TAP

    private func handleCardTap() {
        guard !isDeleting else { return }

        if offset < 0 {
            closeRow()
        } else {
            onOpen()
        }
    }

    // MARK: - OPEN

    private func openRow() {
        startingOffset = -revealedWidth
        openEntryID = entryID

        withAnimation(snapAnimation) {
            offset = -revealedWidth
        }
    }

    // MARK: - CLOSE

    private func closeRow() {
        startingOffset = 0

        withAnimation(snapAnimation) {
            offset = 0
        }

        if openEntryID == entryID {
            openEntryID = nil
        }
    }

    private func closeWithoutChangingOpenEntry() {
        startingOffset = 0

        withAnimation(snapAnimation) {
            offset = 0
        }
    }

    // MARK: - DELETE

    private func animateDeletion(
        width: CGFloat
    ) {
        guard !isDeleting else { return }

        isDeleting = true
        hideDeleteButton = true

        withAnimation(
            .easeOut(duration: 0.23)
        ) {
            offset = -(width + 40)
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.38
        ) {
            if openEntryID == entryID {
                openEntryID = nil
            }

            withAnimation(
                .easeInOut(duration: 0.23)
            ) {
                onDelete()
            }
        }
    }

    // MARK: - RESET

    private func resetVisualState() {
        offset = 0
        startingOffset = 0

        isDeleting = false
        hideDeleteButton = false

        dragDirectionLocked = false
        isHorizontalDrag = false
    }

    private var snapAnimation: Animation {
        .interactiveSpring(
            response: 0.22,
            dampingFraction: 0.9,
            blendDuration: 0.05
        )
    }
}


// MARK: - DAY SECTION VIEW

struct DaySectionView: View {
    let title: String
    let entries: [ThoughtEntry]

    @ObservedObject var vm: AppViewModel

    let orange: Color

    var showViewMore: Bool = false
    var onViewMore: (() -> Void)?

    @ScaledMetric private var titleSize: CGFloat = 18
    @ScaledMetric private var bodySize: CGFloat = 16

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            if !title.isEmpty {
                sectionHeader
            }

            ForEach(entries) { entry in
                entryButton(entry)
            }
        }
    }

    // MARK: - HEADER

    private var sectionHeader: some View {
        HStack {
            Text(title)
                .font(
                    .system(
                        size: titleSize,
                        weight: .semibold
                    )
                )
                .foregroundColor(.black)

            Spacer()

            if showViewMore, let onViewMore {
                Button(action: onViewMore) {
                    Text("View more")
                        .font(
                            .system(
                                size: 14,
                                weight: .medium
                            )
                        )
                        .foregroundColor(orange)
                }
                .buttonStyle(.plain)
            } else {
                Text("\(entries.count) moments")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - ENTRY

    private func entryButton(
        _ entry: ThoughtEntry
    ) -> some View {
        let tagColor =
            MomentDisplayStyle.tagColor(for: entry)

        let tagText =
            MomentDisplayStyle.tagText(for: entry)

        return Button {
            vm.selectedMoment = entry
        } label: {
            HStack(
                alignment: .top,
                spacing: 14
            ) {
                Circle()
                    .fill(
                        ActionStyle.color(
                            entry.selectedActionIcon
                        )
                    )
                    .frame(
                        width: ActionIconStyle.size,
                        height: ActionIconStyle.size
                    )
                    .overlay {
                        MomentIconImage(
                            icon: ActionStyle.iconName(
                                entry.selectedActionIcon
                            ),
                            size: ActionIconStyle.size *
                                ActionIconStyle.imageScale
                        )
                    }

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    Text(
                        MomentDisplayStyle.shortTime(
                            from: entry.date
                        )
                    )
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                    Text(
                        entry.selectedActionLabel ??
                        entry.thought
                    )
                    .font(
                        .system(
                            size: bodySize,
                            weight: .medium
                        )
                    )
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                    Text(tagText)
                        .font(.system(size: 13))
                        .foregroundColor(tagColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            tagColor.opacity(0.12)
                        )
                        .cornerRadius(10)
                }

                Spacer(minLength: 0)

                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
            .padding(16)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                Color.white.opacity(0.78)
            )
            .cornerRadius(22)
            .contentShape(
                RoundedRectangle(cornerRadius: 22)
            )
        }
        .buttonStyle(.plain)
    }
}
