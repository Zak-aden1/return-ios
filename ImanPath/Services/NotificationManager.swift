//
//  NotificationManager.swift
//  ImanPath
//
//  Handles local push notifications for reminders and celebrations
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false
    @Published var checkInReminderEnabled: Bool = false
    @Published var lessonReminderEnabled: Bool = false
    @Published var milestoneAlertsEnabled: Bool = true

    // Default times
    @Published var checkInTime: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    @Published var lessonTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()

    // Notification identifiers
    private let checkInIdentifier = "daily-checkin-reminder"
    private let lessonIdentifier = "daily-lesson-reminder"
    private let firstLessonIdentifier = "first-lesson-reminder"
    private let relapseRecoveryIdentifier = "relapse-recovery-reminder"
    private let milestoneIdentifierPrefix = "milestone-"

    private init() {
        loadSettings()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.scheduleAllEnabledNotifications()
                }
                completion(granted)
            }
        }
    }

    // MARK: - Daily Check-in Reminder

    func scheduleCheckInReminder() {
        guard isAuthorized && checkInReminderEnabled else { return }

        // Cancel existing
        cancelNotification(identifier: checkInIdentifier)

        let content = UNMutableNotificationContent()
        content.title = "Time to Check In"
        content.body = getCheckInMessage()
        content.sound = .default
        content.categoryIdentifier = "CHECKIN"

        // Schedule daily at user's preferred time
        let components = Calendar.current.dateComponents([.hour, .minute], from: checkInTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: checkInIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func getCheckInMessage() -> String {
        let messages = [
            "How was your day? Take a moment to reflect.",
            "A quick check-in keeps you on track. How are you feeling?",
            "End your day with intention. Complete your check-in.",
            "Your daily reflection awaits. How did today go?",
            "Stay mindful of your journey. Time for your check-in."
        ]
        return messages.randomElement() ?? messages[0]
    }

    // MARK: - First Lesson Reminder (Day 1)

    /// Schedules repeating morning reminder until Day 1 is completed
    func scheduleFirstLessonReminder() {
        guard isAuthorized && lessonReminderEnabled else { return }

        // Cancel any existing first lesson reminder
        cancelNotification(identifier: firstLessonIdentifier)

        let content = UNMutableNotificationContent()
        content.title = "Start Your Journey"
        content.body = getFirstLessonMessage()
        content.sound = .default
        content.categoryIdentifier = "LESSON"

        // Schedule daily at lesson time (default 8 AM)
        let components = Calendar.current.dateComponents([.hour, .minute], from: lessonTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: firstLessonIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func getFirstLessonMessage() -> String {
        let messages = [
            "Your first lesson is waiting. Begin your journey today.",
            "Day 1 is ready. Take the first step toward freedom.",
            "Start your transformation. Your first lesson awaits.",
            "The journey of a thousand miles begins with Day 1.",
            "Your path to recovery starts now. Open Day 1."
        ]
        return messages.randomElement() ?? messages[0]
    }

    /// Cancels the first lesson repeating reminder (called when Day 1 is completed)
    func cancelFirstLessonReminder() {
        cancelNotification(identifier: firstLessonIdentifier)
    }

    // MARK: - Lesson Completion Reminder

    /// Called when user completes a lesson - schedules reminder for next lesson 24h later
    func scheduleNextLessonReminder(completedDay: Int, totalLessons: Int = 30) {
        guard isAuthorized && lessonReminderEnabled else { return }

        // If Day 1 completed, cancel the repeating first lesson reminder
        if completedDay == 1 {
            cancelFirstLessonReminder()
        }

        // Don't schedule if all lessons completed
        let nextDay = completedDay + 1
        guard nextDay <= totalLessons else { return }

        // Cancel any existing lesson reminder
        cancelNotification(identifier: lessonIdentifier)

        let content = UNMutableNotificationContent()
        content.title = "Day \(nextDay) Lesson Ready"
        content.body = getLessonMessage(day: nextDay)
        content.sound = .default
        content.categoryIdentifier = "LESSON"

        // Schedule for 24 hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)

        let request = UNNotificationRequest(identifier: lessonIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func getLessonMessage(day: Int) -> String {
        let messages = [
            "Your next step on the journey awaits.",
            "Continue building your strength. Day \(day) is ready.",
            "Keep the momentum going. Your lesson is waiting.",
            "Another day of growth. Tap to start Day \(day).",
            "Feed your soul. Today's teaching is ready."
        ]
        return messages.randomElement() ?? messages[0]
    }

    /// Called when lesson reminders are enabled - checks if Day 1 needs reminding
    func scheduleLessonReminder(isDay1Completed: Bool = false) {
        guard isAuthorized && lessonReminderEnabled else { return }

        if !isDay1Completed {
            // User hasn't completed Day 1 yet - schedule repeating reminder
            scheduleFirstLessonReminder()
        }
        // If Day 1 is completed, the 24h chain handles subsequent reminders
    }

    // MARK: - Streak Milestone Notification

    func sendMilestoneNotification(days: Int, islamicName: String, meaning: String) {
        guard isAuthorized && milestoneAlertsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Milestone Reached: \(islamicName)"
        content.body = "\(days) days! \(meaning) Keep going, Allah is with you."
        content.sound = .default
        content.categoryIdentifier = "MILESTONE"

        // Trigger immediately (with small delay for better UX)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let identifier = "\(milestoneIdentifierPrefix)\(days)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Relapse Recovery

    /// Called when user relapses - cancels invalid notifications and schedules encouraging reminder
    func handleRelapse() {
        // Cancel any pending lesson notifications (they're now invalid - lessons may be locked)
        cancelNotification(identifier: lessonIdentifier)
        cancelNotification(identifier: firstLessonIdentifier)

        // Schedule a compassionate recovery reminder for tomorrow morning
        guard isAuthorized && lessonReminderEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "A New Beginning"
        content.body = getRelapseRecoveryMessage()
        content.sound = .default
        content.categoryIdentifier = "RECOVERY"

        // Schedule for tomorrow at lesson time (default 8 AM)
        var components = Calendar.current.dateComponents([.hour, .minute], from: lessonTime)
        // Add 1 day
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let tomorrowComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        components.year = tomorrowComponents.year
        components.month = tomorrowComponents.month
        components.day = tomorrowComponents.day

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: relapseRecoveryIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func getRelapseRecoveryMessage() -> String {
        let messages = [
            "Every setback is a setup for a comeback. Your journey continues.",
            "Allah's mercy is greater than any fall. Rise again.",
            "A new day, a new chance. Your lessons await when you're ready.",
            "The one who repents is beloved to Allah. Keep going.",
            "Falling is not failure. Staying down is. You've got this."
        ]
        return messages.randomElement() ?? messages[0]
    }

    // MARK: - Management

    func scheduleAllEnabledNotifications() {
        if checkInReminderEnabled {
            scheduleCheckInReminder()
        }
        if lessonReminderEnabled {
            scheduleLessonReminder()
        }
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Settings Persistence

    private func loadSettings() {
        let defaults = UserDefaults.standard

        checkInReminderEnabled = defaults.bool(forKey: "notification_checkin_enabled")
        lessonReminderEnabled = defaults.bool(forKey: "notification_lesson_enabled")
        milestoneAlertsEnabled = defaults.object(forKey: "notification_milestone_enabled") as? Bool ?? true

        if let checkInTimeInterval = defaults.object(forKey: "notification_checkin_time") as? TimeInterval {
            checkInTime = Date(timeIntervalSince1970: checkInTimeInterval)
        }

        if let lessonTimeInterval = defaults.object(forKey: "notification_lesson_time") as? TimeInterval {
            lessonTime = Date(timeIntervalSince1970: lessonTimeInterval)
        }
    }

    func saveSettings() {
        let defaults = UserDefaults.standard

        defaults.set(checkInReminderEnabled, forKey: "notification_checkin_enabled")
        defaults.set(lessonReminderEnabled, forKey: "notification_lesson_enabled")
        defaults.set(milestoneAlertsEnabled, forKey: "notification_milestone_enabled")
        defaults.set(checkInTime.timeIntervalSince1970, forKey: "notification_checkin_time")
        defaults.set(lessonTime.timeIntervalSince1970, forKey: "notification_lesson_time")

        // Reschedule with new settings
        cancelAllNotifications()
        scheduleAllEnabledNotifications()
    }

    // MARK: - Toggle Helpers

    func toggleCheckInReminder(_ enabled: Bool) {
        checkInReminderEnabled = enabled
        if enabled {
            scheduleCheckInReminder()
        } else {
            cancelNotification(identifier: checkInIdentifier)
        }
        saveSettings()
    }

    func toggleLessonReminder(_ enabled: Bool, isDay1Completed: Bool = false) {
        lessonReminderEnabled = enabled
        if enabled {
            scheduleLessonReminder(isDay1Completed: isDay1Completed)
        } else {
            cancelNotification(identifier: lessonIdentifier)
            cancelNotification(identifier: firstLessonIdentifier)
        }
        saveSettings()
    }

    func toggleMilestoneAlerts(_ enabled: Bool) {
        milestoneAlertsEnabled = enabled
        saveSettings()
    }

    func updateCheckInTime(_ time: Date) {
        checkInTime = time
        if checkInReminderEnabled {
            scheduleCheckInReminder()
        }
        saveSettings()
    }

    func updateLessonTime(_ time: Date) {
        lessonTime = time
        if lessonReminderEnabled {
            scheduleLessonReminder()
        }
        saveSettings()
    }
}
