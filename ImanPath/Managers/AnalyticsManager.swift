//
//  AnalyticsManager.swift
//  ImanPath
//
//  Analytics tracking via Mixpanel
//

import Foundation
import Mixpanel
import UIKit

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {
        // Token from Secrets.xcconfig (hardcoded for now, can use Info.plist later)
        Mixpanel.initialize(token: "59acc25de88e8289e0e89c3ece14cc4b", trackAutomaticEvents: false)

        // Use IDFV for consistent user identification across sessions
        // This persists across reinstalls as long as at least one app from the vendor is installed
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            Mixpanel.mainInstance().identify(distinctId: idfv)
        }
    }

    // MARK: - Onboarding

    func trackOnboardingStarted() {
        Mixpanel.mainInstance().track(event: "onboarding_started")
    }

    func trackQuizCompleted(recoveryScore: Int) {
        Mixpanel.mainInstance().track(
            event: "onboarding_quiz_completed",
            properties: ["recovery_score": recoveryScore]
        )
    }

    func trackCommitmentSigned(daysUntilTarget: Int) {
        Mixpanel.mainInstance().track(
            event: "onboarding_commitment_signed",
            properties: ["days_until_target": daysUntilTarget]
        )
    }

    func trackPaywallViewed(offerType: String = "onboarding") {
        Mixpanel.mainInstance().track(
            event: "onboarding_paywall_viewed",
            properties: ["offer_type": offerType]
        )
    }

    func trackSubscriptionStarted(plan: String) {
        Mixpanel.mainInstance().track(
            event: "subscription_started",
            properties: ["plan": plan]
        )
    }

    func trackOnboardingCompleted() {
        Mixpanel.mainInstance().track(event: "onboarding_completed")
    }

    // MARK: - Core Actions

    func trackCheckinCompleted(stayedClean: Bool, urgeLevel: Int?, imanLevel: Int?) {
        var props: [String: MixpanelType] = ["stayed_clean": stayedClean]
        if let urge = urgeLevel { props["urge_level"] = urge }
        if let iman = imanLevel { props["iman_level"] = iman }

        Mixpanel.mainInstance().track(event: "checkin_completed", properties: props)
    }

    func trackRelapse(previousStreak: Int) {
        Mixpanel.mainInstance().track(
            event: "relapse",
            properties: ["previous_streak": previousStreak]
        )
    }

    func trackStreakMilestone(days: Int) {
        Mixpanel.mainInstance().track(
            event: "streak_milestone",
            properties: ["days": days]
        )
    }

    func trackPanicButtonPressed() {
        Mixpanel.mainInstance().track(event: "panic_button_pressed")
    }

    func trackLessonCompleted(lessonDay: Int) {
        Mixpanel.mainInstance().track(
            event: "lesson_completed",
            properties: ["lesson_day": lessonDay]
        )
    }

    func trackJournalEntryCreated() {
        Mixpanel.mainInstance().track(event: "journal_entry_created")
    }

    func trackAICoachUsed() {
        Mixpanel.mainInstance().track(event: "ai_coach_used")
    }

    // MARK: - Win-back Paywall (Transaction Abandon)

    func trackWinbackPaywallViewed() {
        Mixpanel.mainInstance().track(event: "winback_paywall_viewed")
    }

    func trackWinbackPurchaseCompleted() {
        Mixpanel.mainInstance().track(
            event: "winback_purchase_completed",
            properties: ["product_id": "yearly_40", "source": "transaction_abandon"]
        )
    }

    // MARK: - Shortcut Paywall (Quick Action)

    func trackShortcutPaywallViewed() {
        Mixpanel.mainInstance().track(event: "shortcut_paywall_viewed")
    }

    func trackShortcutPurchaseCompleted() {
        Mixpanel.mainInstance().track(
            event: "shortcut_purchase_completed",
            properties: ["product_id": "trail_yearly_40", "source": "shortcut_action"]
        )
    }

    // MARK: - App Lifecycle

    func trackAppOpened() {
        Mixpanel.mainInstance().track(event: "app_opened")
        Mixpanel.mainInstance().flush() // Force send immediately
    }

    // MARK: - Errors

    func trackError(_ errorType: String, context: String? = nil) {
        var props: [String: MixpanelType] = ["error_type": errorType]
        if let context = context {
            props["context"] = context
        }
        Mixpanel.mainInstance().track(event: "error", properties: props)
    }

    // MARK: - Flush

    func flush() {
        Mixpanel.mainInstance().flush()
    }
}
