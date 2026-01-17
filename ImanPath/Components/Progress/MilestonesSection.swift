//
//  MilestonesSection.swift
//  ImanPath
//

import SwiftUI

struct Milestone: Identifiable {
    let id = UUID()
    let day: Int
    let title: String
    let islamicName: String
    var isCompleted: Bool
}

struct MilestonesSection: View {
    let currentDay: Int
    let onSeeAll: () -> Void

    private let primaryGreen = Color(hex: "74B886")

    private var allMilestones: [Milestone] {
        MilestoneCatalog.definitions.map { definition in
            Milestone(
                day: definition.day,
                title: definition.title,
                islamicName: definition.islamicName,
                isCompleted: currentDay >= definition.day
            )
        }
    }

    // Latest completed milestone
    private var latestAchievement: Milestone? {
        allMilestones.filter { $0.isCompleted }.last
    }

    // Next 2 upcoming milestones
    private var upcomingMilestones: [Milestone] {
        Array(allMilestones.filter { !$0.isCompleted }.prefix(2))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .center) {
                Text("Your Milestones")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Spacer()

                Button(action: onSeeAll) {
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
            Text("Celebrate achievements as you progress through milestones, which represent significant points of growth.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "94A3B8"))
                .lineSpacing(2)

            // Latest Achievement Card
            if let latest = latestAchievement {
                LatestAchievementCard(
                    milestone: latest,
                    accentColor: primaryGreen
                )
            }

            // Upcoming Milestones
            ForEach(upcomingMilestones) { milestone in
                UpcomingMilestoneCard(
                    milestone: milestone,
                    currentDay: currentDay,
                    accentColor: primaryGreen
                )
            }
        }
    }
}

// MARK: - Latest Achievement Card
struct LatestAchievementCard: View {
    let milestone: Milestone
    let accentColor: Color

    @State private var shimmer: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text("LATEST ACHIEVEMENT")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(Color(hex: "1E293B").opacity(0.7))

                Text(milestone.islamicName)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "1E293B"))

                Text("\(milestone.day) Days Free")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "1E293B").opacity(0.7))
            }

            Spacer()

            // Achievement badge placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 80, height: 80)

                // Placeholder icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "1E293B").opacity(0.4))
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Warm gradient background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "F5D485"),
                                Color(hex: "E8B94B")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Shimmer effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmer ? 300 : -300)

                // Star decoration
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.white.opacity(0.5))
                    .offset(x: 80, y: -50)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false).delay(0.5)) {
                shimmer = true
            }
        }
    }
}

// MARK: - Upcoming Milestone Card
struct UpcomingMilestoneCard: View {
    let milestone: Milestone
    let currentDay: Int
    let accentColor: Color

    private var progress: Double {
        min(Double(currentDay) / Double(milestone.day), 1.0)
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    private var daysRemaining: Int {
        max(milestone.day - currentDay, 0)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("UPCOMING")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(Color(hex: "64748B"))

                Text(milestone.islamicName)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("\(milestone.day) Days Free")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "94A3B8"))

                // Progress bar
                HStack(spacing: 12) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "1E293B"))
                                .frame(height: 6)

                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(accentColor)
                                .frame(width: geometry.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(percentage)%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "94A3B8"))
                        .frame(width: 36, alignment: .trailing)
                }
                .padding(.top, 4)
            }

            Spacer()

            // Locked badge placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "1E293B"))
                    .frame(width: 70, height: 70)

                // Blur/locked effect
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "334155").opacity(0.5),
                                Color(hex: "1E293B")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)

                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "64748B"))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            MilestonesSection(currentDay: 5, onSeeAll: { })

            Divider()

            MilestonesSection(currentDay: 45, onSeeAll: { })
        }
        .padding()
    }
    .background(Color(hex: "0A1628"))
}
