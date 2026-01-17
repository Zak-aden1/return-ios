//
//  NotificationPermissionScreen.swift
//  Return
//
//  Notification permission request screen
//  Shows mock iOS dialog to prime user before real permission request
//

import SwiftUI
import UserNotifications

struct NotificationPermissionScreen: View {
    var onContinue: () -> Void

    @State private var showContent = false

    private let bgPrimary = Color(hex: "0A1628")
    private let dialogBg = Color(hex: "1E293B")
    private let dividerColor = Color(hex: "334155")

    var body: some View {
        ZStack {
            bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("Stay on your path")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer().frame(height: 16)

                // Subtitle - explanation text ABOVE dialog
                Text("Notifications help you stay on track with daily reminders and milestone celebrations.")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "8A9BAE"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 40)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)

                Spacer().frame(height: 32)

                // Mock iOS notification dialog
                VStack(spacing: 0) {
                    // Dialog content - simple text like iOS
                    VStack(spacing: 4) {
                        Text("Return would like to send you")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Notifications")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)

                    // Divider
                    Rectangle()
                        .fill(dividerColor)
                        .frame(height: 0.5)

                    // Buttons
                    HStack(spacing: 0) {
                        // Don't Allow
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            onContinue()
                        }) {
                            Text("Don't Allow")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(hex: "94A3B8"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }

                        // Vertical divider
                        Rectangle()
                            .fill(dividerColor)
                            .frame(width: 0.5, height: 50)

                        // Allow - emphasized
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            requestNotificationPermission()
                        }) {
                            Text("Allow")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "0F172A"))
                        }
                    }
                }
                .background(dialogBg)
                .cornerRadius(14)
                .padding(.horizontal, 48)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.9)

                // Pointing finger - offset to point at "Allow" button
                HStack {
                    Spacer()
                    Text("👆")
                        .font(.system(size: 32))
                    Spacer().frame(width: 80)
                }
                .padding(.top, 16)
                .opacity(showContent ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showContent = true
            }
        }
    }

    private func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted in
            // Enable reminders by default if permission granted
            if granted {
                NotificationManager.shared.toggleCheckInReminder(true)
                NotificationManager.shared.toggleLessonReminder(true, isDay1Completed: false)
            }
            onContinue()
        }
    }
}

#Preview {
    NotificationPermissionScreen(onContinue: {})
}
