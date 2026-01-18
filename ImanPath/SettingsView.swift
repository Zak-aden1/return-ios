//
//  SettingsView.swift
//  ImanPath
//
//  App settings and preferences
//

import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @Query private var lessonProgress: [LessonProgress]

    @State private var user: User?
    @State private var coachEnabled = true
    @State private var showClearChatAlert = false
    @State private var showDeleteDataAlert = false
    @State private var showPermissionAlert = false

    private var isDay1Completed: Bool {
        lessonProgress.contains { $0.lessonDay == 1 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Notifications Section
                        SettingsSection(title: "NOTIFICATIONS") {
                            // Check-in Reminder
                            NotificationToggleRow(
                                icon: "heart.text.square.fill",
                                iconColor: Color(hex: "F59E0B"),
                                title: "Check-in Reminder",
                                subtitle: "Daily reminder to reflect",
                                isOn: Binding(
                                    get: { notificationManager.checkInReminderEnabled },
                                    set: { handleNotificationToggle(type: .checkIn, enabled: $0) }
                                ),
                                time: $notificationManager.checkInTime,
                                showTimePicker: notificationManager.checkInReminderEnabled,
                                onTimeChange: { notificationManager.updateCheckInTime($0) }
                            )

                            Divider()
                                .background(Color(hex: "334155"))
                                .padding(.horizontal, 16)

                            // Lesson Reminder
                            SettingsToggleRow(
                                icon: "book.fill",
                                iconColor: Color(hex: "5B9A9A"),
                                title: "Lesson Reminder",
                                subtitle: "Notifies 24h after completing a lesson",
                                isOn: Binding(
                                    get: { notificationManager.lessonReminderEnabled },
                                    set: { handleNotificationToggle(type: .lesson, enabled: $0) }
                                )
                            )

                            Divider()
                                .background(Color(hex: "334155"))
                                .padding(.horizontal, 16)

                            // Milestone Alerts
                            SettingsToggleRow(
                                icon: "star.fill",
                                iconColor: Color(hex: "E8B86D"),
                                title: "Milestone Alerts",
                                subtitle: "Celebrate your achievements",
                                isOn: Binding(
                                    get: { notificationManager.milestoneAlertsEnabled },
                                    set: { handleNotificationToggle(type: .milestone, enabled: $0) }
                                )
                            )
                        }

                        // Coach Section
                        SettingsSection(title: "COACH") {
                            SettingsToggleRow(
                                icon: "sparkles",
                                iconColor: Color(hex: "74B886"),
                                title: "AI Coach",
                                subtitle: "Personalized guidance and support",
                                isOn: $coachEnabled
                            )

                            Divider()
                                .background(Color(hex: "334155"))
                                .padding(.horizontal, 16)

                            SettingsButtonRow(
                                icon: "trash",
                                iconColor: Color(hex: "64748B"),
                                title: "Clear Chat History",
                                subtitle: "Delete all coach conversations"
                            ) {
                                showClearChatAlert = true
                            }
                        }

                        // Data Section
                        SettingsSection(title: "DATA & PRIVACY") {
                            SettingsButtonRow(
                                icon: "square.and.arrow.up",
                                iconColor: Color(hex: "60A5FA"),
                                title: "Export My Data",
                                subtitle: "Download all your data"
                            ) {
                                // TODO: Implement export
                            }

                            Divider()
                                .background(Color(hex: "334155"))
                                .padding(.horizontal, 16)

                            SettingsButtonRow(
                                icon: "trash.fill",
                                iconColor: Color(hex: "EF4444"),
                                title: "Delete All Data",
                                subtitle: "Permanently remove everything",
                                isDestructive: true
                            ) {
                                showDeleteDataAlert = true
                            }
                        }

                        // About Section
                        SettingsSection(title: "ABOUT") {
                            SettingsInfoRow(
                                icon: "info.circle",
                                title: "Version",
                                value: "1.0.0"
                            )

                            Divider()
                                .background(Color(hex: "334155"))
                                .padding(.horizontal, 16)

                            SettingsLinkRow(
                                icon: "lock.shield",
                                iconColor: Color(hex: "64748B"),
                                title: "Privacy Policy"
                            ) {
                                if let url = URL(string: "https://returntoiman.com/privacy") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            Divider()
                                .background(Color(hex: "334155"))
                                .padding(.horizontal, 16)

                            SettingsLinkRow(
                                icon: "doc.text",
                                iconColor: Color(hex: "64748B"),
                                title: "Terms of Service"
                            ) {
                                if let url = URL(string: "https://returntoiman.com/terms") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            Divider()
                                .background(Color(hex: "334155"))
                                .padding(.horizontal, 16)

                            SettingsLinkRow(
                                icon: "envelope",
                                iconColor: Color(hex: "64748B"),
                                title: "Send Feedback"
                            ) {
                                // TODO: Open email
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color(hex: "0A1628"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            loadSettings()
            notificationManager.checkAuthorizationStatus()
        }
        .onChange(of: coachEnabled) { _, newValue in
            saveCoachSetting(newValue)
        }
        .alert("Enable Notifications", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Notifications are disabled. Enable them in Settings to receive reminders.")
        }
        .alert("Clear Chat History?", isPresented: $showClearChatAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearChatHistory()
            }
        } message: {
            Text("This will delete all your coach conversations. This cannot be undone.")
        }
        .alert("Delete All Data?", isPresented: $showDeleteDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your data including journals, check-ins, and progress. This cannot be undone.")
        }
    }

    // MARK: - Notification Types

    private enum NotificationType {
        case checkIn, lesson, milestone
    }

    // MARK: - Notification Handling

    private func handleNotificationToggle(type: NotificationType, enabled: Bool) {
        // Check if we need to request permission
        if enabled && !notificationManager.isAuthorized {
            notificationManager.requestAuthorization { granted in
                if granted {
                    applyNotificationToggle(type: type, enabled: true)
                } else {
                    showPermissionAlert = true
                }
            }
        } else if enabled && notificationManager.isAuthorized {
            applyNotificationToggle(type: type, enabled: true)
        } else {
            applyNotificationToggle(type: type, enabled: false)
        }
    }

    private func applyNotificationToggle(type: NotificationType, enabled: Bool) {
        switch type {
        case .checkIn:
            notificationManager.toggleCheckInReminder(enabled)
        case .lesson:
            notificationManager.toggleLessonReminder(enabled, isDay1Completed: isDay1Completed)
        case .milestone:
            notificationManager.toggleMilestoneAlerts(enabled)
        }
    }

    // MARK: - Data

    private func loadSettings() {
        let dataManager = DataManager(modelContext: modelContext)
        user = dataManager.getOrCreateUser()
        coachEnabled = user?.coachEnabled ?? true
    }

    private func saveCoachSetting(_ enabled: Bool) {
        user?.coachEnabled = enabled
        user?.updatedAt = Date()
        try? modelContext.save()
    }

    private func clearChatHistory() {
        let dataManager = DataManager(modelContext: modelContext)
        dataManager.clearAllChatHistory()
    }

    private func deleteAllData() {
        // TODO: Implement full data deletion
        // This should delete all SwiftData entities
    }
}

// MARK: - Supporting Views

struct NotificationToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @Binding var time: Date
    let showTimePicker: Bool
    let onTimeChange: (Date) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "64748B"))
                }

                Spacer()

                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(Color(hex: "74B886"))
            }
            .padding(16)

            // Time picker row (shown when enabled)
            if showTimePicker {
                HStack {
                    Text("Reminder Time")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "94A3B8"))

                    Spacer()

                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .onChange(of: time) { _, newValue in
                            onTimeChange(newValue)
                        }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showTimePicker)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "64748B"))
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "1A2737"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "334155"), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "64748B"))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "74B886"))
        }
        .padding(16)
    }
}

struct SettingsButtonRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isDestructive ? Color(hex: "EF4444") : .white)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "64748B"))
                }

                Spacer()
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsLinkRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "64748B"))
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "64748B").opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "64748B"))
            }

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "64748B"))
        }
        .padding(16)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [User.self], inMemory: true)
}
