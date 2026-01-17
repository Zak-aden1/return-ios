//
//  CheckIn.swift
//  ImanPath
//
//  SwiftData model for daily check-ins
//

import Foundation
import SwiftData

@Model
final class CheckIn {
    var date: Date

    // Self-awareness ratings (1-5)
    var moodRating: Int
    var energyRating: Int
    var confidenceRating: Int
    var faithRating: Int
    var selfControlRating: Int

    // Reflections
    var progressReflection: String?
    var journeyReflection: String?
    var gratitude: String?

    // Outcome
    var stayedClean: Bool

    var createdAt: Date = Date()

    init(
        date: Date = Date(),
        moodRating: Int = 0,
        energyRating: Int = 0,
        confidenceRating: Int = 0,
        faithRating: Int = 0,
        selfControlRating: Int = 0,
        stayedClean: Bool = true
    ) {
        self.date = date
        self.moodRating = moodRating
        self.energyRating = energyRating
        self.confidenceRating = confidenceRating
        self.faithRating = faithRating
        self.selfControlRating = selfControlRating
        self.stayedClean = stayedClean
    }

    // Computed average for analytics
    var averageRating: Double {
        let total = moodRating + energyRating + confidenceRating + faithRating + selfControlRating
        return Double(total) / 5.0
    }
}
