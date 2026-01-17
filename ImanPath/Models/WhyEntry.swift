//
//  WhyEntry.swift
//  ImanPath
//
//  SwiftData model for "My Why" entries
//

import Foundation
import SwiftData

@Model
final class WhyEntry {
    var category: String         // Stored as rawValue: "For Allah", "For Myself", etc.
    var content: String
    var createdDate: Date = Date()

    init(category: String, content: String) {
        self.category = category
        self.content = content
    }
}
