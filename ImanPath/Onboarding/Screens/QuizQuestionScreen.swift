//
//  QuizQuestionScreen.swift
//  ImanPath
//
//  Reusable single-select quiz question screen for onboarding
//

import SwiftUI
import UIKit

struct QuizQuestion {
    let id: String
    let question: String
    let subtitle: String?
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id: String
    let text: String
    let icon: String?

    init(id: String, text: String, icon: String? = nil) {
        self.id = id
        self.text = text
        self.icon = icon
    }
}

struct QuizQuestionScreen: View {
    let question: QuizQuestion
    let progress: Double
    var onContinue: (String) -> Void
    var onBack: () -> Void
    var prewarm: Bool = false

    @State private var selectedOption: String? = nil
    @State private var showContent: Bool = false
    @State private var isAdvancing: Bool = false
    @State private var advanceToken: UUID? = nil

    private let warmAmber = Color(hex: "C4956A")
    private let cardBg = Color(hex: "1A2332")
    private let mutedText = Color(hex: "8A9BAE")

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            OnboardingTopBar(
                progress: progress,
                onBack: onBack
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 32)

                    // Question header
                    VStack(spacing: 12) {
                        Text(question.question)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        if let subtitle = question.subtitle {
                            Text(subtitle)
                                .font(.system(size: 15))
                                .foregroundColor(mutedText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 16)

                    // Options - tap to select and auto-advance
                    VStack(spacing: 12) {
                        ForEach(question.options) { option in
                            QuizOptionCard(
                                option: option,
                                isSelected: selectedOption == option.id,
                                accentColor: warmAmber
                            ) {
                                guard !isAdvancing else { return }
                                triggerHaptic(.light)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedOption = option.id
                                }
                                // Auto-advance after brief visual feedback
                                let token = UUID()
                                advanceToken = token
                                isAdvancing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    guard advanceToken == token else { return }
                                    triggerHaptic(.medium)
                                    onContinue(option.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }

            Spacer()

            // Anonymous note - outside ScrollView so it stays at bottom
            Text("Your responses are anonymous")
                .font(.system(size: 14))
                .foregroundColor(mutedText)
                .padding(.bottom, 40)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.2), value: showContent)
        .onAppear {
            // Reset state when appearing (for back navigation)
            selectedOption = nil
            isAdvancing = false
            advanceToken = nil
            showContent = !prewarm
        }
        .onDisappear {
            advanceToken = nil
            isAdvancing = false
        }
        .onChange(of: question.id) { _, _ in
            // Reset state when question changes (view reused)
            selectedOption = nil
            isAdvancing = false
            advanceToken = nil
            if prewarm {
                showContent = false
            } else {
                showContent = true
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Quiz Option Card
private struct QuizOptionCard: View {
    let option: QuizOption
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    private let cardBg = Color(hex: "1A2332")

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Optional icon
                if let icon = option.icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? accentColor : Color(hex: "64748B"))
                        .frame(width: 24)
                }

                // Text
                Text(option.text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(hex: "94A3B8"))

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? accentColor : Color(hex: "334155"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 12, height: 12)
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

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()
        QuizQuestionScreen(
            question: QuizQuestion(
                id: "struggle_duration",
                question: "How long have you struggled with this?",
                subtitle: "Be honest — this helps us personalize your journey",
                options: [
                    QuizOption(id: "less_1", text: "Less than 1 year"),
                    QuizOption(id: "1_3", text: "1-3 years"),
                    QuizOption(id: "3_5", text: "3-5 years"),
                    QuizOption(id: "5_10", text: "5-10 years"),
                    QuizOption(id: "10_plus", text: "10+ years")
                ]
            ),
            progress: 0.15,
            onContinue: { _ in },
            onBack: {}
        )
    }
}
