//
//  CoachRateLimiter.swift
//  ImanPath
//
//  Local rate limiting for Streak Coach (MVP)
//  Production will use server-side limiting via Supabase
//

import Foundation

struct CoachUsage: Codable {
    var messagesCount: Int
    var resetDate: Date
}

/// Manages local rate limiting for Streak Coach messages
/// MVP implementation using UserDefaults - 30 messages per day
class CoachRateLimiter {
    private let userDefaults = UserDefaults.standard
    private let usageKey = "coach_usage"
    private let dailyLimit = 30

    // MARK: - Public API

    /// Check if user can send another message
    func canSendMessage() -> Bool {
        let usage = getUsage()
        return usage.messagesCount < dailyLimit
    }

    /// Record a sent message
    func recordMessage() {
        var usage = getUsage()
        usage.messagesCount += 1
        saveUsage(usage)
    }

    /// Get current usage stats
    func getUsage() -> CoachUsage {
        guard let data = userDefaults.data(forKey: usageKey),
              let usage = try? JSONDecoder().decode(CoachUsage.self, from: data) else {
            // No existing usage - create fresh
            let newUsage = CoachUsage(messagesCount: 0, resetDate: Date())
            saveUsage(newUsage)
            return newUsage
        }

        // Check if we need to reset (new day)
        if !Calendar.current.isDateInToday(usage.resetDate) {
            let resetUsage = CoachUsage(messagesCount: 0, resetDate: Date())
            saveUsage(resetUsage)
            return resetUsage
        }

        return usage
    }

    /// Get remaining messages for today
    func remainingMessages() -> Int {
        let usage = getUsage()
        return max(0, dailyLimit - usage.messagesCount)
    }

    /// Check if near the daily limit (for showing warning)
    func isNearLimit() -> Bool {
        let remaining = remainingMessages()
        return remaining <= 5 && remaining > 0
    }

    /// Check if at limit
    func isAtLimit() -> Bool {
        return remainingMessages() == 0
    }

    // MARK: - Private

    private func saveUsage(_ usage: CoachUsage) {
        if let data = try? JSONEncoder().encode(usage) {
            userDefaults.set(data, forKey: usageKey)
        }
    }

    // MARK: - Debug/Testing

    #if DEBUG
    func resetForTesting() {
        userDefaults.removeObject(forKey: usageKey)
    }

    func setUsageForTesting(count: Int) {
        let usage = CoachUsage(messagesCount: count, resetDate: Date())
        saveUsage(usage)
    }
    #endif
}
