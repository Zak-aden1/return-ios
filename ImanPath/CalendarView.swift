//
//  CalendarView.swift
//  ImanPath
//
//  Journey Calendar - Monthly view with day details
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var allJournalEntries: [JournalEntry]
    @Query(sort: \CheckIn.date, order: .reverse) private var allCheckIns: [CheckIn]

    // Current displayed month
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var showDayDetails: Bool = true
    @State private var showJournalComposer: Bool = false

    // Real streak data (loaded once)
    @State private var currentStreak: Int = 0
    @State private var streakStartDate: Date? = nil  // nil = no commitment yet

    private let tealAccent = Color(hex: "5B9A9A")
    private let warmGold = Color(hex: "E8B86D")
    private let calendar = Calendar.current

    // MARK: - Real Data Lookups

    /// Group journal entries by day (stable - no Date() in loop)
    private var journalEntriesByDay: [Date: [JournalEntry]] {
        Dictionary(grouping: allJournalEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
    }

    /// Group check-ins by day (one per day max, keep newest if duplicates)
    private var checkInsByDay: [Date: CheckIn] {
        var result: [Date: CheckIn] = [:]
        for checkIn in allCheckIns {
            let day = calendar.startOfDay(for: checkIn.date)
            // allCheckIns is reverse-sorted (newest first), so first entry wins
            if result[day] == nil {
                result[day] = checkIn
            }
        }
        return result
    }

    private func streakDay(for date: Date) -> Int? {
        guard let start = streakStartDate else { return nil }
        let startDay = calendar.startOfDay(for: start)
        let dayStart = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startDay, to: dayStart).day ?? -1
        return days >= 0 ? days : nil
    }

    private func milestoneDefinition(for date: Date) -> MilestoneDefinition? {
        guard let streakDay = streakDay(for: date) else { return nil }
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: date)
        guard dayStart <= today else { return nil }
        return MilestoneCatalog.definition(for: streakDay)
    }

    /// Convert CheckIn to DayCheckInData for display
    private func getCheckInData(for date: Date) -> DayCheckInData? {
        let dayStart = calendar.startOfDay(for: date)
        guard let checkIn = checkInsByDay[dayStart] else { return nil }

        // Calculate overall score (percentage of max 50)
        let total = checkIn.moodRating + checkIn.energyRating + checkIn.confidenceRating
                  + checkIn.faithRating + checkIn.selfControlRating
        let overallScore = Int((Double(total) / 50.0) * 100)

        // Calculate streak day (only if we have a streak and check-in is after streak start)
        let streakDayValue = streakDay(for: date)
        let milestone = streakDayValue.flatMap { MilestoneCatalog.definition(for: $0) }
        let streakDay = streakDayValue ?? 0
        let isMilestone = milestone != nil
        let milestoneTitle = milestone?.title

        // Format check-in time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: checkIn.date)

        return DayCheckInData(
            date: checkIn.date,
            overallScore: overallScore,
            moodScore: checkIn.moodRating,
            energyScore: checkIn.energyRating,
            confidenceScore: checkIn.confidenceRating,
            faithScore: checkIn.faithRating,
            selfControlScore: checkIn.selfControlRating,
            dailyReflection: checkIn.progressReflection,
            journeyReflection: checkIn.journeyReflection,
            gratitude: checkIn.gratitude,
            streakDay: streakDay,
            isMilestone: isMilestone,
            milestoneTitle: milestoneTitle,
            checkInTime: timeString
        )
    }

    /// Build check-in data dictionary for entire calendar
    private var checkInDataByDay: [Date: DayCheckInData] {
        var result: [Date: DayCheckInData] = [:]
        for checkIn in allCheckIns {
            let dayStart = Calendar.current.startOfDay(for: checkIn.date)
            if let data = getCheckInData(for: dayStart) {
                result[dayStart] = data
            }
        }
        return result
    }

    private func getJournalEntries(for date: Date) -> [JournalEntry] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return journalEntriesByDay[dayStart] ?? []
    }

    private func loadCalendarData() {
        let dataManager = DataManager(modelContext: modelContext)

        if let streak = dataManager.getCurrentStreak() {
            streakStartDate = streak.startedAt
            currentStreak = dataManager.calculateCurrentStreakDays()
        } else {
            // No commitment yet - nil means no streak band appears (Option A)
            streakStartDate = nil
            currentStreak = 0
        }
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0F1419"),
                    Color(hex: "0A0E14"),
                    Color(hex: "080B0F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle glow
            RadialGradient(
                colors: [tealAccent.opacity(0.06), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                CalendarHeader(
                    displayedMonth: $displayedMonth,
                    onDismiss: { dismiss() }
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Month Calendar
                        MonthCalendarView(
                            displayedMonth: displayedMonth,
                            selectedDate: $selectedDate,
                            checkInDates: checkInDataByDay,
                            streakStartDate: streakStartDate
                        )
                        .padding(.horizontal, 20)

                        // Day Details
                        DayDetailsCard(
                            selectedDate: selectedDate,
                            dayData: getDayData(for: selectedDate),
                            streakDay: streakDay(for: selectedDate),
                            milestoneDefinition: milestoneDefinition(for: selectedDate),
                            journalEntries: getJournalEntries(for: selectedDate),
                            onAddJournalEntry: {
                                showJournalComposer = true
                            }
                        )
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showJournalComposer) {
            JournalComposerView(prefilledDate: selectedDate)
        }
        .onAppear {
            loadCalendarData()
        }
    }

    private func getDayData(for date: Date) -> DayCheckInData? {
        getCheckInData(for: date)
    }

}

// MARK: - Data Model
struct DayCheckInData {
    let date: Date
    let overallScore: Int
    let moodScore: Int
    let energyScore: Int
    let confidenceScore: Int
    let faithScore: Int
    let selfControlScore: Int
    let dailyReflection: String?
    let journeyReflection: String?
    let gratitude: String?
    let streakDay: Int
    let isMilestone: Bool
    let milestoneTitle: String?
    var checkInTime: String? = nil // e.g., "3:56 PM"
}

// MARK: - Calendar Header
struct CalendarHeader: View {
    @Binding var displayedMonth: Date
    var onDismiss: () -> Void

    private let tealAccent = Color(hex: "5B9A9A")

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Top row
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text("Journey Calendar")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Spacer()

                // Today button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayedMonth = Date()
                    }
                }) {
                    Text("Today")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(tealAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(tealAccent.opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, 20)

            // Month navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }

                Spacer()

                Text(monthYearString)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    let displayedMonth: Date
    @Binding var selectedDate: Date
    let checkInDates: [Date: DayCheckInData]
    let streakStartDate: Date?  // Optional - nil means no commitment yet

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let tealAccent = Color(hex: "5B9A9A")
    private let streakGreen = Color(hex: "74B886")
    private let warmGold = Color(hex: "E8B86D")

    private var monthDays: [Date?] {
        let interval = calendar.dateInterval(of: .month, for: displayedMonth)!
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        var currentDate = firstDay
        while currentDate < interval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        // Pad to complete last week
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    // Check if a date is in the streak
    private func isInStreak(_ date: Date) -> Bool {
        guard let start = streakStartDate else { return false }  // No streak = no days in streak
        let startDay = calendar.startOfDay(for: start)
        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        return checkDate >= startDay && checkDate <= today
    }

    // Get current streak count (Day 0 = today, Day 1 = after 24 hours)
    private func getCurrentStreak() -> Int {
        guard let start = streakStartDate else { return 0 }
        let today = calendar.startOfDay(for: Date())
        let startDay = calendar.startOfDay(for: start)
        return calendar.dateComponents([.day], from: startDay, to: today).day ?? 0
    }

    // Get streak position for a date (for rounded corners)
    private func streakPosition(for index: Int, date: Date) -> StreakPosition {
        let isCurrentInStreak = isInStreak(date)
        if !isCurrentInStreak { return .none }

        let daysBefore = monthDays.indices.contains(index - 1) ? monthDays[index - 1] : nil
        let daysAfter = monthDays.indices.contains(index + 1) ? monthDays[index + 1] : nil

        let hasPrevInStreak = daysBefore.map { isInStreak($0) } ?? false
        let hasNextInStreak = daysAfter.map { isInStreak($0) } ?? false

        // Check if we're at the start/end of a row
        let isStartOfRow = index % 7 == 0
        let isEndOfRow = index % 7 == 6

        let effectivePrev = hasPrevInStreak && !isStartOfRow
        let effectiveNext = hasNextInStreak && !isEndOfRow

        if effectivePrev && effectiveNext { return .middle }
        if effectivePrev && !effectiveNext { return .end }
        if !effectivePrev && effectiveNext { return .start }
        return .single
    }

    var body: some View {
        VStack(spacing: 16) {
            // Day of week headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid with streak bands
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4) {
                ForEach(Array(monthDays.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        ZStack {
                            // Streak band background
                            if isInStreak(date) {
                                StreakBandBackground(
                                    position: streakPosition(for: index, date: date),
                                    color: streakGreen
                                )
                                .offset(y: 4) // Offset to align with circles
                            }

                            // Day cell
                            DayCellV2(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date),
                                isInStreak: isInStreak(date),
                                checkInData: checkInDates[calendar.startOfDay(for: date)],
                                currentStreak: getCurrentStreak(),
                                streakStartDate: streakStartDate,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDate = date
                                    }
                                }
                            )
                        }
                        .frame(height: 64)
                    } else {
                        Color.clear
                            .frame(height: 64)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "141A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Streak Position
enum StreakPosition {
    case none, start, middle, end, single
}

// MARK: - Streak Band Background
struct StreakBandBackground: View {
    let position: StreakPosition
    let color: Color

    // Solid green for streak band (no opacity to avoid stacking issues)
    private let bandGreen = Color(hex: "3D5C45")

    var body: some View {
        GeometryReader { geo in
            let height: CGFloat = 46
            let radius: CGFloat = height / 2

            // Calculate corners to round based on position
            let leftRadius: CGFloat = (position == .start || position == .single) ? radius : 0
            let rightRadius: CGFloat = (position == .end || position == .single) ? radius : 0

            // No extensions - cells meet edge to edge
            // Add 1px overlap only to prevent hairline gaps between cells
            let leftExtend: CGFloat = (position == .middle || position == .end) ? 1 : 0
            let rightExtend: CGFloat = (position == .middle || position == .start) ? 1 : 0

            UnevenRoundedRectangle(
                topLeadingRadius: leftRadius,
                bottomLeadingRadius: leftRadius,
                bottomTrailingRadius: rightRadius,
                topTrailingRadius: rightRadius
            )
            .fill(bandGreen)
            .frame(width: geo.size.width + leftExtend + rightExtend, height: height)
            .offset(x: -leftExtend)
            .position(x: geo.size.width / 2, y: geo.size.height / 2 + 3)
        }
    }
}

// MARK: - Day Cell V2 (with streak support)
struct DayCellV2: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isInStreak: Bool
    let checkInData: DayCheckInData?
    let currentStreak: Int
    let streakStartDate: Date?
    let onTap: () -> Void

    private let calendar = Calendar.current
    private let tealAccent = Color(hex: "5B9A9A")
    private let streakGreen = Color(hex: "74B886")
    private let warmGold = Color(hex: "E8B86D")
    private let progressBlue = Color(hex: "5B7FD6")

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    private var isFuture: Bool {
        // Compare dates at start of day to avoid time-based issues
        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        return checkDate > today
    }

    private var isPast: Bool {
        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        return checkDate < today
    }

    private var isBeforeStreak: Bool {
        // Days before the user's journey started
        !isInStreak && isPast
    }

    private var streakDayForDate: Int? {
        guard let start = streakStartDate else { return nil }
        let startDay = calendar.startOfDay(for: start)
        let dayStart = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startDay, to: dayStart).day ?? -1
        return days >= 0 ? days : nil
    }

    private var milestoneDefinition: MilestoneDefinition? {
        guard let streakDay = streakDayForDate else { return nil }
        return MilestoneCatalog.definition(for: streakDay)
    }

    private var isMilestone: Bool {
        guard !isFuture else { return false }
        return milestoneDefinition != nil
    }

    // Check if this is a future milestone day
    private var isFutureMilestone: Bool {
        guard isFuture else { return false }
        guard streakStartDate != nil else { return false }
        let futureStreakDay = calculateFutureStreakDay()
        return MilestoneCatalog.days.contains(futureStreakDay)
    }

    // Calculate what streak day this future date would be
    private func calculateFutureStreakDay() -> Int {
        let today = calendar.startOfDay(for: Date())
        let futureDate = calendar.startOfDay(for: date)
        let daysUntil = calendar.dateComponents([.day], from: today, to: futureDate).day ?? 0
        return currentStreak + daysUntil
    }

    private var progressValue: CGFloat {
        guard let data = checkInData else { return 0 }
        return CGFloat(data.overallScore) / 100.0
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // Star indicator - only for PAST milestones (achievements earned)
                // Future milestones just show the locked circle, no star above
                if isMilestone {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(warmGold)
                } else {
                    Color.clear.frame(height: 10)
                }

                ZStack {
                    // Base circle
                    Circle()
                        .fill(Color(hex: "1A2430"))
                        .frame(width: 42, height: 42)

                    // Progress ring for check-in days (only past days with data)
                    if checkInData != nil && !isMilestone {
                        // Background ring
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 3)
                            .frame(width: 42, height: 42)

                        // Progress fill
                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(streakGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 42, height: 42)
                            .rotationEffect(.degrees(-90))
                    }

                    // Subtle border for future non-milestone days
                    if isFuture && !isFutureMilestone {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            .frame(width: 42, height: 42)
                    }

                    // Selected state
                    if isSelected {
                        Circle()
                            .stroke(tealAccent, lineWidth: 3)
                            .frame(width: 42, height: 42)
                    }

                    // Today indicator
                    if isToday && !isSelected {
                        Circle()
                            .stroke(tealAccent, lineWidth: 3)
                            .frame(width: 42, height: 42)
                    }

                    // Content based on day type
                    if isBeforeStreak {
                        // Days before streak - lock icon
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.25))
                    }
                    else if isFutureMilestone {
                        // Future milestone - locked with anticipation
                        ZStack {
                            Circle()
                                .fill(warmGold.opacity(0.15))
                                .frame(width: 36, height: 36)

                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(warmGold.opacity(0.6))
                        }
                    }
                    else if isMilestone {
                        // Past milestone - unlocked with icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [warmGold, warmGold.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)

                            // Milestone icon
                            Image(systemName: milestoneIcon)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    else {
                        // Regular day number
                        Text(dayNumber)
                            .font(.system(size: 15, weight: isSelected || isToday ? .bold : .medium))
                            .foregroundColor(
                                isSelected ? .white :
                                isFuture ? .white.opacity(0.35) :
                                isToday ? .white :
                                isInStreak ? .white :
                                .white.opacity(0.5)
                            )
                    }
                }
                .frame(width: 44, height: 44)

                // Check-in indicator dot (green for consistency)
                if checkInData != nil && !isMilestone {
                    Circle()
                        .fill(streakGreen)
                        .frame(width: 5, height: 5)
                } else if isMilestone {
                    Circle()
                        .fill(warmGold)
                        .frame(width: 5, height: 5)
                } else {
                    Color.clear.frame(height: 5)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var milestoneIcon: String {
        milestoneDefinition?.icon ?? "star.fill"
    }
}

// MARK: - Day Details Card
struct DayDetailsCard: View {
    let selectedDate: Date
    let dayData: DayCheckInData?
    let streakDay: Int?
    let milestoneDefinition: MilestoneDefinition?
    var journalEntries: [JournalEntry] = []
    var onAddJournalEntry: (() -> Void)? = nil

    private let tealAccent = Color(hex: "5B9A9A")

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var isFuture: Bool {
        selectedDate > Date()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Date header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    if let day = streakDay, !isFuture {
                        Text("Day \(day) of your journey")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(tealAccent)
                    } else if isToday {
                        Text("Today")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(tealAccent)
                    } else if isFuture {
                        Text("Upcoming")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                Spacer()

                // Day badge (only if in streak)
                if let day = streakDay, !isFuture {
                    DayBadge(day: day)
                }
            }
            .padding(20)

            if let milestone = milestoneDefinition {
                Divider()
                    .background(Color.white.opacity(0.08))

                MilestoneBanner(milestone: milestone)

                Divider()
                    .background(Color.white.opacity(0.08))
            } else if dayData != nil {
                Divider()
                    .background(Color.white.opacity(0.08))
            }

            if let data = dayData {
                // Day Activity Section
                DayActivitySection(data: data, isToday: isToday)
                    .padding(20)

                Divider()
                    .background(Color.white.opacity(0.08))

                // Mood scores
                MoodScoresRow(data: data)
                    .padding(20)

                // Reflections
                if data.dailyReflection != nil || data.journeyReflection != nil || data.gratitude != nil {
                    Divider()
                        .background(Color.white.opacity(0.08))

                    ReflectionsSection(data: data)
                        .padding(20)
                }

                // Journal Entries
                Divider()
                    .background(Color.white.opacity(0.08))

                JournalEntriesSection(
                    entries: journalEntries,
                    onAddEntry: onAddJournalEntry
                )
                .padding(20)

            } else if isFuture {
                // Future date
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.2))

                    Text("This day hasn't arrived yet")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))

                    Text("Keep going, you'll get there insha'Allah")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)

            } else {
                // No check-in
                VStack(spacing: 16) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.2))

                    Text("No check-in recorded")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))

                    if isToday {
                        Text("Complete today's check-in from the home screen")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "141A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Day Activity Section
struct DayActivitySection: View {
    let data: DayCheckInData
    let isToday: Bool

    private let tealAccent = Color(hex: "5B9A9A")
    private let completedGreen = Color(hex: "74B886")

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Day Activity")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            // Daily Check-in Activity Card
            ActivityCard(
                icon: "checkmark.circle.fill",
                iconBackground: Color(hex: "E8B86D"),
                title: "Daily Check-in",
                subtitle: "All sections completed",
                timeString: data.checkInTime,
                isCompleted: true
            )
        }
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    let icon: String
    let iconBackground: Color
    let title: String
    let subtitle: String
    let timeString: String?
    let isCompleted: Bool

    private let completedGreen = Color(hex: "74B886")

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackground.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconBackground)
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(isCompleted ? completedGreen : .white.opacity(0.5))
            }

            Spacer()

            // Time or status
            if let time = timeString {
                Text(time)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "1A2230"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isCompleted ? completedGreen.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Day Badge
struct DayBadge: View {
    let day: Int

    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        Text("Day \(day)")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(tealAccent)
            )
    }
}

