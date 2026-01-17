//
//  DailyLessonsCard.swift
//  ImanPath
//
//  Home card for accessing daily lessons
//

import SwiftUI
import SwiftData

struct DailyLessonsCard: View {
    let userStreakDay: Int
    let onTap: () -> Void

    @Query private var lessonProgress: [LessonProgress]

    private let tealAccent = Color(hex: "5B9A9A")
    private let goldAccent = Color(hex: "E8B86D")
    private let successGreen = Color(hex: "74B886")

    private var completedLessonDays: Set<Int> {
        Set(lessonProgress.map { $0.lessonDay })
    }

    private var completedCount: Int {
        completedLessonDays.count
    }

    private var totalLessons: Int {
        LessonContent.totalLessons
    }

    /// Today's lesson based on streak day
    private var todaysLessonDay: Int {
        max(1, min(userStreakDay, totalLessons))
    }

    /// Is today's lesson completed?
    private var isTodaysLessonCompleted: Bool {
        completedLessonDays.contains(todaysLessonDay)
    }

    private var todaysLesson: LessonContent? {
        LessonContent.lesson(for: todaysLessonDay)
    }

    private var allCompleted: Bool {
        completedCount >= totalLessons
    }

    var body: some View {
        Button(action: onTap) {
            if isTodaysLessonCompleted && !allCompleted {
                // Completed state - Unchained style
                completedCardContent
            } else {
                // Default state - show next lesson or all completed
                defaultCardContent
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Completed State (Today's lesson done)
    // Same layout as default, just with green accents

    private var completedCardContent: some View {
        HStack(spacing: 16) {
            // Icon - same style but green with checkmark
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [successGreen.opacity(0.3), successGreen.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(successGreen)
            }

            // Content - same layout as default
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("DAILY LESSONS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(Color(hex: "64748B"))

                    Spacer()

                    // Progress badge - green
                    Text("\(completedCount)/\(totalLessons)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(successGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(successGreen.opacity(0.15))
                        )
                }

                if let lesson = todaysLesson {
                    Text("Day \(lesson.day): \(lesson.title)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                // Progress bar - green
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "1E293B"))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(successGreen)
                            .frame(
                                width: geo.size.width * (Double(completedCount) / Double(max(totalLessons, 1))),
                                height: 4
                            )
                    }
                }
                .frame(height: 4)
                .padding(.top, 4)
            }

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "64748B"))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(successGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Default State

    private var defaultCardContent: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [tealAccent.opacity(0.3), tealAccent.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: "book.fill")
                    .font(.system(size: 22))
                    .foregroundColor(tealAccent)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("DAILY LESSONS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(Color(hex: "64748B"))

                    Spacer()

                    // Progress badge
                    Text("\(completedCount)/\(totalLessons)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(tealAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(tealAccent.opacity(0.15))
                        )
                }

                if allCompleted {
                    Text("All lessons completed!")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                } else if let lesson = todaysLesson {
                    Text("Day \(lesson.day): \(lesson.title)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "1E293B"))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(tealAccent)
                            .frame(
                                width: geo.size.width * (Double(completedCount) / Double(max(totalLessons, 1))),
                                height: 4
                            )
                    }
                }
                .frame(height: 4)
                .padding(.top, 4)
            }

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "64748B"))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "1E293B"), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()
        VStack(spacing: 20) {
            // Default state (Day 1 not completed)
            DailyLessonsCard(userStreakDay: 1, onTap: {})

            // Note: Completed state shows when lesson matching streakDay is done
        }
        .padding()
    }
}
