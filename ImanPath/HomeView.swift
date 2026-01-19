//
//  HomeView.swift
//  ImanPath
//

import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    // Telegram community link
    private let communityURL = "https://t.me/+OlG8JBruJMYxN2E0"
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var journalEntries: [JournalEntry]
    @Query private var whyEntries: [WhyEntry]

    // Home stats (computed from SwiftData)
    @State private var homeStats: HomeStats?

    // Live timer
    @State private var timerString: String = "0h 0m 0s"
    @State private var streakStartDate: Date?
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Navigation states
    @State private var showProgressPage: Bool = false
    @State private var showPanicView: Bool = false
    @State private var showCheckIn: Bool = false
    @State private var showJournal: Bool = false
    @State private var showMyWhy: Bool = false
    @State private var showDuas: Bool = false
    @State private var showBreathing: Bool = false
    @State private var showGrounding: Bool = false
    @State private var showStreakCoach: Bool = false
    @State private var showProfile: Bool = false
    @State private var showLessons: Bool = false

    // Milestone celebration
    @State private var showMilestoneCelebration: Bool = false
    @State private var celebrationMilestone: CelebrationMilestone?

    // Today's check-in score (0-100)
    @State private var todayCheckInScore: Int = 0

    private var currentStreak: Int {
        homeStats?.currentStreak ?? 0
    }

    private var lastCelebratedMilestoneDay: Int {
        homeStats?.lastCelebratedMilestone ?? 0
    }

    private let milestoneDefinitions = MilestoneCatalog.definitions

    var body: some View {
        NavigationStack {
        ZStack {
            // Background
            SpaceBackground()

            // Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HeaderView(
                        streakBadge: currentStreak,
                        onProfileTap: { showProfile = true }
                    )
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    // Streak Counter
                    StreakSection(
                        days: currentStreak,
                        timerString: timerString
                    )
                    .padding(.top, 16)

                    // Quick Actions
                    QuickActionsSection(
                        onCheckInTap: { showCheckIn = true },
                        onProgressTap: { showProgressPage = true },
                        onCommunityTap: {
                            if let url = URL(string: communityURL) {
                                UIApplication.shared.open(url)
                            }
                        },
                        onChatTap: { showStreakCoach = true }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Commitment Journey Progress Bar
                    CommitmentJourneyView(
                        currentDay: currentStreak,
                        commitmentDays: 90
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Daily Check-in
                    DailyCheckInCard(
                        onTap: { showCheckIn = true },
                        isCheckedInToday: homeStats?.hasCheckedInToday ?? false,
                        todayScore: todayCheckInScore
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Daily Lessons
                    DailyLessonsCard(userStreakDay: max(1, currentStreak), onTap: { showLessons = true })
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // Daily Verse
                    DailyVerseCard(
                        verse: DailyVerses.today.text,
                        reference: DailyVerses.today.reference
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Journal
                    JournalHomeCard(
                        totalEntries: journalEntries.count,
                        onTap: { showJournal = true }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Onboarding Checklist
                    ChecklistSection(onMyWhyTap: { showMyWhy = true })
                        .padding(.horizontal, 24)
                        .padding(.top, 28)

                    // Toolkit
                    ToolkitSection(
                        onMyWhyTap: { showMyWhy = true },
                        onJournalTap: { showJournal = true },
                        onDuasTap: { showDuas = true },
                        onBreathingTap: { showBreathing = true },
                        onGroundingTap: { showGrounding = true }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    // Progress Stats
                    YourProgressSection(
                        currentStreak: currentStreak,
                        checkInsThisWeek: homeStats?.checkinsThisWeek ?? 0
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    // Bottom spacing for action bar
                    Spacer(minLength: 140)
                }
            }

            // Fixed Bottom Action Bar
            VStack {
                Spacer()
                BottomActionBar(
                    onPanicTap: {
                        AnalyticsManager.shared.trackPanicButtonPressed()
                        showPanicView = true
                    },
                    onChatTap: { showStreakCoach = true },
                    onCheckInTap: { showCheckIn = true },
                    onLessonTap: { showLessons = true }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            // Milestone Celebration Overlay
            if showMilestoneCelebration, let milestone = celebrationMilestone {
                MilestoneCelebrationView(
                    milestone: milestone,
                    onDismiss: {
                        showMilestoneCelebration = false
                        celebrationMilestone = nil
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            loadHomeStats()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                loadHomeStats()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            loadHomeStats()
        }
        .onReceive(timer) { _ in
            updateTimerString()
        }
        .onChange(of: homeStats?.currentStreak) { _, _ in
            checkForNewMilestone()
        }
        .navigationDestination(isPresented: $showProgressPage) {
            ProgressPageView()
        }
        .fullScreenCover(isPresented: $showPanicView) {
            PanicView()
        }
        .onChange(of: showPanicView) { oldValue, newValue in
            if oldValue && !newValue {
                // PanicView was dismissed, reload data in case of relapse
                loadHomeStats()
            }
        }
        .fullScreenCover(isPresented: $showCheckIn) {
            CheckInFlowView()
        }
        .navigationDestination(isPresented: $showJournal) {
            JournalView()
        }
        .navigationDestination(isPresented: $showMyWhy) {
            MyWhyView()
        }
        .fullScreenCover(isPresented: $showDuas) {
            DuasView()
        }
        .fullScreenCover(isPresented: $showBreathing) {
            BreathingExerciseView()
        }
        .fullScreenCover(isPresented: $showGrounding) {
            GroundingView()
        }
        .fullScreenCover(isPresented: $showStreakCoach) {
            StreakCoachView()
        }
        .fullScreenCover(isPresented: $showProfile) {
            ProfileView()
        }
        .fullScreenCover(isPresented: $showLessons) {
            LessonsView()
        }
        .navigationBarHidden(true)
        // Handle navigation requests from StreakCoachView
        .onReceive(NotificationCenter.default.publisher(for: .showBreathing)) { _ in
            showBreathing = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .showJournal)) { _ in
            showJournal = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCheckIn)) { _ in
            showCheckIn = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .showPanic)) { _ in
            showPanicView = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .showDua)) { _ in
            showDuas = true
        }
        }
    }

    // MARK: - Data Loading

    private func loadHomeStats() {
        let dataManager = DataManager(modelContext: modelContext)

        // Ensure streak BEFORE getting stats (so stats reflect current state)
        if let streak = dataManager.ensureStreakIfCommitted() {
            streakStartDate = streak.startedAt
        } else {
            streakStartDate = nil  // Timer stays at 0 (no commitment yet)
        }

        homeStats = dataManager.getHomeStats()

        // Calculate today's check-in score (percentage of max 50, ratings are 1-10 each)
        if let todayCheckIn = dataManager.getTodaysCheckin() {
            let total = todayCheckIn.moodRating + todayCheckIn.energyRating +
                        todayCheckIn.confidenceRating + todayCheckIn.faithRating +
                        todayCheckIn.selfControlRating
            todayCheckInScore = min(Int((Double(total) / 50.0) * 100), 100)
        } else {
            todayCheckInScore = 0
        }

        updateTimerString()
        checkForNewMilestone()
    }

    private func updateTimerString() {
        guard let startDate = streakStartDate else {
            timerString = "0h 0m 0s"
            return
        }

        let elapsed = Date().timeIntervalSince(startDate)
        let totalSeconds = Int(elapsed)

        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        timerString = "\(hours)h \(minutes)m \(seconds)s"
    }

    // MARK: - Milestone Celebration Logic

    private func checkForNewMilestone() {
        guard homeStats != nil else { return }

        // Find the highest milestone the user has reached
        let reachedMilestones = milestoneDefinitions.filter { $0.day <= currentStreak }

        guard let latestReached = reachedMilestones.last else { return }

        // Check if this milestone has already been celebrated
        if latestReached.day > lastCelebratedMilestoneDay {
            // New milestone unlocked! Show celebration
            celebrationMilestone = CelebrationMilestone(
                day: latestReached.day,
                title: latestReached.title,
                islamicName: latestReached.islamicName,
                meaning: latestReached.meaning,
                verse: latestReached.verse,
                verseReference: latestReached.verseReference,
                badgeIcon: latestReached.icon,
                badgeColors: latestReached.colors
            )

            // Small delay for smoother UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showMilestoneCelebration = true
                }
                // Mark as celebrated in SwiftData
                let dataManager = DataManager(modelContext: modelContext)
                dataManager.celebrateMilestone(latestReached.day)

                // Send notification (for when app is in background)
                NotificationManager.shared.sendMilestoneNotification(
                    days: latestReached.day,
                    islamicName: latestReached.islamicName,
                    meaning: latestReached.meaning
                )
            }
        }
    }
}

#Preview {
    HomeView()
}
