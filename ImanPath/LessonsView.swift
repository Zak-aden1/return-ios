//
//  LessonsView.swift
//  ImanPath
//
//  Main lessons view showing all daily lessons with progress
//

import SwiftUI
import SwiftData

struct LessonsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var lessonProgress: [LessonProgress]

    @State private var selectedLesson: LessonContent?
    @State private var userStreakDay: Int = 0

    private let tealAccent = Color(hex: "5B9A9A")
    private let goldAccent = Color(hex: "E8B86D")

    private var completedLessonDays: Set<Int> {
        Set(lessonProgress.map { $0.lessonDay })
    }

    private var completedCount: Int {
        completedLessonDays.count
    }

    private var totalLessons: Int {
        LessonContent.totalLessons
    }

    private var progressPercentage: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedCount) / Double(totalLessons)
    }

    /// Consecutive completed lessons from Day 1
    private var lessonStreak: Int {
        var streak = 0
        for day in 1...totalLessons {
            if completedLessonDays.contains(day) {
                streak = day
            } else {
                break
            }
        }
        return streak
    }

    /// Check if a lesson is locked (beyond user's streak day)
    private func isLessonLocked(_ day: Int) -> Bool {
        return day > userStreakDay
    }

    /// Check if user can access this lesson (unlocked AND previous completed)
    private func canAccessLesson(_ day: Int) -> Bool {
        // Beyond streak = locked
        if day > userStreakDay { return false }
        // Day 1 is always accessible if within streak
        if day == 1 { return true }
        // Otherwise, previous lesson must be completed
        return completedLessonDays.contains(day - 1)
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0A1628"),
                    Color(hex: "0A0E14"),
                    Color(hex: "080B0F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow
            RadialGradient(
                colors: [tealAccent.opacity(0.08), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text("Daily Lessons")
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

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Progress Hero Card
                        ProgressHeroCard(
                            completedCount: completedCount,
                            totalLessons: totalLessons,
                            progressPercentage: progressPercentage,
                            lessonStreak: lessonStreak,
                            userStreakDay: userStreakDay,
                            tealAccent: tealAccent
                        )
                        .padding(.horizontal, 24)

                        // Lessons List
                        VStack(spacing: 12) {
                            ForEach(LessonContent.allLessons) { lesson in
                                LessonCard(
                                    lesson: lesson,
                                    isCompleted: completedLessonDays.contains(lesson.day),
                                    isLocked: isLessonLocked(lesson.day),
                                    canAccess: canAccessLesson(lesson.day),
                                    tealAccent: tealAccent,
                                    goldAccent: goldAccent
                                ) {
                                    if canAccessLesson(lesson.day) {
                                        selectedLesson = lesson
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Coming Soon indicator
                        if totalLessons < 30 {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 14))
                                Text("More lessons coming soon...")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "64748B"))
                            .padding(.top, 8)
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonDetailView(
                lesson: lesson,
                isCompleted: completedLessonDays.contains(lesson.day),
                savedReflection: lessonProgress.first(where: { $0.lessonDay == lesson.day })?.reflectionResponse,
                onComplete: { reflection in
                    markLessonComplete(lesson.day, reflection: reflection)
                }
            )
        }
        .onAppear {
            loadUserStreakDay()
        }
    }

    private func loadUserStreakDay() {
        let dataManager = DataManager(modelContext: modelContext)
        let stats = dataManager.getHomeStats()
        // Use max(1, streak) so Day 1 is always available
        userStreakDay = max(1, stats.currentStreak)
    }

    private func markLessonComplete(_ day: Int, reflection: String?) {
        // Check if already completed
        guard !completedLessonDays.contains(day) else { return }

        let progress = LessonProgress(
            lessonDay: day,
            reflectionResponse: reflection
        )
        modelContext.insert(progress)

        // Schedule notification for next lesson (24h from now)
        NotificationManager.shared.scheduleNextLessonReminder(
            completedDay: day,
            totalLessons: totalLessons
        )
    }
}

// MARK: - Progress Hero Card

struct ProgressHeroCard: View {
    let completedCount: Int
    let totalLessons: Int
    let progressPercentage: Double
    let lessonStreak: Int
    let userStreakDay: Int
    let tealAccent: Color

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR PROGRESS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(completedCount) of \(totalLessons) completed")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                // Streak day badge (shows user's recovery streak)
                VStack(spacing: 2) {
                    Text("Day \(userStreakDay)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Streak")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                )
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 10)

                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progressPercentage, height: 10)
                }
            }
            .frame(height: 10)

            // Percentage
            HStack {
                Text("\(Int(progressPercentage * 100))% complete")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                if lessonStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                        Text("Keep going!")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [tealAccent, tealAccent.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: tealAccent.opacity(0.3), radius: 20, y: 10)
        )
    }
}

// MARK: - Lesson Card

struct LessonCard: View {
    let lesson: LessonContent
    let isCompleted: Bool
    let isLocked: Bool      // Beyond streak day
    let canAccess: Bool     // Within streak AND previous completed
    let tealAccent: Color
    let goldAccent: Color
    let onTap: () -> Void

    // Can't tap if locked OR if unlocked but previous not done
    private var isDisabled: Bool {
        isLocked || !canAccess
    }

    // Show "complete previous" message if unlocked but can't access
    private var needsPreviousComplete: Bool {
        !isLocked && !canAccess && !isCompleted
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Day badge
                ZStack {
                    Circle()
                        .fill(
                            isCompleted ?
                            LinearGradient(colors: [tealAccent, tealAccent.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            isLocked ?
                            LinearGradient(colors: [Color(hex: "334155"), Color(hex: "1E293B")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color(hex: "1E293B"), Color(hex: "131C2D")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "64748B"))
                    } else {
                        Text("\(lesson.day)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Day \(lesson.day)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))

                        Spacer()

                        // Status indicator
                        if isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("COMPLETED")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(tealAccent)
                        } else if isLocked {
                            Text("LOCKED")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(hex: "64748B"))
                        } else if needsPreviousComplete {
                            Text("COMPLETE DAY \(lesson.day - 1) FIRST")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(hex: "64748B"))
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 10))
                                Text("\(lesson.readTimeMinutes) MIN")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(goldAccent)
                        }
                    }

                    Text(lesson.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDisabled ? Color(hex: "64748B") : .white)
                        .lineLimit(1)

                    Text(lesson.verseReference)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isDisabled ? Color(hex: "475569") : tealAccent.opacity(0.8))
                }

                Spacer()

                // Arrow
                if !isDisabled {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "64748B"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "131C2D"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCompleted ? tealAccent.opacity(0.3) :
                                isDisabled ? Color(hex: "1E293B") :
                                Color(hex: "334155").opacity(0.5),
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isLocked ? 0.6 : (needsPreviousComplete ? 0.8 : 1))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

#Preview {
    LessonsView()
}
