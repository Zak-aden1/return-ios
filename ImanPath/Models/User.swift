//
//  User.swift
//  ImanPath
//
//  SwiftData model for user profile and settings
//

import Foundation
import SwiftData

@Model
final class User {
    // Profile
    var userName: String?

    // Commitment
    var commitmentDate: Date?        // Target date (e.g., 90 days from start)
    var commitmentSignedAt: Date?    // When they signed the niyyah

    // Onboarding
    var onboardingCompleted: Bool = false
    var hasSeenTutorial: Bool = false

    // Settings
    var notificationsEnabled: Bool = true
    var checkinReminderTime: Date?
    var coachEnabled: Bool = true

    // Stats (denormalized for fast access)
    var currentStreakDays: Int = 0
    var currentStreakStartDate: Date?
    var longestStreak: Int = 0
    var totalCleanDays: Int = 0
    var lastCheckinDate: Date?

    // Milestone tracking
    var lastCelebratedMilestone: Int = 0

    // Timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init() {}
}
