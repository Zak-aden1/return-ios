//
//  TypewriterScreen.swift
//  Return
//
//  Onboarding Step 29: Personalized typewriter reveal
//  Creates emotional bridge before paywall
//

import SwiftUI
import CoreHaptics

struct TypewriterScreen: View {
    var onContinue: () -> Void

    @State private var displayedText: String = ""
    @State private var currentMessageIndex: Int = 0
    @State private var isTyping: Bool = false
    @State private var showContent: Bool = false

    // Haptic engine
    @State private var hapticEngine: CHHapticEngine?

    // Colors - Fajr Dawn palette
    private let bgTop = Color(hex: "FDF8F5")
    private let bgUpperMid = Color(hex: "F7EDE8")
    private let bgLowerMid = Color(hex: "EBE0E8")
    private let bgBottom = Color(hex: "DED0E0")

    private let accentViolet = Color(hex: "7B5E99")
    private let sunriseGlow = Color(hex: "F6C177")

    private let textHeading = Color(hex: "2D2438")
    private let textMuted = Color(hex: "9A8A9E")

    // Timing
    private let characterDelay: Double = 0.04  // 25 chars per second
    private let messagePause: Double = 1.2     // pause between messages

    // Messages - proven structure with Islamic framing
    private let messages: [String] = [
        "Welcome to Return,",
        "Your path to freedom.",
        "Based on your answers, we've built a plan just for you.",
        "It's designed to help you quit porn and reconnect with Allah.",
        "Now, it's time to invest in yourself."
    ]

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [bgTop, bgUpperMid, bgLowerMid, bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Mountains at bottom
            VStack {
                Spacer()
                TypewriterMountainsView()
                    .frame(height: 250)
            }
            .ignoresSafeArea()

            // Subtle center glow
            RadialGradient(
                colors: [
                    sunriseGlow.opacity(0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Main text area
                VStack(spacing: 24) {
                    // Displayed text
                    Text(displayedText)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(textHeading)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .frame(minHeight: 120)
                        .padding(.horizontal, 32)

                    // Typing indicator (3 bouncing dots)
                    if isTyping {
                        TypewriterDotsView(color: textMuted)
                            .transition(.opacity)
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: showContent)

                Spacer()
            }
        }
        .onAppear {
            prepareHaptics()
            showContent = true

            // Start typing after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                typeNextMessage()
            }
        }
    }

    // MARK: - Typing Animation

    private func typeNextMessage() {
        guard currentMessageIndex < messages.count else {
            // All messages complete - auto-advance to paywall
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onContinue()
            }
            return
        }

        let message = messages[currentMessageIndex]
        displayedText = ""
        isTyping = true

        // Type each character with delay
        for (index, character) in message.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * characterDelay) {
                displayedText += String(character)
                triggerCharacterHaptic()
            }
        }

        // After typing completes, pause then move to next message
        let typingDuration = Double(message.count) * characterDelay + messagePause

        DispatchQueue.main.asyncAfter(deadline: .now() + typingDuration) {
            withAnimation {
                isTyping = false
            }
            currentMessageIndex += 1

            // Small delay before next message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                typeNextMessage()
            }
        }
    }

    // MARK: - Haptics

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }

    private func triggerCharacterHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = hapticEngine else { return }

        // Stronger haptic for each character
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Silently fail - haptics are nice-to-have
        }
    }

}

// MARK: - Typewriter Dots View (3 bouncing dots)
struct TypewriterDotsView: View {
    let color: Color

    @State private var animating: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .offset(y: animating ? -6 : 0)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Typewriter Mountains View
struct TypewriterMountainsView: View {
    private let mountainBack = Color(hex: "C4B0D0")
    private let mountainMid = Color(hex: "B09DC4")
    private let mountainFront = Color(hex: "9D8AB5")
    private let sunriseGlow = Color(hex: "F6C177")
    private let sunriseRadiance = Color(hex: "FFD4A8")

    var body: some View {
        ZStack {
            // Sunrise glow at horizon
            VStack {
                Spacer()
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                sunriseRadiance.opacity(0.6),
                                sunriseGlow.opacity(0.4),
                                sunriseGlow.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 180
                        )
                    )
                    .frame(width: 380, height: 200)
                    .offset(y: 70)
            }

            // Mountain layers
            MountainShape(peaks: [0.2, 0.5, 0.8], heights: [0.35, 0.5, 0.3])
                .fill(mountainBack.opacity(0.5))
                .offset(y: 50)

            MountainShape(peaks: [0.15, 0.45, 0.75], heights: [0.45, 0.6, 0.38])
                .fill(mountainMid.opacity(0.65))
                .offset(y: 85)

            MountainShape(peaks: [0.1, 0.4, 0.7, 0.9], heights: [0.4, 0.55, 0.65, 0.35])
                .fill(mountainFront.opacity(0.8))
                .offset(y: 120)

            // Warm glow overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    sunriseGlow.opacity(0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .offset(y: 100)
        }
    }
}

#Preview {
    TypewriterScreen(onContinue: {})
}
