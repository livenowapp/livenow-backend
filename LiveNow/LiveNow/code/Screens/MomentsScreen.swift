//
//  MomentsScreen.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
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
            
            
            /*VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Moments")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(.black)

                        Text("Real moments. Real progress.")
                            .font(.system(size: subtitleSize))
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)*/

                    VStack(spacing: 18) {

                        CalendarMiniCard(
                            vm: vm,
                            orange: orange,
                            displayedMonth: $displayedMonth
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 26)
                }

                BottomTabBar(vm: vm, orange: orange)
            }
        }
        .sheet(isPresented: $vm.showSelectedDateEntries) {
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
                                    .font(.system(size: dayTextSize, weight: isSelectedDay(date) ? .semibold : .regular))
                                    .foregroundColor(isSelectedDay(date) ? .white : .black.opacity(0.82))
                                    .frame(width: cellSize, height: cellSize)
                                    .background(
                                        Circle()
                                            .fill(isSelectedDay(date) ? orange : Color.clear)
                                    )

                                Circle()
                                    .fill(vm.hasEntry(on: date) ? orange : Color.clear)
                                    .frame(width: dotSize, height: dotSize)
                            }
                            .frame(maxWidth: .infinity)
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
            .background(Color.white.opacity(0.72))
            .cornerRadius(18)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.62))
        .cornerRadius(20)
        
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

// MARK: - SELECTED DATE SHEET

struct SelectedDateEntriesSheet: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    @Environment(\.dismiss) private var dismiss

    @State private var path: [ThoughtEntry] = []

    private var selectedEntries: [ThoughtEntry] {
        vm.entries(for: vm.selectedDate)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    if selectedEntries.isEmpty {
                        VStack(spacing: 8) {
                            Text("No resets left for today.")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black.opacity(0.75))

                            Text("All resets have been deleted.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(selectedEntries) { entry in
                            Button(action: {
                                path.append(entry)
                            }) {
                                HStack(alignment: .top, spacing: 14) {
                                    Circle()
                                        .fill(ActionStyle.color(entry.selectedActionIcon))
                                        .frame(
                                            width: ActionIconStyle.size,
                                            height: ActionIconStyle.size
                                        )
                                        .overlay(
                                            MomentIconImage(
                                                icon: ActionStyle.iconName(entry.selectedActionIcon),
                                                size: ActionIconStyle.size * ActionIconStyle.imageScale
                                            )
                                        )

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(timeString(entry.date))
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)

                                        Text(entry.selectedActionLabel ?? entry.thought)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)

                                        Text(shortTag(entry))
                                            .font(.system(size: 13))
                                            .foregroundColor(outcomeColor(entry))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(outcomeColor(entry).opacity(0.12))
                                            .cornerRadius(10)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(18)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(22)
            }
            .background(
                Color(red: 0.97, green: 0.96, blue: 0.94)
                    .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top) {
                ZStack {

                    Text(formattedSelectedDate())
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)

                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.black.opacity(0.75))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 14)
                .background(Color(red: 0.97, green: 0.96, blue: 0.94))
            }

            .navigationDestination(for: ThoughtEntry.self) { entry in
                MomentDetailScreen(
                    vm: vm,
                    entry: entry,
                    orange: orange,
                    lightOrange: Color(red: 1.0, green: 0.66, blue: 0.32),
                    onClose: {
                        if !path.isEmpty {
                            path.removeLast()
                        }
                    }
                )
                .navigationBarBackButtonHidden(true)
            }
        }
    }

    private func formattedSelectedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f.string(from: vm.selectedDate)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    private func shortTag(_ entry: ThoughtEntry) -> String {
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

    private func outcomeColor(_ entry: ThoughtEntry) -> Color {
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
}

// MARK: - DAY SECTION VIEW

struct DaySectionView: View {
    let title: String
    let entries: [ThoughtEntry]
    @ObservedObject var vm: AppViewModel
    let orange: Color

    var showViewMore: Bool = false
    var onViewMore: (() -> Void)? = nil

    @ScaledMetric private var titleSize: CGFloat = 18
    @ScaledMetric private var bodySize: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                HStack {
                    Text(title)
                        .font(.system(size: titleSize, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    if showViewMore, let onViewMore {
                        Button(action: onViewMore) {
                            Text("View more")
                                .font(.system(size: 14, weight: .medium))
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

            ForEach(entries) { entry in
                Button(action: {
                    vm.selectedMoment = entry
                }) {
                    HStack(alignment: .top, spacing: 14) {
                        Circle()
                            .fill(ActionStyle.color(entry.selectedActionIcon))
                            .frame(width: ActionIconStyle.size,
                                   height: ActionIconStyle.size)
                            .overlay(
                                MomentIconImage(
                                    icon: ActionStyle.iconName(entry.selectedActionIcon),
                                    size: ActionIconStyle.size * ActionIconStyle.imageScale
                                )
                            )

                        VStack(alignment: .leading, spacing: 6) {
                            Text(timeString(entry.date))
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            Text(entry.selectedActionLabel ?? entry.thought)
                                .font(.system(size: bodySize, weight: .medium))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(shortTag(entry))
                                .font(.system(size: 13))
                                .foregroundColor(outcomeColor(entry))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(outcomeColor(entry).opacity(0.12))
                                .cornerRadius(10)
                        }

                        Spacer()

                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(18)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    private func shortTag(_ entry: ThoughtEntry) -> String {
        switch entry.worthIt {
        case .no:
            return "Not worth it"
        case .maybe:
            return "Maybe"
        case .yes:
            return "Wrorth it"
        default:
            return "Pending"
        }
    }

    private func outcomeColor(_ entry: ThoughtEntry) -> Color {
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
}
