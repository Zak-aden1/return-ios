//
//  YourProgressSection.swift
//  ImanPath
//

import SwiftUI

struct YourProgressSection: View {
    let currentStreak: Int
    let checkInsThisWeek: Int
    let commitmentDays: Int = 90

    private let primaryGreen = Color(hex: "74B886")
    private let milestones = MilestoneCatalog.majorDays

    // Calculate goal date
    private var goalDate: String {
        let daysRemaining = max(commitmentDays - currentStreak, 0)
        let targetDate = Calendar.current.date(byAdding: .day, value: daysRemaining, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: targetDate)
    }

    // Find next milestone
    private var nextMilestone: Int? {
        milestones.first { $0 > currentStreak }
    }

    private var daysToNextMilestone: Int {
        guard let next = nextMilestone else { return 0 }
        return next - currentStreak
    }

    // Streak strength based on check-in frequency (7 possible in a week)
    private var streakStrength: (label: String, color: Color) {
        switch checkInsThisWeek {
        case 6...7: return ("Strong", primaryGreen)
        case 4...5: return ("Good", Color(hex: "F59E0B"))
        case 2...3: return ("Building", Color(hex: "F97316"))
        default: return ("Needs Focus", Color(hex: "EF4444"))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Section header with lines
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color(hex: "334155"))
                    .frame(height: 1)

                Text("Your Progress")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .fixedSize()

                Rectangle()
                    .fill(Color(hex: "334155"))
                    .frame(height: 1)
            }

            // 2x2 Grid
            VStack(spacing: 12) {
                // Top row
                HStack(spacing: 12) {
                    // Goal Date Card
                    ProgressStatCard(
                        icon: "🎯",
                        title: "You are on track for",
                        value: goalDate,
                        subtitle: "\(currentStreak)/\(commitmentDays) Days to overcoming\nPorn & Lust"
                    )

                    // Next Milestone Card
                    ProgressStatCard(
                        icon: "⛰️",
                        title: "Next Milestone in",
                        value: "\(daysToNextMilestone) Days",
                        subtitle: nextMilestone != nil ? "Day \(nextMilestone!) awaits" : "Goal reached!"
                    )
                }

                // Bottom row
                HStack(spacing: 12) {
                    // Daily Check-ins Card
                    ProgressStatCard(
                        icon: "📝",
                        title: "Daily Check-ins",
                        value: "\(checkInsThisWeek)",
                        subtitle: "Completed in the last\n7 days"
                    )

                    // Streak Strength Card (reframed from Relapse Risk)
                    ProgressStatCard(
                        icon: streakStrength.label == "Strong" ? "💪" : "🔥",
                        title: "Streak Strength",
                        value: streakStrength.label,
                        valueColor: streakStrength.color,
                        subtitle: "Based on your check-in\nfrequency"
                    )
                }
            }
        }
    }
}

struct ProgressStatCard: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .white
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            // Emoji icon
            Text(icon)
                .font(.system(size: 28))

            // Title
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "94A3B8"))
                .multilineTextAlignment(.center)

            // Value
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(valueColor)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "64748B"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    YourProgressSection(currentStreak: 86, checkInsThisWeek: 5)
        .padding()
        .background(Color(hex: "0A1628"))
}
