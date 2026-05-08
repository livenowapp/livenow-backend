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

    private var calendar: Calendar { Calendar.current }

    @ScaledMetric private var titleSize: CGFloat = 34
    @ScaledMetric private var subtitleSize: CGFloat = 15

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.025, 22)

            VStack(spacing: 0) {
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
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        MomentsStatsCard(vm: vm, orange: orange)

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
    }
}

// MARK: - STATS CARD

struct MomentsStatsCard: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 4),
            spacing: 0
        ) {
            MomentStatItem(icon: "sparkles", value: "\(vm.entries.count)", title: "moments", orange: orange)
            MomentStatItem(icon: "flame", value: "\(thisWeekCount)", title: "this week", orange: orange)
            MomentStatItem(icon: "chart.line.uptrend.xyaxis", value: "\(vm.streakCount)", title: "streak", orange: orange)
            MomentStatItem(icon: "checkmark.circle", value: "\(vm.didNotHappenPercent)%", title: "less worry", orange: orange)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.62))
        .cornerRadius(20)
    }

    private var thisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return vm.entries.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear)
        }.count
    }
}

struct MomentStatItem: View {
    let icon: String
    let value: String
    let title: String
    let orange: Color

    @ScaledMetric private var iconSize: CGFloat = 18
    @ScaledMetric private var valueSize: CGFloat = 20
    @ScaledMetric private var titleSize: CGFloat = 11

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(orange)

            Text(value)
                .font(.system(size: valueSize, weight: .semibold))
                .foregroundColor(.black)

            Text(title)
                .font(.system(size: titleSize))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - CALENDAR CARD

// MARK: - CALENDAR MINI CARD

struct CalendarMiniCard: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    @Binding var displayedMonth: Date

