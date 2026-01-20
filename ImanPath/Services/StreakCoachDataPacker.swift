//
//  StreakCoachDataPacker.swift
//  ImanPath
//
//  Builds the data pack for Streak Coach with citation IDs
//

import Foundation
import SwiftData

/// Maps citation IDs to their corresponding data entries
struct CitationMap {
    var journals: [String: JournalEntry] = [:]
    var checkIns: [String: CheckIn] = [:]
    var whyEntries: [String: WhyEntry] = [:]
}

/// Builds structured data pack for the Streak Coach AI
class StreakCoachDataPacker {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Builds the data pack and returns both the text and the citation map
    func buildDataPack() -> (text: String, citationMap: CitationMap) {
        let dataManager = DataManager(modelContext: modelContext)
        var citationMap = CitationMap()
        var lines: [String] = []

        // === STREAK INFO ===
        let stats = dataManager.getHomeStats()
        let streak = dataManager.getCurrentStreak()

        lines.append("=== STREAK INFO ===")
        lines.append("Current: Day \(stats.currentStreak)\(streak != nil ? " (started: \(formatDate(streak!.startedAt)))" : "")")
        lines.append("Longest: \(stats.longestStreak) days")
        lines.append("Total clean days: \(stats.totalCleanDays)")

        if let nextMilestone = getNextMilestone(currentDay: stats.currentStreak) {
            let daysUntil = nextMilestone.day - stats.currentStreak
            lines.append("Next milestone: Day \(nextMilestone.day) \"\(nextMilestone.islamicName)\" (\(daysUntil) day\(daysUntil == 1 ? "" : "s") away)")
        }

        if let commitmentDate = stats.commitmentDate {
            let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: commitmentDate).day ?? 0
            if daysRemaining > 0 {
                lines.append("Commitment goal: \(daysRemaining) days remaining")
            }
        }
        lines.append("")

        // === CHECK-INS ===
        lines.append("=== CHECK-INS [cite as checkin:YYYY-MM-DD] ===")
        let checkIns = dataManager.getCheckinHistory(limit: 7)

        if checkIns.isEmpty {
            lines.append("No check-ins recorded yet.")
        } else {
            for checkIn in checkIns {
                let dateStr = formatDateForId(checkIn.date)
                let citationId = "checkin:\(dateStr)"
                citationMap.checkIns[citationId] = checkIn

                var reflectionText = "No reflection"
                if let reflection = checkIn.progressReflection, !reflection.isEmpty {
                    reflectionText = "\"\(String(reflection.prefix(100)))\""
                } else if let journey = checkIn.journeyReflection, !journey.isEmpty {
                    reflectionText = "\"\(String(journey.prefix(100)))\""
                }

                lines.append("[\(citationId)] mood:\(checkIn.moodRating) energy:\(checkIn.energyRating) confidence:\(checkIn.confidenceRating) faith:\(checkIn.faithRating) control:\(checkIn.selfControlRating) | \(reflectionText)")
            }
        }
        lines.append("")

        // === JOURNALS ===
        lines.append("=== JOURNALS [cite as journal:DATE] ===")
        let journals = dataManager.getJournalEntries(limit: 5)

        if journals.isEmpty {
            lines.append("No journal entries yet.")
        } else {
            for (index, journal) in journals.enumerated() {
                // Use date-based ID for journals
                let dateId = formatDateForId(journal.date)
                let citationId = "journal:\(dateId)-\(index)"
                citationMap.journals[citationId] = journal

                let dateLabel = formatDateLabel(journal.date)
                let truncatedContent = String(journal.content.prefix(200))
                lines.append("[\(citationId)] \(dateLabel): \"\(truncatedContent)...\"")
            }
        }
        lines.append("")

        // === WHY ENTRIES ===
        lines.append("=== WHY ENTRIES [cite as why:INDEX] ===")
        let whyEntries = dataManager.getWhyEntries()

        if whyEntries.isEmpty {
            lines.append("No 'Why' entries recorded yet.")
        } else {
            for (index, why) in whyEntries.enumerated() {
                // Use index-based ID for why entries
                let citationId = "why:\(index)"
                citationMap.whyEntries[citationId] = why
                lines.append("[\(citationId)] \(why.category): \"\(why.content)\"")
            }
        }
        lines.append("")

        // === CONTEXT ===
        lines.append("=== CONTEXT ===")
        lines.append("Local time: \(formatTime(Date())) (\(getTimeOfDay()))")

        let rateLimiter = CoachRateLimiter()
        lines.append("Messages today: \(rateLimiter.getUsage().messagesCount)/30")

        return (lines.joined(separator: "\n"), citationMap)
    }

    // MARK: - Helper Methods

    private func getNextMilestone(currentDay: Int) -> MilestoneDefinition? {
        MilestoneCatalog.next(after: currentDay)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func formatDateForId(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func getTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default: return "night"
        }
    }
}
