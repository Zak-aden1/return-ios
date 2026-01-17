//
//  MilestonesPageView.swift
//  ImanPath
//
//  Full milestones page showing all achievements and progress
//

import SwiftUI

struct MilestoneData: Identifiable {
    let id = UUID()
    let day: Int
    let title: String
    let islamicName: String
    let meaning: String
    let verse: String?
    let verseReference: String?
    let badgeIcon: String  // SF Symbol for the badge
    let badgeColors: [Color]  // Gradient colors for the badge
    var isCompleted: Bool
}

struct MilestonesPageView: View {
    @Environment(\.dismiss) private var dismiss
    let currentDay: Int

    @State private var selectedMilestone: MilestoneData?

    private let primaryGreen = Color(hex: "74B886")
    private let goldAccent = Color(hex: "E8B86D")

    private var milestones: [MilestoneData] {
        MilestoneCatalog.definitions.map { definition in
            MilestoneData(
                day: definition.day,
                title: definition.title,
                islamicName: definition.islamicName,
                meaning: definition.meaning,
                verse: definition.verse,
                verseReference: definition.verseReference,
                badgeIcon: definition.icon,
                badgeColors: definition.colors,
                isCompleted: currentDay >= definition.day
            )
        }
    }

    private var completedMilestones: [MilestoneData] {
        milestones.filter { $0.isCompleted }
    }

    private var latestAchievement: MilestoneData? {
        completedMilestones.last
    }

    private var nextMilestone: MilestoneData? {
        milestones.first { !$0.isCompleted }
    }

    private var daysToNext: Int {
        guard let next = nextMilestone else { return 0 }
        return max(next.day - currentDay, 0)
    }

    private var progressToNext: Double {
        guard let next = nextMilestone else { return 1.0 }
        let previousDay = latestAchievement?.day ?? 0
        let range = Double(next.day - previousDay)
        let current = Double(currentDay - previousDay)
        return min(max(current / range, 0), 1.0)
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

            // Ambient glow
            RadialGradient(
                colors: [goldAccent.opacity(0.08), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text("Milestones")
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
                        // Hero: Latest Achievement Card
                        if let latest = latestAchievement {
                            LatestAchievementHero(
                                milestone: latest,
                                currentDay: currentDay,
                                nextMilestone: nextMilestone,
                                daysToNext: daysToNext,
                                progressToNext: progressToNext,
                                goldAccent: goldAccent
                            )
                            .padding(.horizontal, 24)
                        }

                        // Milestones List
                        VStack(spacing: 12) {
                            ForEach(milestones) { milestone in
                                Button(action: {
                                    selectedMilestone = milestone
                                }) {
                                    MilestoneCard(
                                        milestone: milestone,
                                        currentDay: currentDay,
                                        goldAccent: goldAccent,
                                        primaryGreen: primaryGreen
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 60)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarHidden(true)
        .overlay {
            if selectedMilestone != nil {
                MilestoneDetailModal(
                    milestone: $selectedMilestone,
                    currentDay: currentDay,
                    primaryGreen: primaryGreen,
                    goldAccent: goldAccent
                )
            }
        }
    }
}

// MARK: - Latest Achievement Hero
struct LatestAchievementHero: View {
    let milestone: MilestoneData
    let currentDay: Int
    let nextMilestone: MilestoneData?
    let daysToNext: Int
    let progressToNext: Double
    let goldAccent: Color

    @State private var shimmer: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Main hero content
            HStack(alignment: .top, spacing: 16) {
                // Badge
                MilestoneBadge(
                    icon: milestone.badgeIcon,
                    colors: milestone.badgeColors,
                    size: 80,
                    isLocked: false
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("LATEST ACHIEVEMENT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(Color(hex: "1E293B").opacity(0.6))

                    Text(milestone.islamicName)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "1E293B"))

                    Text("\(milestone.day) Days • \(milestone.title)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "1E293B").opacity(0.7))
                }

                Spacer()

                // Days count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(currentDay)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "1E293B"))

                    Text("Days Free")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "1E293B").opacity(0.6))
                }
            }
            .padding(20)

            // Progress to next milestone
            if let next = nextMilestone {
                VStack(spacing: 8) {
                    HStack {
                        Text("\(daysToNext) days to \(next.islamicName)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "1E293B").opacity(0.7))

                        Spacer()

                        Text("\(Int(progressToNext * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "1E293B").opacity(0.8))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "1E293B").opacity(0.2))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "1E293B").opacity(0.6))
                                .frame(width: geo.size.width * progressToNext, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .background(
            ZStack {
                // Warm gradient background
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 24)
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
                    .offset(x: shimmer ? 400 : -400)

                // Decorative stars
                GeometryReader { geo in
                    Image(systemName: "sparkle")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.5))
                        .position(x: geo.size.width - 30, y: 25)

                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.4))
                        .position(x: geo.size.width - 60, y: 45)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false).delay(0.5)) {
                shimmer = true
            }
        }
    }
}

// MARK: - Milestone Badge
struct MilestoneBadge: View {
    let icon: String
    let colors: [Color]
    let size: CGFloat
    let isLocked: Bool

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    isLocked ?
                    LinearGradient(colors: [Color(hex: "334155"), Color(hex: "1E293B")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: size, height: size)

            // Inner glow
            if !isLocked {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: size * 0.7, height: size * 0.7)
                    .blur(radius: 8)
            }

            // Icon
            Image(systemName: isLocked ? "lock.fill" : icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(isLocked ? Color(hex: "64748B") : .white)
        }
    }
}

// MARK: - Milestone Card
struct MilestoneCard: View {
    let milestone: MilestoneData
    let currentDay: Int
    let goldAccent: Color
    let primaryGreen: Color

