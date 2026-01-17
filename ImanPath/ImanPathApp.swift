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
            RootView()
                .modelContainer(container)
        }
    }
}

// MARK: - Root View (Splash -> Content)

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen(onComplete: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSplash = false
                    }
                })
                .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}
