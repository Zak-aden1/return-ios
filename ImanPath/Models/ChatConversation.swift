//
//  ChatConversation.swift
//  ImanPath
//
//  SwiftData model for Streak Coach conversations
//

import Foundation
import SwiftData

@Model
final class ChatConversation {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // Relationship - cascade delete messages when conversation deleted
    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.conversation)
    var messages: [ChatMessage] = []

    init() {}

    var sortedMessages: [ChatMessage] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }

    var lastMessage: ChatMessage? {
        sortedMessages.last
    }

    var messageCount: Int {
        messages.count
    }
}
