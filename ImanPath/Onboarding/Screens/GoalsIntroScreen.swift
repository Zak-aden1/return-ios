//
//  GoalsIntroScreen.swift
//  ImanPath
//
//  Onboarding: Transitional screen before goal selection
//  Reuses Welcome screen aesthetic with auto-advance
//

import SwiftUI

struct GoalsIntroScreen: View {
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var showContent: Bool = false
    @State private var mountainsOffset: CGFloat = 50
    @State private var glowPulse: Bool = false
    @State private var dotAnimation: Bool = false

    // Colors - Deep spiritual purple/navy palette (matching WelcomeScreen)
    private let bgTop = Color(hex: "1A1033")
    private let bgMid = Color(hex: "2D2456")
    private let bgLower = Color(hex: "4A3875")
    private let bgBottom = Color(hex: "6B4D8A")

    // Mountain colors
    private let mountainBack = Color(hex: "5D4A7A")
    private let mountainMid = Color(hex: "7B6399")
    private let mountainFront = Color(hex: "4A3B6B")

    // Accent colors
    private let sunriseGlow = Color(hex: "F6C177")
    private let sunrisePink = Color(hex: "E8A4B8")

    // Text colors
    private let textPrimary = Color.white
    private let textSecondary = Color(hex: "C4B5D4")

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [bgTop, bgMid, bgLower, bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Mountain scene at bottom
            VStack {
                Spacer()
                GoalsIntroMountainScene(
                    mountainBack: mountainBack,
                    mountainMid: mountainMid,
                    mountainFront: mountainFront,
                    sunriseGlow: sunriseGlow,
                    sunrisePink: sunrisePink,
                    glowPulse: glowPulse
                )
                .frame(height: 350)
                .offset(y: mountainsOffset)
            }
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                Spacer().frame(height: 120)

                // Mosque icon
                Text("🕌")
                    .font(.system(size: 60))
                    .shadow(color: sunriseGlow.opacity(0.5), radius: 20, x: 0, y: 5)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)

                Spacer().frame(height: 40)

                // Title
                Text("Every Journey\nBegins with Goals")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(textPrimary)
                    .multilineTextAlignment(.center)
                    .shadow(color: sunriseGlow.opacity(0.3), radius: 10, x: 0, y: 4)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)

                Spacer().frame(height: 16)

                // Subtitle
                Text("Let's set yours together")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(textSecondary)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)

                Spacer().frame(height: 24)

                // Loading dots - right below subtitle
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(sunriseGlow)
                            .frame(width: 8, height: 8)
                            .scaleEffect(dotAnimation ? 1.0 : 0.6)
                            .opacity(dotAnimation ? 1.0 : 0.4)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: dotAnimation
                            )
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.8), value: showContent)

                Spacer()
            }
        }
        .onAppear {
            // Animate in
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
                mountainsOffset = 0
            }

            // Start glow pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }

            // Start dot animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                dotAnimation = true
            }

            // Auto-advance after 3.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                onContinue()
            }
        }
    }
}

// MARK: - Mountain Scene (matching WelcomeScreen)
private struct GoalsIntroMountainScene: View {
    let mountainBack: Color
    let mountainMid: Color
    let mountainFront: Color
    let sunriseGlow: Color
    let sunrisePink: Color
    let glowPulse: Bool

    var body: some View {
        ZStack {
            // Sunrise glow at horizon
            VStack {
                Spacer()

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                sunriseGlow.opacity(glowPulse ? 0.8 : 0.6),
                                sunrisePink.opacity(glowPulse ? 0.5 : 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 200
                        )
                    )
                    .frame(width: 450, height: 250)
                    .offset(y: 100)
            }

            // Back mountain layer
            GoalsIntroMountainShape(peaks: [0.15, 0.4, 0.65, 0.9], heights: [0.25, 0.4, 0.35, 0.2])
                .fill(
                    LinearGradient(
                        colors: [mountainBack.opacity(0.6), mountainBack.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: 40)

            // Mid mountain layer
            GoalsIntroMountainShape(peaks: [0.1, 0.35, 0.6, 0.85], heights: [0.35, 0.55, 0.45, 0.3])
                .fill(
                    LinearGradient(
                        colors: [mountainMid.opacity(0.7), mountainMid.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: 80)

            // Front mountain layer
            GoalsIntroMountainShape(peaks: [0.05, 0.3, 0.55, 0.8, 0.95], heights: [0.3, 0.5, 0.65, 0.45, 0.25])
                .fill(
                    LinearGradient(
                        colors: [mountainFront.opacity(0.9), mountainFront.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: 130)

            // Warm overlay gradient at bottom
            LinearGradient(
                colors: [
                    Color.clear,
                    sunriseGlow.opacity(0.15),
                    sunriseGlow.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .offset(y: 100)
        }
    }
}

// MARK: - Mountain Shape
private struct GoalsIntroMountainShape: Shape {
    let peaks: [Double]
    let heights: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * (1 - heights[0] * 0.3)))

        for i in 0..<peaks.count {
            let peakX = width * peaks[i]
            let peakY = height * (1 - heights[i])

            if i > 0 {
                let prevPeakX = width * peaks[i - 1]
                let controlX = (prevPeakX + peakX) / 2
                path.addQuadCurve(
                    to: CGPoint(x: peakX, y: peakY),
                    control: CGPoint(x: controlX, y: peakY + 20)
                )
            } else {
                path.addLine(to: CGPoint(x: peakX, y: peakY))
            }
        }

        path.addLine(to: CGPoint(x: width, y: height * 0.7))
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    GoalsIntroScreen(
        onContinue: {},
        onBack: {}
    )
}