// MARK: - Milestone Card
struct MilestoneBanner: View {
    let milestone: MilestoneDefinition

    private let warmGold = Color(hex: "E8B86D")

    private var milestoneDescription: String {
        if let verse = milestone.verse, let reference = milestone.verseReference {
            return "\(milestone.meaning) \"\(verse)\" (\(reference))"
        }
        return milestone.meaning
    }

    private var milestoneIcon: String {
        milestone.icon
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [warmGold, warmGold.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: milestoneIcon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            // Text
            VStack(alignment: .leading, spacing: 6) {
                Text(milestone.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)

                Text(milestoneDescription)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [warmGold.opacity(0.25), warmGold.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(warmGold.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Mood Scores Row
struct MoodScoresRow: View {
    let data: DayCheckInData

    private let dimensions: [(String, String, Color, KeyPath<DayCheckInData, Int>)] = [
        ("Mood", "face.smiling", Color(hex: "E8B86D"), \DayCheckInData.moodScore),
        ("Energy", "bolt.fill", Color(hex: "74B886"), \DayCheckInData.energyScore),
        ("Confidence", "shield.fill", Color(hex: "6BA3D6"), \DayCheckInData.confidenceScore),
        ("Faith", "moon.stars.fill", Color(hex: "A78BDA"), \DayCheckInData.faithScore),
        ("Control", "hand.raised.fill", Color(hex: "E88B6D"), \DayCheckInData.selfControlScore)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(dimensions, id: \.0) { dimension in
                VStack(spacing: 8) {
                    // Score circle
                    ZStack {
                        Circle()
                            .stroke(dimension.2.opacity(0.2), lineWidth: 3)
                            .frame(width: 44, height: 44)

                        Circle()
                            .trim(from: 0, to: CGFloat(data[keyPath: dimension.3]) / 10.0)
                            .stroke(dimension.2, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))

                        Text("\(data[keyPath: dimension.3])")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    // Label
                    Text(dimension.0)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Reflections Section
struct ReflectionsSection: View {
    let data: DayCheckInData

    @State private var expandedReflection: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            if let daily = data.dailyReflection {
                ReflectionCard(
                    icon: "heart.text.square.fill",
                    title: "Daily Reflection",
                    content: daily,
                    color: Color(hex: "6BA3D6"),
                    isExpanded: expandedReflection == "daily",
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedReflection = expandedReflection == "daily" ? nil : "daily"
                        }
                    }
                )
            }

            if let journey = data.journeyReflection {
                ReflectionCard(
                    icon: "leaf.fill",
                    title: "Journey Reflection",
                    content: journey,
                    color: Color(hex: "74B886"),
                    isExpanded: expandedReflection == "journey",
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedReflection = expandedReflection == "journey" ? nil : "journey"
                        }
                    }
                )
            }

            if let gratitude = data.gratitude {
                ReflectionCard(
                    icon: "heart.fill",
                    title: "Gratitude",
                    content: gratitude,
                    color: Color(hex: "E8B86D"),
                    isExpanded: expandedReflection == "gratitude",
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedReflection = expandedReflection == "gratitude" ? nil : "gratitude"
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Reflection Card
struct ReflectionCard: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)

                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                }

                if isExpanded {
                    Text(content)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(4)
                        .padding(.top, 12)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Journal Entries Section (for Calendar Day Details)
struct JournalEntriesSection: View {
    let entries: [JournalEntry]
    var onAddEntry: (() -> Void)? = nil

    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("Journal Entries")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if let onAdd = onAddEntry {
                    Button(action: onAdd) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Add")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(tealAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(tealAccent.opacity(0.15))
                        )
                    }
                }
            }

            if entries.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.2))

                    Text("No journal entries for this day")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                // Entry previews
                ForEach(entries) { entry in
                    CalendarJournalEntryPreview(entry: entry)
                }
            }
        }
    }
}

// MARK: - Calendar Journal Entry Preview
struct CalendarJournalEntryPreview: View {
    let entry: JournalEntry

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Time
            Text(timeString)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.4))

            // Content
            Text(entry.content)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
                .lineSpacing(2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "1A2230"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

#Preview {
    CalendarView()
}
