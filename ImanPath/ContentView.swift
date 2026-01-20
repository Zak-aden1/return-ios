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
    @Environment(\.scenePhase) private var scenePhase
    @Query private var users: [User]
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // Flash guard: hasExistingUser is synchronous, users (@Query) is async
    // Prevents brief flash of OnboardingFlowView for returning users
    @AppStorage("hasExistingUser") private var hasExistingUser: Bool = false
    @State private var hasWaitedForUsers: Bool = false

    // Track prepaywall -> paywall flow for returning non-subscribers
    @State private var showPaywallScreen: Bool = false
    @State private var showWinBackPaywall: Bool = false

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

    private var isOnboardingComplete: Bool {
        users.first?.onboardingCompleted ?? false
    }

    var body: some View {
        Group {
            if hasExistingUser && users.isEmpty {
                // Flash guard: returning user but SwiftData not loaded yet
                // Prevents brief flash of OnboardingFlowView while @Query loads
                if hasWaitedForUsers {
                    OnboardingFlowView()
                } else {
                    Color(hex: "0A1628").ignoresSafeArea()
                }
            } else if !isOnboardingComplete {
                // First time user or incomplete onboarding - show onboarding flow
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
                        },
                        onDismiss: {
                            // Transaction abandon - show win-back paywall
                            showWinBackPaywall = true
                        }
                    )
                    .fullScreenCover(isPresented: $showWinBackPaywall) {
                        WinBackPaywallView(
                            source: .transactionAbandon,
                            onPurchase: {
                                // Successful purchase - subscription status auto-updates
                                showWinBackPaywall = false
                            },
                            onDismiss: {
                                // Dismissed win-back - go back to prepaywall
                                showWinBackPaywall = false
                                showPaywallScreen = false
                            }
                        )
                    }
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
        .animation(.easeInOut(duration: 0.3), value: isOnboardingComplete)
        .task {
            if !users.isEmpty && !hasExistingUser {
                hasExistingUser = true
            }
            if !hasWaitedForUsers {
                try? await Task.sleep(nanoseconds: 600_000_000)
                hasWaitedForUsers = true
            }
        }
        .onChange(of: users.count) { _, newCount in
            if newCount > 0 && !hasExistingUser {
                hasExistingUser = true
            }
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            // Reset paywall flow state when subscription status changes
            if isSubscribed {
                showPaywallScreen = false
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Refresh subscription status when app returns to foreground
            // Catches expired subscriptions that occurred while backgrounded
            if newPhase == .active {
                Task {
                    await subscriptionManager.updateSubscriptionStatus()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
