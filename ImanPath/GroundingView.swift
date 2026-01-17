//
//  GroundingView.swift
//  ImanPath
//
//  5-4-3-2-1 Grounding Technique - Sensory grounding for crisis moments
//

import SwiftUI

// MARK: - Grounding Step
struct GroundingStep: Identifiable {
    let id = UUID()
    let number: Int
    let sense: String
    let icon: String
    let instruction: String
    let color: Color
    let prompt: String
}

// MARK: - Main View
struct GroundingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: Int = 0  // 0 = intro, 1-5 = steps, 6 = complete
    @State private var isAnimating: Bool = false

    private let tealAccent = Color(hex: "5B9A9A")

    private let steps: [GroundingStep] = [
        GroundingStep(
            number: 5,
            sense: "SEE",
            icon: "eye.fill",
            instruction: "Look around and notice",
            color: Color(hex: "60A5FA"),
            prompt: "5 things you can see"
        ),
        GroundingStep(
            number: 4,
            sense: "TOUCH",
            icon: "hand.raised.fill",
            instruction: "Feel and acknowledge",
            color: Color(hex: "74B886"),
            prompt: "4 things you can feel"
        ),
        GroundingStep(
            number: 3,
            sense: "HEAR",
            icon: "ear.fill",
            instruction: "Listen carefully for",
            color: Color(hex: "E8B86D"),
            prompt: "3 things you can hear"
        ),
        GroundingStep(
            number: 2,
            sense: "SMELL",
            icon: "nose.fill",
            instruction: "Breathe in and notice",
            color: Color(hex: "A78BDA"),
            prompt: "2 things you can smell"
        ),
        GroundingStep(
            number: 1,
            sense: "TASTE",
            icon: "mouth.fill",
            instruction: "Focus on",
            color: Color(hex: "E88B8B"),
            prompt: "1 thing you can taste"
        )
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0F1419"),
                    Color(hex: "0A0E14"),
                    Color(hex: "080B0F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Dynamic glow based on current step
            if currentStep > 0 && currentStep <= 5 {
                RadialGradient(
                    colors: [steps[currentStep - 1].color.opacity(0.15), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 350
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentStep)
            } else {
                RadialGradient(
                    colors: [tealAccent.opacity(0.08), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Header
                HStack {
                    if currentStep == 0 {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }

                    Spacer()

                    if currentStep > 0 && currentStep <= 5 {
                        Text("Step \(currentStep) of 5")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Progress bar (only during steps)
                if currentStep > 0 && currentStep <= 5 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)
                                .cornerRadius(2)

                            Rectangle()
                                .fill(steps[currentStep - 1].color)
                                .frame(width: geo.size.width * CGFloat(currentStep) / 5, height: 4)
                                .cornerRadius(2)
                                .animation(.easeInOut(duration: 0.3), value: currentStep)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                Spacer()

                // Content based on current step
                if currentStep == 0 {
                    GroundingIntroContent()
                } else if currentStep <= 5 {
                    GroundingStepContent(step: steps[currentStep - 1], isAnimating: $isAnimating)
                } else {
                    GroundingCompleteContent()
                }

                Spacer()

                // Bottom button
                if currentStep == 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = 1
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text("Begin Grounding")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(tealAccent)
                                .shadow(color: tealAccent.opacity(0.4), radius: 12, y: 4)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                } else if currentStep <= 5 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep += 1
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text(currentStep == 5 ? "Finish" : "Next")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: currentStep == 5 ? "checkmark" : "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(steps[currentStep - 1].color)
                                .shadow(color: steps[currentStep - 1].color.opacity(0.4), radius: 12, y: 4)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                } else {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(tealAccent)
                                    .shadow(color: tealAccent.opacity(0.4), radius: 12, y: 4)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Intro Content
struct GroundingIntroContent: View {
    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        VStack(spacing: 28) {
            // Icon
            ZStack {
                Circle()
                    .fill(tealAccent.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "hand.raised.fingers.spread.fill")
                    .font(.system(size: 44))
                    .foregroundColor(tealAccent)
            }

            // Title
            VStack(spacing: 12) {
                Text("5-4-3-2-1 Grounding")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("A sensory technique to bring you back to the present moment")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Steps preview
            VStack(alignment: .leading, spacing: 14) {
                GroundingPreviewRow(number: "5", text: "things you can SEE", color: Color(hex: "60A5FA"))
                GroundingPreviewRow(number: "4", text: "things you can TOUCH", color: Color(hex: "74B886"))
                GroundingPreviewRow(number: "3", text: "things you can HEAR", color: Color(hex: "E8B86D"))
                GroundingPreviewRow(number: "2", text: "things you can SMELL", color: Color(hex: "A78BDA"))
                GroundingPreviewRow(number: "1", text: "thing you can TASTE", color: Color(hex: "E88B8B"))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "141A22"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Preview Row
struct GroundingPreviewRow: View {
    let number: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .frame(width: 32)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
    }
}

// MARK: - Step Content
struct GroundingStepContent: View {
    let step: GroundingStep
    @Binding var isAnimating: Bool

    @State private var pulseAnimation: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            // Large number with pulsing circle
            ZStack {
                // Outer pulse rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(step.color.opacity(0.1 - Double(i) * 0.03), lineWidth: 2)
                        .frame(width: 160 + CGFloat(i * 40), height: 160 + CGFloat(i * 40))
                        .scaleEffect(pulseAnimation ? 1.05 : 0.95)
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                            value: pulseAnimation
                        )
                }

                // Main circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                step.color.opacity(0.3),
                                step.color.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                // Number
                Text("\(step.number)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            // Sense label
            HStack(spacing: 10) {
                Image(systemName: step.icon)
                    .font(.system(size: 18))
                    .foregroundColor(step.color)

                Text(step.sense)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(step.color)
                    .tracking(2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(step.color.opacity(0.15))
            )

            // Instructions
            VStack(spacing: 12) {
                Text(step.instruction)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Text(step.prompt)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            // Tip
            Text(tipForStep(step.number))
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .onAppear {
            pulseAnimation = true
        }
    }

    private func tipForStep(_ number: Int) -> String {
        switch number {
        case 5: return "Look around slowly. Notice colors, shapes, and textures."
        case 4: return "Feel your feet on the ground, the texture of your clothes."
        case 3: return "Listen for distant sounds, nearby sounds, your own breathing."
        case 2: return "Notice any scents in the air, pleasant or neutral."
        case 1: return "Notice the taste in your mouth, or take a sip of water."
        default: return ""
        }
    }
}

// MARK: - Complete Content
struct GroundingCompleteContent: View {
    private let tealAccent = Color(hex: "5B9A9A")

    @State private var showCheckmark: Bool = false

    var body: some View {
        VStack(spacing: 28) {
            // Success icon
            ZStack {
                Circle()
                    .fill(tealAccent.opacity(0.15))
                    .frame(width: 120, height: 120)

                Circle()
                    .stroke(tealAccent, lineWidth: 3)
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(tealAccent)
                    .scaleEffect(showCheckmark ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheckmark)
            }

            // Text
            VStack(spacing: 12) {
                Text("You're Grounded")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("You've reconnected with the present moment. The urge will pass.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Reminder card
            VStack(spacing: 8) {
                Text("\"Verily, with hardship comes ease.\"")
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(.white.opacity(0.8))

                Text("— Quran 94:6")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(tealAccent)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(tealAccent.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(tealAccent.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showCheckmark = true
            }
        }
    }
}

#Preview {
    GroundingView()
}
