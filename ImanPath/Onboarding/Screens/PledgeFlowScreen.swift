//
//  PledgeFlowScreen.swift
//  ImanPath
//
//  Onboarding Step 24.5: 3 pledges with hold-to-commit interaction
//  Inspired by Unchaind's pledge flow
//

import SwiftUI
import UIKit

struct PledgeFlowScreen: View {
    var onComplete: () -> Void
    var onBack: () -> Void

    @State private var currentPledge: Int = 1
    @State private var showCelebration: Bool = false
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding: Bool = false
    @State private var showContent: Bool = false

    private let totalPledges = 3
    private let holdDuration: Double = 2.0 // seconds to hold

    // Colors - "Fajr Dawn" palette
    // Background gradient
    private let bgTop = Color(hex: "FDF8F5")         // Warm ivory
    private let bgUpperMid = Color(hex: "F7EDE8")    // Soft blush
    private let bgLowerMid = Color(hex: "EBE0E8")    // Dusty rose
    private let bgBottom = Color(hex: "DED0E0")      // Soft mauve

    // Accent colors
    private let sunriseGlow = Color(hex: "F6C177")   // Warm amber
    private let accentViolet = Color(hex: "7B5E99")  // Rich violet

    // Text colors
    private let textHeading = Color(hex: "2D2438")   // Deep plum
    private let textBody = Color(hex: "5A4A66")      // Muted plum
    private let textMuted = Color(hex: "9A8A9E")     // Soft gray-purple

    // Button
    private let buttonBg = Color(hex: "FFFCF8")      // Warm white

    // Pledge data
    private let pledges: [(question: String, verse: String, reference: String)] = [
        (
            "Do I commit to seeking Allah's protection from Shaytan and my desires?",
            "And if an evil suggestion comes to you from Satan, then seek refuge in Allah. Indeed, He is Hearing and Knowing.",
            "Quran 7:200"
        ),
        (
            "Do I commit to lowering my gaze and guarding my heart, knowing this leads to freedom?",
            "Tell the believing men to lower their gaze and guard their private parts. That is purer for them.",
            "Quran 24:30"
        ),
        (
            "Do I trust in Allah's mercy, knowing He forgives those who sincerely repent?",
            "Say: O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins.",
            "Quran 39:53"
        )
    ]

    private var currentPledgeData: (question: String, verse: String, reference: String) {
        pledges[currentPledge - 1]
    }

    private var progress: Double {
        Double(currentPledge - 1) / Double(totalPledges)
    }

