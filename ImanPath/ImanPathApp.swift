//
//  ReturnApp.swift
//  Return
//
//  Created by zak aden on 08/01/2026.
//

import SwiftUI
import SwiftData

@main
struct ReturnApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            User.self,
            Streak.self,
            CheckIn.self,
            JournalEntry.self,
            WhyEntry.self,
            ChatMessage.self,
            ChatConversation.self,
            LessonProgress.self
        ])

        let config = ModelConfiguration(
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
