//
//  BreathingExerciseView.swift
//  ImanPath
//
//  Calming breathing exercise with 5 cycles
//

import SwiftUI

struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)? = nil

    // Breathing state
    @State private var currentCycle: Int = 1
    @State private var breathPhase: BreathPhase = .ready
    @State private var circleScale: CGFloat = 0.6
    @State private var phaseTimer: Timer?
    @State private var countdown: Int = 4
    @State private var isCompleted: Bool = false
    @State private var showRenewPromise: Bool = false

    // Colors
    private let calmTeal = Color(hex: "5B9A9A")
    private let deepTeal = Color(hex: "3D7A7A")
    private let glowColor = Color(hex: "7FBFBF")

    private let totalCycles = 5

    // Verses for each cycle
    private let verses: [(text: String, reference: String)] = [
        ("Verily, with hardship comes ease.", "Quran 94:6"),
        ("Allah does not burden a soul beyond that it can bear.", "Quran 2:286"),
        ("And He is with you wherever you are.", "Quran 57:4"),
        ("So remember Me; I will remember you.", "Quran 2:152"),
        ("Indeed, Allah is with the patient.", "Quran 2:153")
    ]

    enum BreathPhase {
        case ready
        case starting  // 3-2-1 countdown
        case inhale
        case hold
        case exhale
        case pause

        var instruction: String {
            switch self {
            case .ready: return "Get Ready"
            case .starting: return "Starting..."
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            case .pause: return "Rest"
            }
        }

        var duration: Int {
            switch self {
            case .ready: return 0
            case .starting: return 3
            case .inhale: return 4
            case .hold: return 4
            case .exhale: return 4
            case .pause: return 2
            }
        }
    }

    var body: some View {
        ZStack {
            // Background
            SpaceBackground()

            // Ambient glow behind circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            calmTeal.opacity(0.3),
                            calmTeal.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 250
                    )
                )
                .scaleEffect(circleScale * 1.5)
                .blur(radius: 40)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Spacer()

                    Button(action: {
                        stopBreathing()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                // Main breathing circle
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(
                                calmTeal.opacity(0.1 - Double(i) * 0.03),
                                lineWidth: 1
                            )
                            .frame(width: 220 + CGFloat(i * 40), height: 220 + CGFloat(i * 40))
                            .scaleEffect(circleScale)
                    }

                    // Main breathing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    glowColor.opacity(0.4),
                                    calmTeal.opacity(0.6),
                                    deepTeal.opacity(0.8)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 110
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(circleScale)
                        .shadow(color: calmTeal.opacity(0.5), radius: 30, x: 0, y: 0)
                        .shadow(color: calmTeal.opacity(0.3), radius: 60, x: 0, y: 0)

                    // Inner circle with countdown
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .scaleEffect(circleScale)
                        .overlay(
                            Text("\(countdown)")
                                .font(.system(size: 36, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(breathPhase == .ready ? 0 : 1)
                                .contentTransition(.numericText())
                        )
                }

                Spacer().frame(height: 40)

                // Phase instruction
                VStack(spacing: 12) {
                    Text(breathPhase.instruction)
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3), value: breathPhase)

                    // Cycle indicator (only show during exercise)
                    if breathPhase != .ready && breathPhase != .starting {
                        Text("Cycle \(currentCycle) of \(totalCycles)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "8A9BAE"))
                            .transition(.opacity)
                    }
                }

                Spacer().frame(height: 48)

                // Verse card (hide during starting countdown)
                if !isCompleted && breathPhase != .ready && breathPhase != .starting {
                    VStack(spacing: 12) {
                        Text("\"\(verses[currentCycle - 1].text)\"")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)

                        Text("— \(verses[currentCycle - 1].reference)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(calmTeal)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(calmTeal.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .id(currentCycle)
                }

                Spacer()

                // Bottom button
                if isCompleted {
                    VStack(spacing: 16) {
                        Text("Well done. You chose strength.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)

                        Button(action: { showRenewPromise = true }) {
                            Text("Renew My Promise")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(calmTeal)
                                        .shadow(color: calmTeal.opacity(0.4), radius: 12, y: 4)
                                )
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 48)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else if breathPhase == .ready {
                    Button(action: { startBreathing() }) {
                        Text("Begin")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(calmTeal)
                                    .shadow(color: calmTeal.opacity(0.4), radius: 12, y: 4)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                } else if breathPhase == .starting {
                    // During starting countdown, just show empty space
                    Spacer().frame(height: 100)
                        .padding(.bottom, 48)
                } else {
                    // Skip option during exercise - styled button
                    Button(action: {
                        stopBreathing()
                        showRenewPromise = true
                    }) {
                        Text("I'm better, continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 26)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            stopBreathing()
        }
        .fullScreenCover(isPresented: $showRenewPromise) {
            RenewPromiseView(onComplete: {
                dismiss()
                onComplete?()
            })
        }
    }

    // MARK: - Breathing Logic

    private func startBreathing() {
        runPhase(.starting)
    }

    private func stopBreathing() {
        phaseTimer?.invalidate()
        phaseTimer = nil
    }

    private func runPhase(_ phase: BreathPhase) {
        breathPhase = phase
        countdown = phase.duration

        // Animate circle based on phase
        withAnimation(.easeInOut(duration: Double(phase.duration))) {
            switch phase {
            case .inhale:
                circleScale = 1.0
            case .exhale:
                circleScale = 0.6
            case .hold, .pause, .ready, .starting:
                break
            }
        }

        // Countdown timer
        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                advancePhase()
            }
        }
    }

    private func advancePhase() {
        switch breathPhase {
        case .ready:
            runPhase(.starting)
        case .starting:
            runPhase(.inhale)
        case .inhale:
            runPhase(.hold)
        case .hold:
            runPhase(.exhale)
        case .exhale:
            if currentCycle < totalCycles {
                // Brief pause then next cycle
                runPhase(.pause)
            } else {
                // Completed all cycles
                withAnimation(.easeInOut(duration: 0.5)) {
                    isCompleted = true
                }
            }
        case .pause:
            withAnimation(.easeInOut(duration: 0.3)) {
                currentCycle += 1
            }
            runPhase(.inhale)
        }
    }
}

#Preview {
    BreathingExerciseView()
}
