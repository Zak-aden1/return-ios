//
//  ContentView.swift
//  ImanPath
//
//  Created by zak aden on 08/01/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    private var dataManager: DataManager {
        DataManager(modelContext: modelContext)
    }

    private var shouldShowOnboarding: Bool {
        guard let user = users.first else { return true }
        return !user.onboardingCompleted
    }

    private var shouldShowTutorial: Bool {
        guard let user = users.first else { return false }
        return user.onboardingCompleted && !user.hasSeenTutorial
    }

    var body: some View {
        if shouldShowOnboarding {
            OnboardingFlowView()
        } else if shouldShowTutorial {
            TutorialView(onComplete: {
                dataManager.completeTutorial()
            })
        } else {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
