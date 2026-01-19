//
//  DataManager.swift
//  ImanPath
//
//  Central manager for all SwiftData operations
//

import Foundation
import SwiftData

@Observable
class DataManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            print("❌ SwiftData save failed: \(error)")
            #endif
        }
    }

    // MARK: - User

    func getOrCreateUser() -> User {
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            return user
        }
        let user = User()
        modelContext.insert(user)
        save()
        return user
    }

    func updateUserName(_ name: String) {
        let user = getOrCreateUser()
        user.userName = name
        user.updatedAt = Date()
        save()
    }

    func completeOnboarding() {
        let user = getOrCreateUser()
        user.onboardingCompleted = true
        user.updatedAt = Date()
        save()
    }

    func completeTutorial() {
        let user = getOrCreateUser()
        user.hasSeenTutorial = true
        user.updatedAt = Date()
        save()
    }

    func signCommitment(targetDate: Date) {
        let user = getOrCreateUser()
        user.commitmentDate = targetDate
        user.commitmentSignedAt = Date()
        user.updatedAt = Date()
        save()

        // Start first streak
        _ = startNewStreak()
    }

    // MARK: - Streaks

    func getCurrentStreak() -> Streak? {
        var descriptor = FetchDescriptor<Streak>(
            predicate: #Predicate { $0.endedAt == nil }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    /// Returns active streak if commitment exists, creates one if missing.
    /// Returns nil if user hasn't signed commitment yet.
    func ensureStreakIfCommitted() -> Streak? {
        let user = getOrCreateUser()

        // No commitment = no streak allowed
        guard user.commitmentSignedAt != nil else {
            return nil
        }

        // Active streak exists
        if let existing = getCurrentStreak() {
            // Sync user's cached start date if out of sync
            if user.currentStreakStartDate != existing.startedAt {
                user.currentStreakStartDate = existing.startedAt
                user.updatedAt = Date()
                save()
            }
            return existing
        }

        // Commitment exists but streak missing - recover
        // First streak uses commitmentSignedAt, subsequent use Date()
        let startDate = user.currentStreakStartDate ?? user.commitmentSignedAt ?? Date()
        let streak = Streak(startedAt: startDate)
        modelContext.insert(streak)
        user.currentStreakStartDate = startDate
        user.updatedAt = Date()
        save()

        return streak
    }

    func startNewStreak() -> Streak {
        let streak = Streak(startedAt: Date())
        modelContext.insert(streak)

        let user = getOrCreateUser()
        user.currentStreakDays = 0
        user.currentStreakStartDate = Date()
        user.updatedAt = Date()

        save()
        return streak
    }

    func resetStreak(reason: String) {
        guard let currentStreak = getCurrentStreak() else { return }

        // End current streak
        currentStreak.endedAt = Date()
        currentStreak.endReason = reason

        // Update user stats
        let user = getOrCreateUser()
        if currentStreak.days > user.longestStreak {
            user.longestStreak = currentStreak.days
        }
        user.currentStreakDays = 0
        user.currentStreakStartDate = nil
        user.updatedAt = Date()

        save()

        // Handle notifications for relapse (cancel invalid ones, schedule recovery reminder)
        NotificationManager.shared.handleRelapse()

        // Start new streak
        _ = startNewStreak()
    }

    func incrementStreak() {
        guard let streak = getCurrentStreak() else { return }
        streak.days += 1

        let user = getOrCreateUser()
        user.currentStreakDays = streak.days
        user.totalCleanDays += 1

        if streak.days > user.longestStreak {
            user.longestStreak = streak.days
        }
        user.updatedAt = Date()

        save()
    }

    /// Calculate current streak days based on streak start date
    func calculateCurrentStreakDays() -> Int {
        guard let streak = getCurrentStreak() else { return 0 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: streak.startedAt, to: Date()).day ?? 0
        return max(0, days)
    }

    // MARK: - Milestones

    func celebrateMilestone(_ day: Int) {
        let user = getOrCreateUser()
        user.lastCelebratedMilestone = day
        user.updatedAt = Date()
        save()
    }

    func hasNewMilestone(milestones: [Int]) -> Int? {
        let user = getOrCreateUser()
        let currentDays = user.currentStreakDays

        // Find highest milestone reached that hasn't been celebrated
        let uncelebrated = milestones.filter { $0 <= currentDays && $0 > user.lastCelebratedMilestone }
        return uncelebrated.max()
    }

    // MARK: - Check-ins

    func getTodaysCheckin() -> CheckIn? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func hasCheckedInToday() -> Bool {
        getTodaysCheckin() != nil
    }

    func submitCheckin(
        moodRating: Int,
        energyRating: Int,
        confidenceRating: Int,
        faithRating: Int,
        selfControlRating: Int,
        progressReflection: String?,
        journeyReflection: String?,
        gratitude: String?,
        stayedClean: Bool
    ) -> CheckIn {
        // Check if updating existing check-in or creating new
        let existingCheckin = getTodaysCheckin()
        let isUpdate = existingCheckin != nil

        let checkin: CheckIn
        if let existing = existingCheckin {
            // Update existing check-in
            existing.moodRating = moodRating
            existing.energyRating = energyRating
            existing.confidenceRating = confidenceRating
            existing.faithRating = faithRating
            existing.selfControlRating = selfControlRating
            existing.progressReflection = progressReflection
            existing.journeyReflection = journeyReflection
            existing.gratitude = gratitude
            existing.stayedClean = stayedClean
            checkin = existing
        } else {
            // Create new check-in
            checkin = CheckIn(
                date: Date(),
                moodRating: moodRating,
                energyRating: energyRating,
                confidenceRating: confidenceRating,
                faithRating: faithRating,
                selfControlRating: selfControlRating,
                stayedClean: stayedClean
            )
            checkin.progressReflection = progressReflection
            checkin.journeyReflection = journeyReflection
            checkin.gratitude = gratitude
            modelContext.insert(checkin)
        }

        let user = getOrCreateUser()
        user.lastCheckinDate = Date()
        user.updatedAt = Date()

        // Only update streak on first check-in of the day
        if !isUpdate {
            if stayedClean {
                incrementStreak()
            } else {
                resetStreak(reason: "relapse")
            }
        }

        save()
        return checkin
    }

    func getCheckinHistory(limit: Int = 30) -> [CheckIn] {
        var descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getCheckinsThisWeek() -> Int {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }

        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { $0.date >= weekAgo }
        )
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }

    // MARK: - Journal

    func createJournalEntry(content: String, mood: Int? = nil) -> JournalEntry {
        let entry = JournalEntry(content: content, mood: mood)
        modelContext.insert(entry)
        save()
        return entry
    }

    func getJournalEntries(limit: Int = 50) -> [JournalEntry] {
        var descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getJournalEntriesThisWeek() -> Int {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }

        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { $0.date >= weekAgo }
        )
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }

    func searchJournalEntries(query: String) -> [JournalEntry] {
        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { $0.content.localizedStandardContains(query) },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func updateJournalEntry(_ entry: JournalEntry, content: String, mood: Int?) {
        entry.content = content
        entry.mood = mood
        entry.updatedAt = Date()
        save()
    }

    func deleteJournalEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        save()
    }

    // MARK: - My Why

    func createWhyEntry(category: String, content: String) -> WhyEntry {
        let entry = WhyEntry(category: category, content: content)
        modelContext.insert(entry)
        save()
        return entry
    }

    func getWhyEntries() -> [WhyEntry] {
        let descriptor = FetchDescriptor<WhyEntry>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func updateWhyEntry(_ entry: WhyEntry, category: String, content: String) {
        entry.category = category
        entry.content = content
        save()
    }

    func deleteWhyEntry(_ entry: WhyEntry) {
        modelContext.delete(entry)
        save()
    }

    // MARK: - Stats for Home View

    func getHomeStats() -> HomeStats {
        let user = getOrCreateUser()
        let currentDays = calculateCurrentStreakDays()

        // Update cached value if different
        if user.currentStreakDays != currentDays {
            user.currentStreakDays = currentDays
            save()
        }

        return HomeStats(
            currentStreak: currentDays,
            longestStreak: user.longestStreak,
            totalCleanDays: user.totalCleanDays,
            checkinsThisWeek: getCheckinsThisWeek(),
            journalEntriesThisWeek: getJournalEntriesThisWeek(),
            hasCheckedInToday: hasCheckedInToday(),
            commitmentDate: user.commitmentDate,
            userName: user.userName,
            lastCelebratedMilestone: user.lastCelebratedMilestone
        )
    }

    // MARK: - Streak Coach Chat

    func getOrCreateCurrentConversation() -> ChatConversation {
        // Get the most recent conversation, or create a new one
        var descriptor = FetchDescriptor<ChatConversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        if let conversation = try? modelContext.fetch(descriptor).first {
            return conversation
        }

        // Create new conversation
        let conversation = ChatConversation()
        modelContext.insert(conversation)
        save()
        return conversation
    }

    func createNewConversation() -> ChatConversation {
        let conversation = ChatConversation()
        modelContext.insert(conversation)
        save()
        return conversation
    }

    func addMessageToConversation(
        _ conversation: ChatConversation,
        sender: MessageSender,
        content: String,
        citations: [String] = [],
        suggestedAction: String? = nil
    ) -> ChatMessage {
        let message = ChatMessage(sender: sender, content: content)
        message.citations = citations
        message.suggestedAction = suggestedAction
        message.conversation = conversation
        conversation.messages.append(message)
        conversation.updatedAt = Date()

        modelContext.insert(message)
        save()
        return message
    }

    func markMessageAsError(_ message: ChatMessage, errorMessage: String) {
        message.isError = true
        message.errorMessage = errorMessage
        save()
    }

    func updateMessageContent(_ message: ChatMessage, content: String) {
        message.content = content
        // Don't save on every chunk - let SwiftData batch updates
    }

    func deleteMessage(_ message: ChatMessage) {
        modelContext.delete(message)
        save()
    }

    func clearConversation(_ conversation: ChatConversation) {
        for message in conversation.messages {
            modelContext.delete(message)
        }
        conversation.messages = []
        conversation.updatedAt = Date()
        save()
    }

    func deleteConversation(_ conversation: ChatConversation) {
        modelContext.delete(conversation)
        save()
    }

    func clearAllChatHistory() {
        let descriptor = FetchDescriptor<ChatConversation>()
        if let conversations = try? modelContext.fetch(descriptor) {
            for conversation in conversations {
                modelContext.delete(conversation)
            }
        }
        save()
    }
}

// MARK: - Helper Types

struct HomeStats {
    let currentStreak: Int
    let longestStreak: Int
    let totalCleanDays: Int
    let checkinsThisWeek: Int
    let journalEntriesThisWeek: Int
    let hasCheckedInToday: Bool
    let commitmentDate: Date?
    let userName: String?
    let lastCelebratedMilestone: Int
}
