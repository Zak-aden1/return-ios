//
//  WelcomeScreen.swift
//  Return
//
//  Onboarding Step 1: Welcome
//  Inspired by Unchaind's welcome screen with Islamic framing
//

import SwiftUI
import UIKit

struct WelcomeScreen: View {
    var onContinue: () -> Void
    @State private var showContent: Bool = false
    @State private var mountainsOffset: CGFloat = 50
    @State private var glowPulse: Bool = false

    // Colors - Deep spiritual purple/navy palette
    private let bgTop = Color(hex: "1A1033")          // Deep purple-black
    private let bgMid = Color(hex: "2D2456")          // Rich purple
    private let bgLower = Color(hex: "4A3875")        // Lighter purple
    private let bgBottom = Color(hex: "6B4D8A")       // Mauve purple

    // Mountain colors
    private let mountainBack = Color(hex: "5D4A7A")   // Distant purple
    private let mountainMid = Color(hex: "7B6399")    // Mid purple
    private let mountainFront = Color(hex: "4A3B6B")  // Front darker purple

    // Accent colors
    private let sunriseGlow = Color(hex: "F6C177")    // Warm amber/gold
    private let sunrisePink = Color(hex: "E8A4B8")    // Soft pink

    // Text colors
    private let textPrimary = Color.white
    private let textSecondary = Color(hex: "C4B5D4")  // Soft lavender
    private let textMuted = Color(hex: "9A8AAE")      // Muted purple

    // Pill background
    private let pillBg = Color(hex: "3D2D5C").opacity(0.85)

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
                WelcomeMountainScene(
                    mountainBack: mountainBack,
                    mountainMid: mountainMid,
                    mountainFront: mountainFront,
                    sunriseGlow: sunriseGlow,
                    sunrisePink: sunrisePink,
                    glowPulse: glowPulse
                )
                .frame(height: 380)
                .offset(y: mountainsOffset)
            }
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                Spacer().frame(height: 80)

                // Mosque icon
                Text("🕌")
                    .font(.system(size: 50))
                    .shadow(color: sunriseGlow.opacity(0.5), radius: 20, x: 0, y: 5)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)

                Spacer().frame(height: 32)

                // Welcome text
                Text("Welcome to")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(textSecondary)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)

                // App name - Hero text
                Text("Return")
                    .font(.system(size: 52, weight: .bold, design: .serif))
                    .foregroundColor(textPrimary)
                    .shadow(color: sunriseGlow.opacity(0.3), radius: 10, x: 0, y: 2)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)

                Spacer().frame(height: 20)

                // Subtitle
                Text("Allah has given you the strength to\novercome this struggle.\nWe are here to help you.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.7), value: showContent)

                Spacer()

                // Benefit pills
                VStack(spacing: 12) {
                    BenefitPill(emoji: "🌙", text: "Quit Porn with Iman", bgColor: pillBg)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.9), value: showContent)

                    BenefitPill(emoji: "❤️", text: "Strengthen Your Deen", bgColor: pillBg)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(1.0), value: showContent)

                    BenefitPill(emoji: "📿", text: "Get Personalized Guidance", bgColor: pillBg)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(1.1), value: showContent)
                }
                .padding(.horizontal, 40)

                Spacer().frame(height: 32)

                // CTA Button - White/cream style
                Button(action: {
                    triggerHaptic(.medium)
                    onContinue()
                }) {
                    HStack(spacing: 8) {
                        Text("Start Quiz")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "1A1033"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                    )
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(1.2), value: showContent)

                // Footer text
                Text("Let's understand your current situation")
                    .font(.system(size: 14))
                    .foregroundColor(textMuted)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(1.4), value: showContent)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
                mountainsOffset = 0
            }

            // Start glow pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Benefit Pill
private struct BenefitPill: View {
    let emoji: String
    let text: String
    let bgColor: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 18))
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(bgColor)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Welcome Mountain Scene
private struct WelcomeMountainScene: View {
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

                // Warm glow ellipse
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
            WelcomeMountainShape(peaks: [0.15, 0.4, 0.65, 0.9], heights: [0.25, 0.4, 0.35, 0.2])
                .fill(
                    LinearGradient(
                        colors: [mountainBack.opacity(0.6), mountainBack.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: 40)

            // Mid mountain layer
            WelcomeMountainShape(peaks: [0.1, 0.35, 0.6, 0.85], heights: [0.35, 0.55, 0.45, 0.3])
                .fill(
                    LinearGradient(
                        colors: [mountainMid.opacity(0.7), mountainMid.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: 80)

            // Front mountain layer
            WelcomeMountainShape(peaks: [0.05, 0.3, 0.55, 0.8, 0.95], heights: [0.3, 0.5, 0.65, 0.45, 0.25])
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

// MARK: - Welcome Mountain Shape
private struct WelcomeMountainShape: Shape {
    let peaks: [Double]
    let heights: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))

        // Start from bottom left
        path.addLine(to: CGPoint(x: 0, y: height * (1 - heights[0] * 0.3)))

        // Create mountain peaks
        for i in 0..<peaks.count {
            let peakX = width * peaks[i]
            let peakY = height * (1 - heights[i])

            // Create smooth curves between peaks
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

        // End at bottom right
        path.addLine(to: CGPoint(x: width, y: height * 0.7))
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    WelcomeScreen(onContinue: {})
}
