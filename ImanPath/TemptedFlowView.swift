//
//  TemptedFlowView.swift
//  ImanPath
//
//  Intervention Options - What do you need right now?
//

import SwiftUI
import UIKit

struct TemptedFlowView: View {
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)? = nil

    // Navigation states
    @State private var showBreathing: Bool = false
    @State private var showDhikr: Bool = false

    // Telegram community link
    private let communityURL = "https://t.me/+OlG8JBruJMYxN2E0"

    // Colors - calming blues/teals
    private let calmTeal = Color(hex: "5B9A9A")
    private let deepTeal = Color(hex: "3D7A7A")
    private let softBlue = Color(hex: "6B8CAE")

    var body: some View {
        ZStack {
            // Starry background
            SpaceBackground()

            // Content
            VStack(spacing: 0) {
                // Top bar with close button
                HStack {
                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer().frame(height: 40)

                // Title
                VStack(spacing: 12) {
                    Text("Stay Strong")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("Get the support you need")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "8A9BAE"))
                }

                Spacer().frame(height: 48)

                // Intervention cards
                VStack(spacing: 16) {
                    // Breathing
                    InterventionCard(
                        icon: "wind",
                        title: "Breathing",
                        subtitle: "Calm your mind & body",
                        accentColor: calmTeal
                    ) {
                        triggerHaptic(.medium)
                        showBreathing = true
                    }

                    // Dhikr
                    InterventionCard(
                        icon: "hands.clap.fill",
                        title: "Dhikr",
                        subtitle: "Remember Allah",
                        accentColor: softBlue
                    ) {
                        triggerHaptic(.medium)
                        showDhikr = true
                    }

                    // Community
                    InterventionCard(
                        icon: "person.2.fill",
                        title: "Chat with Community",
                        subtitle: "You're not alone",
                        accentColor: deepTeal
                    ) {
                        triggerHaptic(.medium)
                        openCommunity()
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Encouragement text
                Text("This urge will pass in 10-15 minutes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "8A9BAE"))
                    .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showBreathing) {
            BreathingExerciseView(onComplete: {
                dismiss()
                onComplete?()
            })
        }
        .fullScreenCover(isPresented: $showDhikr) {
            DhikrCounterView(onComplete: {
                dismiss()
                onComplete?()
            })
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func openCommunity() {
        if let url = URL(string: communityURL) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Intervention Card
struct InterventionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Circle()
                        .stroke(accentColor.opacity(0.4), lineWidth: 1)
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "8A9BAE"))
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        accentColor.opacity(0.3),
                                        accentColor.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: accentColor.opacity(0.15), radius: 20, y: 8)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    TemptedFlowView()
}