    var body: some View {
        ZStack {
            if showCelebration {
                // Celebration screen
                CelebrationView(
                    pledgeNumber: currentPledge,
                    totalPledges: totalPledges,
                    onComplete: {
                        if currentPledge < totalPledges {
                            // Next pledge
                            withAnimation(.easeOut(duration: 0.3)) {
                                showCelebration = false
                                currentPledge += 1
                                holdProgress = 0
                                isHolding = false
                            }
                        } else {
                            // All pledges done
                            onComplete()
                        }
                    }
                )
                .transition(.opacity)
            } else {
                // Pledge screen
                pledgeView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showCelebration)
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }

    // MARK: - Pledge View
    private var pledgeView: some View {
        ZStack {
            // Gradient background - Fajr Dawn palette
            LinearGradient(
                colors: [
                    bgTop,
                    bgUpperMid,
                    bgLowerMid,
                    bgBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Mountain layers at bottom
            VStack {
                Spacer()
                FajrMountainsView()
                    .frame(height: 280)
            }
            .ignoresSafeArea()

            // Main content (will be covered by white overlay)
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(accentViolet.opacity(0.2))
                            .frame(height: 4)

                        Rectangle()
                            .fill(accentViolet)
                            .frame(width: geometry.size.width * (progress + (Double(holdProgress) / Double(totalPledges))), height: 4)
                            .animation(.linear(duration: 0.1), value: holdProgress)
                    }
                }
                .frame(height: 4)
                .padding(.top, 8)

                // Pledge counter
                Text("Pledge \(currentPledge) / \(totalPledges)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textMuted)
                    .padding(.top, 16)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)

                Spacer()

                // Pledge question
                Text(currentPledgeData.question)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(textHeading)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                    .id("question_\(currentPledge)")

                // Quran verse
                VStack(spacing: 8) {
                    Text("\"\(currentPledgeData.verse)\"")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(textBody)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)

                    Text("– \(currentPledgeData.reference)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(accentViolet)
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                .id("verse_\(currentPledge)")

                Spacer()

                // Spacer for button area
                Spacer().frame(height: 140)
            }

            // White overlay that fades in - covers everything
            // Button is on a separate layer ABOVE this, so it stays visible
            Color.white
                .opacity(Double(holdProgress))
                .animation(.linear(duration: 0.05), value: holdProgress)
                .ignoresSafeArea()

            // Button layer - always on top, not covered by white
            VStack {
                Spacer()

                VStack(spacing: 16) {
                    // Button with progress fill
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: 30)
                            .fill(buttonBg)
                            .shadow(color: accentViolet.opacity(0.15), radius: 12, x: 0, y: 6)

                        // Progress fill
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 30)
                                .fill(sunriseGlow.opacity(0.35))
                                .frame(width: geometry.size.width * holdProgress)
                                .animation(.linear(duration: 0.05), value: holdProgress)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 30))

                        // Text - changes when holding
                        HStack(spacing: 8) {
                            Text(isHolding ? "Keep Holding..." : "Press & Hold to Commit")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(textHeading)
                                .animation(.easeInOut(duration: 0.2), value: isHolding)

                            Text(isHolding ? "✊" : "✋")
                                .font(.system(size: 20))
                                .animation(.easeInOut(duration: 0.2), value: isHolding)
                        }
                    }
                    .frame(height: 60)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isHolding {
                                    isHolding = true
                                    startHoldTimer()
                                }
                            }
                            .onEnded { _ in
                                isHolding = false
                                if holdProgress < 1.0 {
                                    // Reset if not complete
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        holdProgress = 0
                                    }
                                }
                            }
                    )

                    // Previous button (if not first pledge)
                    if currentPledge > 1 {
                        Button(action: {
                            withAnimation {
                                currentPledge -= 1
                                holdProgress = 0
                            }
                        }) {
                            Text("previous")
                                .font(.system(size: 14))
                                .foregroundColor(textMuted)
                        }
                    } else {
                        // Back button on first pledge
                        Button(action: onBack) {
                            Text("back")
                                .font(.system(size: 14))
                                .foregroundColor(textMuted)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)
            }
        }
    }

    // MARK: - Hold Timer
    private func startHoldTimer() {
        let interval: Double = 0.02
        let increment = interval / holdDuration

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if isHolding && holdProgress < 1.0 {
                holdProgress += increment

                // Haptic feedback at intervals
                if Int(holdProgress * 100) % 25 == 0 {
                    triggerHaptic(.light)
                }

                if holdProgress >= 1.0 {
                    timer.invalidate()
                    holdProgress = 1.0
                    triggerHaptic(.heavy)

                    // Show celebration
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            showCelebration = true
                        }
                    }
                }
            } else if !isHolding {
                timer.invalidate()
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    let pledgeNumber: Int
    let totalPledges: Int
    var onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var handsScale: CGFloat = 0.5
    @State private var glowOpacity: Double = 0

    // Colors matching Fajr palette
    private let bgColor = Color(hex: "FDF8F5")
    private let textHeading = Color(hex: "2D2438")
    private let accentViolet = Color(hex: "7B5E99")
    private let sunriseGlow = Color(hex: "F6C177")

    var body: some View {
        ZStack {
            // Warm off-white background
            bgColor.ignoresSafeArea()

            // Subtle radial glow
            RadialGradient(
                colors: [
                    sunriseGlow.opacity(glowOpacity * 0.3),
                    sunriseGlow.opacity(glowOpacity * 0.1),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 250
            )

            VStack(spacing: 24) {
                Spacer()

                // Raised hands emoji (celebration)
                Text("🙌")
                    .font(.system(size: 100))
                    .scaleEffect(handsScale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: handsScale)

                // Pledge done text
                VStack(spacing: 4) {
                    Text("Pledge \(pledgeNumber)/\(totalPledges) Done")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(textHeading)

                    if pledgeNumber == totalPledges {
                        Text("All pledges complete")
                            .font(.system(size: 14))
                            .foregroundColor(accentViolet)
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)

                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
                handsScale = 1.0
            }

            withAnimation(.easeOut(duration: 0.8)) {
                glowOpacity = 1.0
            }

            // Auto-advance after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}

// MARK: - Fajr Mountains View (warm dawn palette)
struct FajrMountainsView: View {
    // Mountain colors - soft purple/mauve tones
    private let mountainBack = Color(hex: "C4B0D0")
    private let mountainMid = Color(hex: "B09DC4")
    private let mountainFront = Color(hex: "9D8AB5")

    // Sunrise colors
    private let sunriseGlow = Color(hex: "F6C177")
    private let sunriseRadiance = Color(hex: "FFD4A8")

    var body: some View {
        ZStack {
            // Sunrise glow at horizon (behind mountains)
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
                            startRadius: 10,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 200)
                    .offset(y: 60)
            }

            // Back layer (most distant, lightest)
            MountainShape(peaks: [0.2, 0.5, 0.8], heights: [0.35, 0.5, 0.3])
                .fill(mountainBack.opacity(0.5))
                .offset(y: 50)

            // Middle layer
            MountainShape(peaks: [0.15, 0.45, 0.75], heights: [0.45, 0.6, 0.38])
                .fill(mountainMid.opacity(0.65))
                .offset(y: 80)

            // Front layer (closest, most defined)
            MountainShape(peaks: [0.1, 0.4, 0.7, 0.9], heights: [0.4, 0.55, 0.65, 0.35])
                .fill(mountainFront.opacity(0.8))
                .offset(y: 110)

            // Additional warm glow overlay
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
    PledgeFlowScreen(
        onComplete: {},
        onBack: {}
    )
}
