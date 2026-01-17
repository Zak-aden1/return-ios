//
//  GoalsSelectionScreen.swift
//  ImanPath
//
//  Onboarding Step 23: Goal selection multi-select screen
//

import SwiftUI
import UIKit

struct GoalsSelectionScreen: View {
    var onContinue: (Set<String>) -> Void
    var onBack: () -> Void

    @State private var selectedGoals: Set<String> = []
    @State private var showContent: Bool = false

    // Colors
    private let bgColor = Color(hex: "0A1628")
    private let cardBg = Color(hex: "1A2332")
    private let warmAmber = Color(hex: "C4956A")
    private let mutedText = Color(hex: "8A9BAE")

    // Goal options
    private let goals: [(id: String, emoji: String, text: String)] = [
        ("energy", "⚡", "More energy & motivation"),
        ("iman", "📖", "Strengthen my iman"),
        ("mood", "😊", "Improve my mood"),
        ("relationships", "❤️", "Stronger relationships"),
        ("focus", "🧠", "Improved focus & clarity"),
        ("clean", "✨", "Feel spiritually clean"),
        ("self_control", "💪", "Better self-control")
    ]

    private var canContinue: Bool {
        !selectedGoals.isEmpty
    }

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back button
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: showContent)

                // Title section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Track your goals")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("Every journey is different. Select the goals you want to focus on")
                        .font(.system(size: 16))
                        .foregroundColor(mutedText)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                // Goal cards
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                            GoalCard(
                                emoji: goal.emoji,
                                text: goal.text,
                                isSelected: selectedGoals.contains(goal.id)
                            ) {
                                triggerHaptic(.light)
                                if selectedGoals.contains(goal.id) {
                                    selectedGoals.remove(goal.id)
                                } else {
                                    selectedGoals.insert(goal.id)
                                }
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 15)
                            .animation(.easeOut(duration: 0.4).delay(0.2 + Double(index) * 0.05), value: showContent)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // Space for button
                }

                Spacer(minLength: 0)

                // Bottom button
                VStack(spacing: 0) {
                    // Gradient fade
                    LinearGradient(
                        colors: [bgColor.opacity(0), bgColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)

                    // Button container
                    VStack {
                        Button(action: {
                            triggerHaptic(.medium)
                            onContinue(selectedGoals)
                        }) {
                            HStack(spacing: 8) {
                                Text("Track these goals")
                                    .font(.system(size: 17, weight: .semibold))

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(canContinue ? bgColor : bgColor.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(canContinue ? Color.white : Color.white.opacity(0.5))
                            )
                        }
                        .disabled(!canContinue)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    .background(bgColor)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)
            }
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

// MARK: - Goal Card
private struct GoalCard: View {
    let emoji: String
    let text: String
    let isSelected: Bool
    let action: () -> Void

    private let cardBg = Color(hex: "1A2332")
    private let warmAmber = Color(hex: "C4956A")

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Emoji
                Text(emoji)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)

                // Text
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .stroke(isSelected ? warmAmber : Color(hex: "334155"), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isSelected {
                        Circle()
                            .fill(warmAmber)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "0A1628"))
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
                            .stroke(
                                isSelected ? warmAmber : Color(hex: "334155").opacity(0.5),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(GoalCardButtonStyle())
    }
}

private struct GoalCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    GoalsSelectionScreen(
        onContinue: { _ in },
        onBack: {}
    )
}
