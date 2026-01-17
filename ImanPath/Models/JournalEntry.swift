//
//  JournalEntry.swift
//  ImanPath
//
//  SwiftData model for journal entries
//

import Foundation
import SwiftData

@Model
final class JournalEntry {
    var date: Date               // When the entry was created
    var content: String
    var mood: Int?               // 1-10, optional

    var updatedAt: Date = Date()

    init(date: Date = Date(), content: String, mood: Int? = nil) {
        self.date = date
        self.content = content
        self.mood = mood
    }
}
