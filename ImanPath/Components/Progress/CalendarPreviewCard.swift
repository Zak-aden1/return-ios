//
//  CalendarPreviewCard.swift
//  ImanPath
//

import SwiftUI

struct CalendarPreviewCard: View {
    let onTap: () -> Void
    var streakStartDate: Date? = nil
    var currentStreak: Int = 2
    var totalDays: Int = 90
    var journalEntries: Int = 3
    var checkIns: Int = 5

    private let primaryGreen = Color(hex: "74B886")

    // Calculate current week dates
    private var currentWeekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    private var todayIndex: Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: Date()) - 1
    }

    // Goal date calculation
    private var goalDate: String {
        let daysRemaining = max(totalDays - currentStreak, 0)
        let targetDate = Calendar.current.date(byAdding: .day, value: daysRemaining, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: targetDate)
    }

    private var daysLeft: Int {
        max(totalDays - currentStreak, 0)
    }

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: Date())
    }

    private var streakStrength: (text: String, color: Color) {
        let percentage = Double(currentStreak) / Double(totalDays)
        if percentage >= 0.5 {
            return ("Strong", primaryGreen)
        } else if percentage >= 0.2 {
            return ("Growing", Color(hex: "F5D485"))
        } else {
            return ("Building", Color(hex: "94A3B8"))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(alignment: .center) {
                Text("Your Calendar")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Spacer()

                Button(action: onTap) {
                    HStack(spacing: 4) {
                        Text("More")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(primaryGreen.opacity(0.3))
                    )
                }
            }

            // Subtitle
            Text("Track daily activities and journal entries. Use the calendar to maintain motivation and consistency.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "94A3B8"))
                .lineSpacing(2)

            // Week Strip
            WeekStripView(
                dates: currentWeekDates,
                todayIndex: todayIndex,
                accentColor: primaryGreen,
                currentStreak: currentStreak,
                streakStartDate: streakStartDate
            )

            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                // Row 1
                StatCard(emoji: "📅", label: "Today", value: todayDateString)
                StatCard(emoji: "🎯", label: "Goal Date", value: goalDate)
                StatCard(emoji: "⏳", label: "Days Left", value: "\(daysLeft)")

                // Row 2
                StatCard(emoji: "📝", label: "Journal", value: "\(journalEntries)")
                StatCard(emoji: "🤲", label: "Check-ins", value: "\(checkIns)")
                StatCard(
                    emoji: "💪",
                    label: "Strength",
                    value: streakStrength.text,
                    valueColor: streakStrength.color
                )
            }
        }
    }
}

// MARK: - Week Strip View
struct WeekStripView: View {
    let dates: [Date]
    let todayIndex: Int
    let accentColor: Color
    var currentStreak: Int = 0
    var streakStartDate: Date? = nil

    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let milestoneDays = MilestoneCatalog.days
    private let warmGold = Color(hex: "E8B86D")

    // Check if a day is a future milestone
    // currentStreak is days elapsed (Day 0 = start day)
    private func isFutureMilestone(at index: Int) -> Bool {
        guard index > todayIndex else { return false }
        guard streakStartDate != nil else { return false }
        let daysUntil = index - todayIndex
        let futureStreakDay = currentStreak + daysUntil
        return milestoneDays.contains(futureStreakDay)
    }

    // Check if a day was a past milestone achievement
    private func isPastMilestone(at index: Int) -> Bool {
        guard let startDate = streakStartDate, index < dates.count else { return false }
        guard index < todayIndex else { return false }  // Only past days

        let calendar = Calendar.current
        let cellDate = dates[index]

        // Calculate which streak day this calendar date was
        let daysSinceStart = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: calendar.startOfDay(for: cellDate)).day ?? -1

        let streakDay = daysSinceStart

        return streakDay > 0 && milestoneDays.contains(streakDay)
    }

    // Check if today is a milestone
    // currentStreak is days elapsed (Day 0 = start day)
    private func isTodayMilestone() -> Bool {
        guard streakStartDate != nil else { return false }
        return milestoneDays.contains(currentStreak)
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                let isAchievedMilestone = isPastMilestone(at: index) || (index == todayIndex && isTodayMilestone())
                WeekDayCell(
                    index: index,
                    todayIndex: todayIndex,
                    dates: dates,
                    accentColor: accentColor,
                    isFutureMilestone: isFutureMilestone(at: index),
                    isAchievedMilestone: isAchievedMilestone,
                    dayLabel: dayLabels[index],
                    warmGold: warmGold
                )
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "0F172A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Week Day Cell
private struct WeekDayCell: View {
    let index: Int
    let todayIndex: Int
    let dates: [Date]
    let accentColor: Color
    let isFutureMilestone: Bool
    let isAchievedMilestone: Bool
    let dayLabel: String
    let warmGold: Color

    private var isToday: Bool { index == todayIndex }
    private var isFuture: Bool { index > todayIndex }

    private var dayNumber: String {
        guard index < dates.count else { return "" }
        let calendar = Calendar.current
        let day = calendar.component(.day, from: dates[index])
        return "\(day)"
    }

    var body: some View {
        VStack(spacing: 8) {
            // Day label
            Text(dayLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(
                    isToday ? accentColor :
                    isAchievedMilestone ? warmGold :
                    isFuture ? Color(hex: "475569") :
                    Color(hex: "64748B")
                )

            // Day number with styling
            ZStack {
                // Today highlight
                if isToday {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Circle()
                        .stroke(accentColor, lineWidth: 2)
                        .frame(width: 40, height: 40)
                }

                // Achieved milestone background (past or today)
                if isAchievedMilestone && !isToday {
                    Circle()
                        .fill(warmGold.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Circle()
                        .stroke(warmGold.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                }

                // Future milestone background
                if isFutureMilestone {
                    Circle()
                        .fill(warmGold.opacity(0.15))
                        .frame(width: 40, height: 40)
                }

                // Content based on state
                if isFutureMilestone {
                    // Future milestone - show lock
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(warmGold)
                } else if isAchievedMilestone {
                    // Achieved milestone - show star
                    VStack(spacing: 0) {
                        Text(dayNumber)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isToday ? .white : warmGold)
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(warmGold)
                    }
                } else {
                    // Regular day
                    Text(dayNumber)
                        .font(.system(size: 16, weight: isToday ? .bold : .medium))
                        .foregroundColor(
                            isToday ? .white :
                            isFuture ? Color(hex: "475569") :
                            .white
                        )
                }
            }
            .frame(width: 44, height: 44)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let emoji: String
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 20))

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "64748B"))

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "334155").opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ScrollView {
        CalendarPreviewCard(onTap: { })
            .padding()
    }
    .background(Color(hex: "0A1628"))
}
