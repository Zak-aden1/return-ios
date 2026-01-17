//
//  WhyHereScreen.swift
//  ImanPath
//
//  Onboarding Step 2: Why Are You Here?
//

import SwiftUI
import UIKit

struct WhyHereScreen: View {
    var onContinue: (Set<String>) -> Void
    var onBack: () -> Void
    let progress: Double // e.g., 2/20 = 0.1

    @State private var selectedReasons: Set<String> = []
    @State private var showContent: Bool = false

    private let warmAmber = Color(hex: "C4956A")
    private let cardBg = Color(hex: "1A2332")
    private let mutedText = Color(hex: "8A9BAE")

    private let reasons: [(id: String, text: String, icon: String)] = [
        ("quit_porn", "I want to quit porn", "xmark.circle.fill"),
        ("strengthen_iman", "I want to strengthen my iman", "sparkles"),
        ("protect_relationships", "I want to protect my relationships", "heart.fill"),
        ("feel_clean", "I want to feel clean again", "drop.fill"),
        ("preparing_marriage", "I'm preparing for marriage", "person.2.fill"),
        ("other", "Other", "ellipsis.circle.fill")
    ]

    private var canContinue: Bool {
        !selectedReasons.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with back button and progress
            OnboardingTopBar(
                progress: progress,
                onBack: onBack
            )
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    // Header
                    VStack(spacing: 12) {
                        Text("What brought you here today?")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Select all that apply")
                            .font(.system(size: 15))
                            .foregroundColor(mutedText)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    Spacer().frame(height: 8)

                    // Selection cards
                    VStack(spacing: 12) {
                        ForEach(Array(reasons.enumerated()), id: \.element.id) { index, reason in
                            SelectionCard(
                                text: reason.text,
                                icon: reason.icon,
                                isSelected: selectedReasons.contains(reason.id),
                                accentColor: warmAmber
                            ) {
                                triggerHaptic(.light)
                                if selectedReasons.contains(reason.id) {
                                    selectedReasons.remove(reason.id)
                                } else {
                                    selectedReasons.insert(reason.id)
                                }
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.3 + Double(index) * 0.08), value: showContent)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 100)
                }
            }

            // Bottom button
            OnboardingBottomButton(
                title: "Continue",
                isEnabled: canContinue,
                accentColor: warmAmber
            ) {
                triggerHaptic(.medium)
                onContinue(selectedReasons)
            }
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.6), value: showContent)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Selection Card
private struct SelectionCard: View {
    let text: String
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    private let cardBg = Color(hex: "1A2332")

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? accentColor : Color(hex: "64748B"))
                    .frame(width: 24)

                // Text
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(hex: "94A3B8"))

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .stroke(isSelected ? accentColor : Color(hex: "334155"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? accentColor : Color(hex: "334155").opacity(0.5), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(OnboardingScaleButtonStyle())
    }
}

// MARK: - Scale Button Style (shared across onboarding screens)
struct OnboardingScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Onboarding Top Bar
struct OnboardingTopBar: View {
    let progress: Double
    var onBack: (() -> Void)? = nil

    private let warmAmber = Color(hex: "C4956A")

    var body: some View {
        HStack(spacing: 16) {
            // Back button
            if let onBack = onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            } else {
                Spacer().frame(width: 44)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    // Progress
                    RoundedRectangle(cornerRadius: 3)
                        .fill(warmAmber)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)

            // Spacer for symmetry
            Spacer().frame(width: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Onboarding Bottom Button
struct OnboardingBottomButton: View {
    let title: String
    let isEnabled: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [Color.clear, Color(hex: "0A1628").opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)

            // Button container
            VStack(spacing: 0) {
                Button(action: action) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isEnabled ? .white : .white.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(isEnabled ? accentColor : Color(hex: "1A2230"))
                                .shadow(color: isEnabled ? accentColor.opacity(0.4) : .clear, radius: 12, y: 4)
                        )
                }
                .disabled(!isEnabled)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .background(Color(hex: "0A1628").opacity(0.95))
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()
        WhyHereScreen(
            onContinue: { _ in },
            onBack: {},
            progress: 0.1
        )
    }
}
