//
//  ReturnApp.swift
//  Return
//
//  Created by zak aden on 08/01/2026.
//

import SwiftUI
import SwiftData
import UIKit

// MARK: - Quick Action Types

enum QuickAction: String {
    case sendFeedback = "com.returntoiman.sendFeedback"
    case tryForFree = "com.returntoiman.tryForFree"
}

// MARK: - Quick Action Manager (Shared State)

class QuickActionManager: ObservableObject {
    static let shared = QuickActionManager()
    @Published var pendingAction: QuickAction?
    @Published var showWinBackPaywall: Bool = false
    private init() {}
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupQuickActions(for: application)
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Handle quick action if app was launched from one (COLD LAUNCH)
        if let shortcutItem = options.shortcutItem {
            handleQuickAction(shortcutItem)
        }

        let configuration = UISceneConfiguration(
            name: connectingSceneSession.configuration.name,
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    private func setupQuickActions(for application: UIApplication) {
        updateQuickActions(for: application, isPremium: SubscriptionManager.shared.isSubscribed)
    }

    func updateQuickActions(for application: UIApplication, isPremium: Bool) {
        var items: [UIApplicationShortcutItem] = []

        // Feedback item - always show
        let feedbackItem = UIApplicationShortcutItem(
            type: QuickAction.sendFeedback.rawValue,
            localizedTitle: "Deleting? Tell us why.",
            localizedSubtitle: "Send feedback before you go",
            icon: UIApplicationShortcutIcon(systemImageName: "square.and.pencil")
        )
        items.append(feedbackItem)

        // Only show free trial for non-premium users
        if !isPremium {
            let tryFreeItem = UIApplicationShortcutItem(
                type: QuickAction.tryForFree.rawValue,
                localizedTitle: "🚨 TRY FOR FREE",
                localizedSubtitle: "Get unlimited access to Return",
                icon: UIApplicationShortcutIcon(systemImageName: "gift")
            )
            items.append(tryFreeItem)
        }

        application.shortcutItems = items
    }

    /// Call this to refresh quick actions (e.g., after subscription change)
    static func refreshQuickActions() {
        let isPremium = SubscriptionManager.shared.isSubscribed
        UIApplication.shared.shortcutItems = {
            var items: [UIApplicationShortcutItem] = []

            items.append(UIApplicationShortcutItem(
                type: QuickAction.sendFeedback.rawValue,
                localizedTitle: "Deleting? Tell us why.",
                localizedSubtitle: "Send feedback before you go",
                icon: UIApplicationShortcutIcon(systemImageName: "square.and.pencil")
            ))

            if !isPremium {
                items.append(UIApplicationShortcutItem(
                    type: QuickAction.tryForFree.rawValue,
                    localizedTitle: "🚨 TRY FOR FREE",
                    localizedSubtitle: "Get unlimited access to Return",
                    icon: UIApplicationShortcutIcon(systemImageName: "gift")
                ))
            }

            return items
        }()
    }

    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) {
        guard let action = QuickAction(rawValue: shortcutItem.type) else { return }
        QuickActionManager.shared.pendingAction = action
    }
}

// MARK: - Scene Delegate (Warm Launch Handling)

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        QuickActionManager.shared.pendingAction = action
        completionHandler(true)
    }
}

// MARK: - Main App

@main
struct ReturnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var quickActionManager = QuickActionManager.shared
    @Environment(\.scenePhase) private var scenePhase

    let container: ModelContainer

    // Feedback form URL
    private let feedbackURL = URL(string: "https://docs.google.com/forms/d/12qzOjZndxTQKQSJI2nnxQkZ-I-jYntyifyBZrdv3b7w/viewform")!

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

        // Initialize Mixpanel Analytics
        _ = AnalyticsManager.shared
        AnalyticsManager.shared.trackAppOpened()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .environmentObject(quickActionManager)
                .onReceive(quickActionManager.$pendingAction) { action in
                    guard let action = action else { return }
                    handleQuickAction(action)
                    quickActionManager.pendingAction = nil
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Refresh quick actions based on premium status
                AppDelegate.refreshQuickActions()
            }
        }
    }

    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .sendFeedback:
            if let url = URL(string: "https://docs.google.com/forms/d/12qzOjZndxTQKQSJI2nnxQkZ-I-jYntyifyBZrdv3b7w/viewform") {
                UIApplication.shared.open(url)
            }

        case .tryForFree:
            // Only show if not already subscribed
            if !SubscriptionManager.shared.isSubscribed {
                quickActionManager.showWinBackPaywall = true
            }
        }
    }
}

// MARK: - Root View (Splash -> Content)

struct RootView: View {
    @EnvironmentObject var quickActionManager: QuickActionManager
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
        .fullScreenCover(isPresented: $quickActionManager.showWinBackPaywall) {
            WinBackPaywallView(
                onPurchase: {
                    quickActionManager.showWinBackPaywall = false
                    // Refresh quick actions to hide "Try for Free" now that user is subscribed
                    AppDelegate.refreshQuickActions()
                },
                onDismiss: {
                    quickActionManager.showWinBackPaywall = false
                }
            )
        }
    }
}
