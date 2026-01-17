//
//  CoachWelcome.swift
//  ImanPath
//
//  Welcome/empty state for Streak Coach chat
//

import SwiftUI

struct CoachWelcome: View {
    var currentStreak: Int = 0
    var messagesRemaining: Int = 100
    var onSuggestionTap: ((String) -> Void)?

    private let accentGreen = Color(hex: "74B886")
    private let accentTeal = Color(hex: "5EEAD4")
    private let accentGold = Color(hex: "D4AF37")

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Coach icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1E3A5F"), Color(hex: "0F2942")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: accentGreen.opacity(0.3), radius: 20)

                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(accentGreen)
            }

            // Title & subtitle
            VStack(spacing: 12) {
                Text("Coach")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(greetingMessage)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "94A3B8"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Data info
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(accentGreen)

                    Text("Uses your journals, check-ins & streaks")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "64748B"))
                }

                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(accentGreen)

                    Text("Private - your data stays on device")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "64748B"))
                }
            }
            .padding(.top, 8)

            // Suggested prompts
            VStack(spacing: 12) {
                Text("Try asking:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "64748B"))

                VStack(spacing: 10) {
                    SuggestionChip(text: "I'm struggling right now") {
                        onSuggestionTap?("I'm struggling right now")
                    }

                    SuggestionChip(text: "What patterns do you see?") {
                        onSuggestionTap?("What patterns do you see in my data?")
                    }

                    SuggestionChip(text: "Help me stay strong tonight") {
                        onSuggestionTap?("Help me stay strong tonight")
                    }
                }
            }
            .padding(.top, 16)

            // Messages remaining
            Text("\(messagesRemaining) messages remaining today")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(accentTeal)
                .padding(.top, 24)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var greetingMessage: String {
        if currentStreak == 0 {
            return "I'm here to support you on your journey. Ask me anything - I'll use your data to give personalized guidance."
        } else if currentStreak < 7 {
            return "Day \(currentStreak) - you're building momentum! I'm here whenever you need support."
        } else if currentStreak < 30 {
            return "Day \(currentStreak) - strong progress! Let's talk about how you're feeling."
        } else {
            return "Day \(currentStreak) - incredible dedication! I'm honored to be part of your journey."
        }
    }
}

struct SuggestionChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "E2E8F0"))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "64748B"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1A2737"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "334155"), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CoachWelcome(currentStreak: 12) { suggestion in
        print("Tapped: \(suggestion)")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