    private var progress: Double {
        guard !milestone.isCompleted else { return 1.0 }
        let previousDay = getPreviousMilestoneDay()
        let range = Double(milestone.day - previousDay)
        let current = Double(currentDay - previousDay)
        return min(max(current / range, 0), 1.0)
    }

    private var daysRemaining: Int {
        max(milestone.day - currentDay, 0)
    }

    private func getPreviousMilestoneDay() -> Int {
        let days = [0, 1, 3, 7, 14, 30, 50, 60, 75, 90, 120, 150, 270, 365]
        if let index = days.firstIndex(of: milestone.day), index > 0 {
            return days[index - 1]
        }
        return 0
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Badge
            MilestoneBadge(
                icon: milestone.badgeIcon,
                colors: milestone.badgeColors,
                size: 56,
                isLocked: !milestone.isCompleted
            )

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Header row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(milestone.day) Days")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))

                        Text(milestone.islamicName)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(milestone.isCompleted ? goldAccent : .white)
                    }

                    Spacer()

                    // Status badge
                    if milestone.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                            Text("ACHIEVED")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(goldAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(goldAccent.opacity(0.15))
                        )
                    } else {
                        Text("LOCKED")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "64748B"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "334155").opacity(0.5))
                            )
                    }
                }

                // Meaning (always visible)
                Text(milestone.meaning)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "94A3B8"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Progress bar for incomplete milestones
                if !milestone.isCompleted {
                    HStack(spacing: 10) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: "1E293B"))
                                    .frame(height: 5)

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(primaryGreen)
                                    .frame(width: geo.size.width * progress, height: 5)
                            }
                        }
                        .frame(height: 5)

                        Text("\(daysRemaining)d left")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))
                            .frame(width: 45, alignment: .trailing)
                    }
                    .padding(.top, 4)
                }

                // Verse (if available and completed)
                if milestone.isCompleted, let verse = milestone.verse, let ref = milestone.verseReference {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(primaryGreen.opacity(0.5))
                            .frame(width: 2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\"\(verse)\"")
                                .font(.system(size: 12, weight: .regular, design: .serif))
                                .italic()
                                .foregroundColor(.white.opacity(0.7))

                            Text("— \(ref)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(primaryGreen)
                        }
                    }
                    .padding(.top, 6)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            milestone.isCompleted ?
                                goldAccent.opacity(0.25) :
                                Color(hex: "334155").opacity(0.5),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Milestone Detail Modal
