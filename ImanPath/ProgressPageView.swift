//
//  ProgressPageView.swift
//  ImanPath
//

import SwiftUI
import SwiftData

struct ProgressPageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date) private var journalEntries: [JournalEntry]
    @Query(sort: \CheckIn.date) private var checkIns: [CheckIn]

    @State private var currentStreak: Int = 0
    @State private var streakStartDate: Date? = nil
    @State private var showAllMilestones: Bool = false
    @Environment(\.dismiss) private var dismiss

    private let primaryGreen = Color(hex: "74B886")

    private func loadData() {
        let dataManager = DataManager(modelContext: modelContext)
        currentStreak = dataManager.calculateCurrentStreakDays()
        streakStartDate = dataManager.getCurrentStreak()?.startedAt
    }

    // Mood data computed from check-ins (averages converted to 0-100 scale)
    private var moodData: [RadarDataPoint] {
        guard !checkIns.isEmpty else {
            // No check-ins yet - return zeros
            return [
                RadarDataPoint(label: "Mood", value: 0),
                RadarDataPoint(label: "Energy", value: 0),
                RadarDataPoint(label: "Self Control", value: 0),
                RadarDataPoint(label: "Faith", value: 0),
                RadarDataPoint(label: "Confidence", value: 0)
            ]
        }

        let count = Double(checkIns.count)

        // Calculate averages (1-10 scale) then convert to percentage (0-100), capped at 100
        let avgMood = min((checkIns.reduce(0.0) { $0 + Double($1.moodRating) } / count) * 10, 100)
        let avgEnergy = min((checkIns.reduce(0.0) { $0 + Double($1.energyRating) } / count) * 10, 100)
        let avgSelfControl = min((checkIns.reduce(0.0) { $0 + Double($1.selfControlRating) } / count) * 10, 100)
        let avgFaith = min((checkIns.reduce(0.0) { $0 + Double($1.faithRating) } / count) * 10, 100)
        let avgConfidence = min((checkIns.reduce(0.0) { $0 + Double($1.confidenceRating) } / count) * 10, 100)

        return [
            RadarDataPoint(label: "Mood", value: avgMood),
            RadarDataPoint(label: "Energy", value: avgEnergy),
            RadarDataPoint(label: "Self Control", value: avgSelfControl),
            RadarDataPoint(label: "Faith", value: avgFaith),
            RadarDataPoint(label: "Confidence", value: avgConfidence)
        ]
    }

    var body: some View {
        ZStack {
            // Background
            SpaceBackground()

            // Content
            VStack(spacing: 0) {
                // Sticky Header
                ZStack {
                    Text("Your Progress")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Section 1: Journey Ring
                        JourneyRingView(
                            currentDay: currentStreak,
                            totalDays: 90,
                            accentColor: primaryGreen
                        )
                        .padding(.horizontal, 24)

                        // Divider
                        SectionDivider()
                            .padding(.horizontal, 24)

                        // Section 2: Calendar Preview
                        CalendarPreviewCardWithNav(
                            streakStartDate: streakStartDate,
                            currentStreak: currentStreak,
                            totalDays: 90,
                            journalEntries: journalEntries.count,
                            checkIns: checkIns.count
                        )
                        .padding(.horizontal, 24)

                        // Divider
                        SectionDivider()
                            .padding(.horizontal, 24)

                        // Section 3: Milestones
                        MilestonesSection(currentDay: currentStreak) {
                            showAllMilestones = true
                        }
                        .padding(.horizontal, 24)

                        // Divider
                        SectionDivider()
                            .padding(.horizontal, 24)

                        // Section 4: Mood Analysis
                        MoodAnalysisSection(moodData: moodData)
                            .padding(.horizontal, 24)

                        // Inspiration Quote (simple, at the end)
                        VStack(spacing: 12) {
                            Text("\"And whoever is mindful of Allah, He will make a way out for them.\"")
                                .font(.system(size: 15, weight: .regular, design: .serif))
                                .italic()
                                .foregroundColor(Color(hex: "64748B"))
                                .multilineTextAlignment(.center)

                            Text("— Quran 65:2")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "475569"))
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)

                        // Bottom spacing
                        Spacer(minLength: 60)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showAllMilestones) {
            MilestonesPageView(currentDay: currentStreak)
        }
        .onAppear { loadData() }
    }
}

// MARK: - Calendar Preview with Navigation
struct CalendarPreviewCardWithNav: View {
    var streakStartDate: Date? = nil
    var currentStreak: Int = 2
    var totalDays: Int = 90
    var journalEntries: Int = 3
    var checkIns: Int = 5

    var body: some View {
        NavigationLink(destination: CalendarView()) {
            CalendarPreviewCardContent(
                streakStartDate: streakStartDate,
                currentStreak: currentStreak,
                totalDays: totalDays,
                journalEntries: journalEntries,
                checkIns: checkIns
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Calendar Preview Content (without navigation)
struct CalendarPreviewCardContent: View {
    var streakStartDate: Date? = nil
    var currentStreak: Int = 2
    var totalDays: Int = 90
    var journalEntries: Int = 3
    var checkIns: Int = 5

    private let primaryGreen = Color(hex: "74B886")

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
        Calendar.current.component(.weekday, from: Date()) - 1
    }

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
                StatCard(emoji: "📅", label: "Today", value: todayDateString)
                StatCard(emoji: "🎯", label: "Goal Date", value: goalDate)
                StatCard(emoji: "⏳", label: "Days Left", value: "\(daysLeft)")
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

#Preview {
    NavigationStack {
        ProgressPageView()
    }
}
