//
//  Streak.swift
//  ImanPath
//
//  SwiftData model for streak history
//

import Foundation
import SwiftData

@Model
final class Streak {
    var startedAt: Date
    var endedAt: Date?           // nil if current/active streak
    var days: Int
    var endReason: String?       // "relapse", "manual_reset", nil if ongoing

    var createdAt: Date = Date()

    var isActive: Bool {
        endedAt == nil
    }

    init(startedAt: Date = Date()) {
        self.startedAt = startedAt
        self.days = 0
    }
}
