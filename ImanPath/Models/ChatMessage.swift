//
//  ChatMessage.swift
//  ImanPath
//
//  SwiftData model for Streak Coach chat messages
//

import Foundation
import SwiftData

enum MessageSender: String, Codable {
    case user
    case assistant
}

@Model
final class ChatMessage {
    var id: UUID = UUID()
    var senderRaw: String = MessageSender.user.rawValue
    var content: String
    var timestamp: Date = Date()

    // Relationship to conversation
    var conversation: ChatConversation?

    // Structured citations stored as JSON string (e.g., ["journal:abc123", "checkin:2026-01-10"])
    var citationsData: String = "[]"

    var citations: [String] {
        get {
            guard let data = citationsData.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                citationsData = string
            }
        }
    }

    // Suggested action from AI (breathing, journal, checkin, panic, dua, none)
    var suggestedAction: String?

    // Error state for retry functionality
    var isError: Bool = false
    var errorMessage: String?

    var sender: MessageSender {
        get { MessageSender(rawValue: senderRaw) ?? .user }
        set { senderRaw = newValue.rawValue }
    }

    init(sender: MessageSender, content: String) {
        self.senderRaw = sender.rawValue
        self.content = content
    }
}