    private let calendar = Calendar.current
    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]

    @ScaledMetric private var monthTitleSize: CGFloat = 20
    @ScaledMetric private var dayTextSize: CGFloat = 15
    @ScaledMetric private var dotSize: CGFloat = 5
    @ScaledMetric private var previewIconSize: CGFloat = 40

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
                        Button(action: {
                            vm.showSelectedDateEntries = true
                        }) {
                            Text(selectedEntries.count > 3 ? "View more" : "\(selectedEntries.count) moments")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedEntries.count > 3 ? orange : .gray)
                        }
                        .buttonStyle(.plain)
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
                                vm.selectedMoment = entry
                            }) {
                                Circle()
                                    .fill(colorForMoment(entry))
                                    .frame(width: previewIconSize, height: previewIconSize)
                                    .overlay(
                                        Image(assetIconName(for: entry))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: previewIconSize * 0.92, height: previewIconSize * 0.92)
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        if selectedEntries.count > 3 {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: previewIconSize, height: previewIconSize)
                                .overlay(
                                    Text("+\(selectedEntries.count - 3)")
                                        .font(.system(size: previewIconSize * 0.35, weight: .semibold))
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

    private func assetIconName(for entry: ThoughtEntry) -> String {
        let icon = entry.selectedActionIcon ?? "action_sunlight"

        let map: [String: String] = [
            "wind": "action_breath",
            "figure.walk": "action_walk",
            "bubble.left.and.bubble.right": "action_chat",
            "pencil": "action_pencil",
            "leaf": "action_leaf",
            "music.note": "action_music",
            "bed.double": "action_sleep",
            "sun.max": "action_sunlight",
            "hand.raised": "action_handraised",

            "action_breath": "action_breath",
            "action_walk": "action_walk",
            "action_chat": "action_chat",
            "action_pencil": "action_pencil",
            "action_leaf": "action_leaf",
            "action_music": "action_music",
            "action_sleep": "action_sleep",
            "action_sunlight": "action_sunlight",
            "action_handraised": "action_handraised"
        ]

        return map[icon] ?? "action_sunlight"
    }

    private func colorForMoment(_ entry: ThoughtEntry) -> Color {
        let icon = assetIconName(for: entry)

        let colorMap: [String: Color] = [
            "action_breath": .blue,
            "action_walk": .orange,
            "action_chat": .teal,
            "action_pencil": .indigo,
            "action_leaf": .green,
            "action_music": .purple,
            "action_sleep": .pink,
            "action_sunlight": .yellow,
            "action_handraised": .red
        ]

        return colorMap[icon]?.opacity(0.22) ?? .gray.opacity(0.18)
    }
}

// MARK: - SELECTED DATE SHEET

struct SelectedDateEntriesSheet: View {
    @ObservedObject var vm: AppViewModel
    let orange: Color
    @Environment(\.dismiss) private var dismiss

    @State private var path: [ThoughtEntry] = []

    @ScaledMetric private var iconSize: CGFloat = 72

    private var selectedEntries: [ThoughtEntry] {
        vm.entries(for: vm.selectedDate)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(selectedEntries) { entry in
                        Button(action: {
                            path.append(entry)
                        }) {
                            HStack(alignment: .top, spacing: 14) {

                                Circle()
                                    .fill(colorForMoment(entry))
                                    .frame(width: iconSize, height: iconSize)
                                    .overlay(
                                        Image(assetIconName(for: entry))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(
                                                width: iconSize * 0.92,
                                                height: iconSize * 0.92
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
                .padding(22)
            }
            .background(
                Color(red: 0.97, green: 0.96, blue: 0.94)
                    .ignoresSafeArea()
            )
            .navigationTitle(formattedSelectedDate())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(orange)
                }
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
        switch entry.didHappen {
        case .no:
            return "Didn’t happen"
        case .maybe:
            return "Maybe"
        case .yes:
            return "Happened"
        default:
            return "Pending"
        }
    }

    private func assetIconName(for entry: ThoughtEntry) -> String {
        let icon = entry.selectedActionIcon ?? "action_sunlight"

        let map: [String: String] = [
            "wind": "action_breath",
            "figure.walk": "action_walk",
            "bubble.left.and.bubble.right": "action_chat",
            "pencil": "action_pencil",
            "leaf": "action_leaf",
            "music.note": "action_music",
            "bed.double": "action_sleep",
            "sun.max": "action_sunlight",
            "hand.raised": "action_handraised",

            "action_breath": "action_breath",
            "action_walk": "action_walk",
            "action_chat": "action_chat",
            "action_pencil": "action_pencil",
            "action_leaf": "action_leaf",
            "action_music": "action_music",
            "action_sleep": "action_sleep",
            "action_sunlight": "action_sunlight",
            "action_handraised": "action_handraised"
        ]

        return map[icon] ?? "action_sunlight"
    }

    private func colorForMoment(_ entry: ThoughtEntry) -> Color {
        let icon = assetIconName(for: entry)

        let colorMap: [String: Color] = [
            "action_breath": .blue,
            "action_walk": .orange,
            "action_chat": .teal,
            "action_pencil": .indigo,
            "action_leaf": .green,
            "action_music": .purple,
            "action_sleep": .pink,
            "action_sunlight": .yellow,
            "action_handraised": .red
        ]

        return colorMap[icon]?.opacity(0.22)
        ?? .gray.opacity(0.18)
    }

    private func outcomeColor(_ entry: ThoughtEntry) -> Color {
        switch entry.didHappen {
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

    @ScaledMetric private var iconSize: CGFloat = 72
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
                            .fill(colorForMoment(entry))
                            .frame(width: iconSize, height: iconSize)
                            .overlay(
                                Image(assetIconName(for: entry))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: iconSize * 0.92,
                                        height: iconSize * 0.92
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
        switch entry.didHappen {
        case .no:
            return "Didn’t happen"
        case .maybe:
            return "Maybe"
        case .yes:
            return "Happened"
        default:
            return "Pending"
        }
    }

    private func assetIconName(for entry: ThoughtEntry) -> String {
        let icon = entry.selectedActionIcon ?? "action_sunlight"

        let map: [String: String] = [
            "wind": "action_breath",
            "figure.walk": "action_walk",
            "bubble.left.and.bubble.right": "action_chat",
            "pencil": "action_pencil",
            "leaf": "action_leaf",
            "music.note": "action_music",
            "bed.double": "action_sleep",
            "sun.max": "action_sunlight",
            "hand.raised": "action_handraised",

            "action_breath": "action_breath",
            "action_walk": "action_walk",
            "action_chat": "action_chat",
            "action_pencil": "action_pencil",
            "action_leaf": "action_leaf",
            "action_music": "action_music",
            "action_sleep": "action_sleep",
            "action_sunlight": "action_sunlight",
            "action_handraised": "action_handraised"
        ]

        return map[icon] ?? "action_sunlight"
    }

    private func colorForMoment(_ entry: ThoughtEntry) -> Color {
           let icon = assetIconName(for: entry)

        let colorMap: [String: Color] = [
            "action_breath": .blue,
            "action_walk": .orange,
            "action_chat": .teal,
            "action_pencil": .indigo,
            "action_leaf": .green,
            "action_music": .purple,
            "action_sleep": .pink,
            "action_sunlight": .yellow,
            "action_handraised": .red
        ]

           return colorMap[icon]?.opacity(0.22)
           ?? .gray.opacity(0.18)
       }


    private func outcomeColor(_ entry: ThoughtEntry) -> Color {
        switch entry.didHappen {
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
