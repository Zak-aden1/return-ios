//
//  ProfileView.swift
//  ImanPath
//
//  User profile with journey stats and milestone badges
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var user: User?
    @State private var homeStats: HomeStats?
    @State private var showSettings = false
    @State private var showMilestones = false

    // Milestone definitions for badges
    private let milestones: [(day: Int, name: String, islamicName: String, icon: String, colors: [Color])] = [
        (1, "First Step", "Tawbah", "leaf.fill", [Color(hex: "74B886"), Color(hex: "5A9A6E")]),
        (3, "Reborn", "Tajdeed", "sunrise.fill", [Color(hex: "F5D485"), Color(hex: "E8B86D")]),
        (7, "First Week", "Sabr", "shield.fill", [Color(hex: "60A5FA"), Color(hex: "3B82F6")]),
        (14, "Two Weeks", "Istiqamah", "arrow.up.circle.fill", [Color(hex: "8B5CF6"), Color(hex: "7C3AED")]),
        (30, "One Month", "Mujahadah", "flame.fill", [Color(hex: "F97316"), Color(hex: "EA580C")]),
        (50, "Fifty Days", "Thiqah", "hand.raised.fill", [Color(hex: "EC4899"), Color(hex: "DB2777")]),
        (60, "Two Months", "Taqwa", "eye.fill", [Color(hex: "5B9A9A"), Color(hex: "4A8585")]),
        (90, "Three Months", "Ihsan", "star.fill", [Color(hex: "FBBF24"), Color(hex: "F59E0B")]),
        (365, "One Year", "Falah", "crown.fill", [Color(hex: "E8B86D"), Color(hex: "D4A056")])
    ]

    private var currentStreakDays: Int {
        homeStats?.currentStreak ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                            .padding(.top, 20)

                        // Milestone Badges
                        milestoneBadges
                            .padding(.top, 8)

                        // Journey Stats
                        statsCard
                            .padding(.horizontal, 20)

                        // My Why Link
                        myWhyCard
                            .padding(.horizontal, 20)

                        // Journey Info
                        journeyInfoCard
                            .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                }
            }
            .toolbarBackground(Color(hex: "0A1628"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $showMilestones) {
                MilestonesPageView(currentDay: currentStreakDays)
            }
        }
        .onAppear {
            loadData()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1E3A5F"), Color(hex: "0F2942")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                if let name = user?.userName, !name.isEmpty {
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "74B886"))
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "64748B"))
                }
            }
            .overlay(
                Circle()
                    .stroke(Color(hex: "334155"), lineWidth: 3)
            )

            // Name
            VStack(spacing: 4) {
                Text(user?.userName ?? "Traveler")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                if let startDate = user?.commitmentSignedAt {
                    Text("Journey started \(formatDate(startDate))")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "64748B"))
                }
            }
        }
    }

    // MARK: - Milestone Badges

    private var milestoneBadges: some View {
        Button(action: { showMilestones = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Milestones")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "64748B"))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "64748B"))
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(milestones, id: \.day) { milestone in
                            ProfileMilestoneBadge(
                                icon: milestone.icon,
                                name: milestone.islamicName,
                                isUnlocked: currentStreakDays >= milestone.day,
                                colors: milestone.colors
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ProfileStatItem(
                    value: "\(homeStats?.currentStreak ?? 0)",
                    label: "Current",
                    icon: "flame.fill",
                    color: Color(hex: "74B886")
                )

                Divider()
                    .frame(height: 40)
                    .background(Color(hex: "334155"))

                ProfileStatItem(
                    value: "\(homeStats?.longestStreak ?? 0)",
                    label: "Longest",
                    icon: "trophy.fill",
                    color: Color(hex: "FBBF24")
                )

                Divider()
                    .frame(height: 40)
                    .background(Color(hex: "334155"))

                ProfileStatItem(
                    value: "\(homeStats?.totalCleanDays ?? 0)",
                    label: "Total Days",
                    icon: "calendar",
                    color: Color(hex: "60A5FA")
                )
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1A2737"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "334155"), lineWidth: 1)
        )
    }

    // MARK: - My Why Card

    private var myWhyCard: some View {
        NavigationLink(destination: MyWhyView()) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: "74B886").opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "74B886"))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("My Why")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Your reasons for this journey")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "64748B"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "64748B"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "1A2737"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "334155"), lineWidth: 1)
            )
        }
    }

    // MARK: - Journey Info Card

    private var journeyInfoCard: some View {
        VStack(spacing: 0) {
            InfoRow(
                icon: "calendar.badge.clock",
                label: "Check-ins this week",
                value: "\(homeStats?.checkinsThisWeek ?? 0)"
            )

            Divider()
                .background(Color(hex: "334155"))
                .padding(.horizontal, 16)

            InfoRow(
                icon: "book.fill",
                label: "Journal entries",
                value: "\(homeStats?.journalEntriesThisWeek ?? 0) this week"
            )

            if let commitmentDate = homeStats?.commitmentDate {
                Divider()
                    .background(Color(hex: "334155"))
                    .padding(.horizontal, 16)

                InfoRow(
                    icon: "flag.fill",
                    label: "Commitment goal",
                    value: formatDate(commitmentDate)
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1A2737"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "334155"), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func loadData() {
        let dataManager = DataManager(modelContext: modelContext)
        user = dataManager.getOrCreateUser()
        homeStats = dataManager.getHomeStats()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct ProfileMilestoneBadge: View {
    let icon: String
    let name: String
    let isUnlocked: Bool
    let colors: [Color]

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                            ? LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color(hex: "1A2737"), Color(hex: "1A2737")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: isUnlocked ? icon : "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isUnlocked ? .white : Color(hex: "64748B"))
            }
            .overlay(
                Circle()
                    .stroke(isUnlocked ? colors[0].opacity(0.5) : Color(hex: "334155"), lineWidth: 2)
            )

            Text(name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isUnlocked ? .white : Color(hex: "64748B"))
        }
    }
}

struct ProfileStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "64748B"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "64748B"))
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "94A3B8"))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(16)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [User.self, Streak.self, CheckIn.self, JournalEntry.self, WhyEntry.self], inMemory: true)
}