struct MilestoneDetailModal: View {
    @Binding var milestone: MilestoneData?
    let currentDay: Int
    let primaryGreen: Color
    let goldAccent: Color

    @State private var isAnimating: Bool = false
    @State private var showContent: Bool = false

    private var daysRemaining: Int {
        guard let milestone = milestone else { return 0 }
        return max(milestone.day - currentDay, 0)
    }

    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        ZStack {
            // Dimmed background overlay
            Color.black
                .opacity(isAnimating ? 0.7 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }

            // Floating modal card
            if let milestone = milestone {
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Drag indicator
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 4)
                                .padding(.top, 16)

                            // Large Badge Container
                            ZStack {
                                // Outer glow for unlocked
                                if milestone.isCompleted {
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(milestone.badgeColors[0].opacity(0.2))
                                        .frame(width: 150, height: 150)
                                        .blur(radius: 20)
                                }

                                // Badge container
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: milestone.isCompleted ?
                                                [Color(hex: "1E293B"), Color(hex: "0F172A")] :
                                                [Color(hex: "1E293B"), Color(hex: "0F172A")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                milestone.isCompleted ?
                                                    LinearGradient(colors: milestone.badgeColors, startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                    LinearGradient(colors: [Color(hex: "334155"), Color(hex: "1E293B")], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: milestone.isCompleted ? 3 : 1
                                            )
                                    )
                                    .shadow(color: milestone.isCompleted ? milestone.badgeColors[0].opacity(0.3) : Color.clear, radius: 20)

                                // Badge icon
                                MilestoneBadge(
                                    icon: milestone.badgeIcon,
                                    colors: milestone.badgeColors,
                                    size: 80,
                                    isLocked: !milestone.isCompleted
                                )
                            }
                            .padding(.top, 8)

                            // Status pill
                            if milestone.isCompleted {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 12))
                                    Text("UNLOCKED")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(1)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [primaryGreen, primaryGreen.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: primaryGreen.opacity(0.4), radius: 8, y: 2)
                                )
                            } else {
                                Text("\(daysRemaining) MORE DAYS TO UNLOCK")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.5)
                                    .foregroundColor(Color(hex: "92400E"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "FDE68A"), Color(hex: "FCD34D")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            }

                            // Title section
                            VStack(spacing: 6) {
                                Text(milestone.islamicName)
                                    .font(.system(size: 32, weight: .bold, design: .serif))
                                    .foregroundColor(milestone.isCompleted ? goldAccent : .white)

                                Text("\(milestone.day) Days Free")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                            }

                            // Description
                            Text(milestone.meaning)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color(hex: "94A3B8"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)

                            // Verse card (if available)
                            if let verse = milestone.verse, let ref = milestone.verseReference {
                                VStack(spacing: 10) {
                                    Text("\"\(verse)\"")
                                        .font(.system(size: 14, weight: .regular, design: .serif))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(3)

                                    Text("— \(ref)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(tealAccent)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(tealAccent.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(tealAccent.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }

                            Spacer(minLength: 16)
                        }
                    }

                    // Close button
                    Button(action: { dismissModal() }) {
                        Text("Close")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(tealAccent)
                                    .shadow(color: tealAccent.opacity(0.3), radius: 8, y: 2)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .frame(maxWidth: 340)
                .frame(maxHeight: 620)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "1A2433"),
                                    Color(hex: "131C2D"),
                                    Color(hex: "0F1620")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.5), radius: 40, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.02)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(showContent ? 1 : 0.85)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                isAnimating = true
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75).delay(0.05)) {
                showContent = true
            }
        }
    }

    private func dismissModal() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            showContent = false
        }
        withAnimation(.easeIn(duration: 0.2).delay(0.1)) {
            isAnimating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            milestone = nil
        }
    }
}

#Preview {
    MilestonesPageView(currentDay: 86)
}
