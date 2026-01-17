//
//  ContentView.swift
//  Return
//
//  Main app coordinator - handles onboarding, paywall, and home navigation
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // Track if user has completed onboarding up to prepaywall
    @AppStorage("hasSeenPrepaywall") private var hasSeenPrepaywall: Bool = false

    // Track prepaywall -> paywall flow for returning non-subscribers
    @State private var showPaywallScreen: Bool = false

    private var dataManager: DataManager {
        DataManager(modelContext: modelContext)
    }

    private var shouldShowTutorial: Bool {
        guard let user = users.first else { return false }
        return !user.hasSeenTutorial
    }

    private var userName: String {
        users.first?.userName ?? ""
    }

    var body: some View {
        Group {
            if !hasSeenPrepaywall {
                // First time user - show full onboarding flow
                // OnboardingFlowView will set hasSeenPrepaywall when reaching step 31
                OnboardingFlowView()

            } else if !subscriptionManager.isSubscribed {
                // Returning non-subscriber - show prepaywall -> paywall
                if !showPaywallScreen {
                    PrePaywallScreen(
                        userName: userName,
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showPaywallScreen = true
                            }
                        }
                    )
                } else {
                    PaywallScreen(
                        onSubscribe: {
                            // Subscription successful
                            // isSubscribed will update automatically via SubscriptionManager
                        },
                        onRestorePurchases: {
                            // Restore successful
                            // isSubscribed will update automatically via SubscriptionManager
                        }
                    )
                }

            } else if shouldShowTutorial {
                // Subscribed but hasn't seen tutorial
                TutorialView(onComplete: {
                    dataManager.completeTutorial()
                })

            } else {
                // Subscribed and tutorial complete - show home
                HomeView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: subscriptionManager.isSubscribed)
        .animation(.easeInOut(duration: 0.3), value: hasSeenPrepaywall)
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            // Reset paywall flow state when subscription status changes
            if isSubscribed {
                showPaywallScreen = false
            }
        }
    }
}

#Preview {
    ContentView()
}
