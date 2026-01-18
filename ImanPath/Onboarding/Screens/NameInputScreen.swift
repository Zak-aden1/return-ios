//
//  NameInputScreen.swift
//  ImanPath
//
//  Onboarding: Collect user's first name at end of quiz
//

import SwiftUI

struct NameInputScreen: View {
    var onContinue: (String) -> Void
    var onBack: () -> Void
    var progress: Double

    @State private var firstName: String = ""
    @State private var showContent: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    private let warmAmber = Color(hex: "C4956A")
    private let mutedText = Color(hex: "8A9BAE")

    private var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with progress
            OnboardingTopBar(
                progress: progress,
                onBack: onBack
            )
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: showContent)

            // Main content - grouped at top like Unchaind
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Finally, what's your name?")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .padding(.top, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                // Dark text field with visible placeholder
                TextField("", text: $firstName, prompt: Text("First Name").foregroundColor(Color.white.opacity(0.4)))
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1A2332"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        isTextFieldFocused ? warmAmber : Color(hex: "334155").opacity(0.5),
                                        lineWidth: isTextFieldFocused ? 2 : 1
                                    )
                            )
                    )
                    .focused($isTextFieldFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                // Continue button - directly under text field like Unchaind
                Button(action: {
                    let trimmedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                    onContinue(trimmedName)
                }) {
                    HStack(spacing: 8) {
                        Text("Complete Quiz")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(canContinue ? Color(hex: "0A1628") : Color(hex: "0A1628").opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(canContinue ? warmAmber : Color(hex: "8A9BAE").opacity(0.5))
                    )
                }
                .disabled(!canContinue)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
            }
            .padding(.horizontal, 24)

            Spacer()

            // Anonymous note at bottom
            Text("Your responses are anonymous")
                .font(.system(size: 14))
                .foregroundColor(mutedText)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            // Auto-focus the text field after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()
        NameInputScreen(
            onContinue: { _ in },
            onBack: {},
            progress: 0.75
        )
    }
}
