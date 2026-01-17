//
//  CommitmentCongratulationsScreen.swift
//  ImanPath
//
//  Onboarding Step 27: Congratulations after commitment
//  Celebrates the user's niyyah with warm, hopeful Islamic messaging
//

import SwiftUI

struct CommitmentCongratulationsScreen: View {
    let userName: String
    var onContinue: () -> Void

    @State private var showContent: Bool = false
    @State private var mosqueScale: CGFloat = 0.3
    @State private var mosqueOpacity: Double = 0
    @State private var glowPulse: Bool = false
    @State private var floatOffset: CGFloat = 0

    // Colors - Fajr Dawn palette (matching PledgeFlowScreen)
    private let bgTop = Color(hex: "FDF8F5")         // Warm ivory
    private let bgUpperMid = Color(hex: "F7EDE8")    // Soft blush
    private let bgLowerMid = Color(hex: "EBE0E8")    // Dusty rose
    private let bgBottom = Color(hex: "DED0E0")      // Soft mauve

    private let sunriseGlow = Color(hex: "F6C177")   // Warm amber
    private let accentViolet = Color(hex: "7B5E99")  // Rich violet

    private let textHeading = Color(hex: "2D2438")   // Deep plum
    private let textBody = Color(hex: "5A4A66")      // Muted plum

    var body: some View {
        ZStack {
            // Gradient background
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
                CongratsMountainsView()
                    .frame(height: 320)
            }
            .ignoresSafeArea()

            // Radial glow behind mosque
            RadialGradient(
                colors: [
                    sunriseGlow.opacity(glowPulse ? 0.4 : 0.25),
                    sunriseGlow.opacity(glowPulse ? 0.2 : 0.1),
                    Color.clear
                ],
                center: .center,
                startRadius: 30,
                endRadius: 200
            )
            .frame(width: 400, height: 400)
            .offset(y: -60)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)

            VStack(spacing: 0) {
                Spacer()

                // Mosque emoji with animation
                Text("🕌")
                    .font(.system(size: 100))
                    .scaleEffect(mosqueScale)
                    .opacity(mosqueOpacity)
                    .offset(y: floatOffset)
                    .shadow(color: sunriseGlow.opacity(0.3), radius: 20, x: 0, y: 10)

                Spacer().frame(height: 40)

                // MashaAllah heading
                Text("MashaAllah!")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(textHeading)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)

                Spacer().frame(height: 16)

                // Main message
                Text("You've taken a powerful first step.\nAllah sees your niyyah and is\nwith you on this journey.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textBody)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)

                Spacer().frame(height: 24)

                // Hadith quote
                VStack(spacing: 8) {
                    Text("\"Whoever intends to do a good deed but does not do it, Allah records it as a complete good deed.\"")
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(textBody.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text("— Sahih Bukhari")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(accentViolet)
                }
                .padding(.horizontal, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 10)
                .animation(.easeOut(duration: 0.5).delay(0.8), value: showContent)

                Spacer()

                // Continue button
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Continue Your Journey")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(accentViolet)
                            .shadow(color: accentViolet.opacity(0.3), radius: 12, x: 0, y: 6)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(1.0), value: showContent)
            }
        }
        .onAppear {
            // Mosque entrance animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                mosqueScale = 1.0
                mosqueOpacity = 1.0
            }

            // Start floating animation
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatOffset = -8
            }

            // Start glow pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                glowPulse = true
            }

            // Show content
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Congrats Mountains View (same Fajr palette)
struct CongratsMountainsView: View {
    // Mountain colors - soft purple/mauve tones
    private let mountainBack = Color(hex: "C4B0D0")
    private let mountainMid = Color(hex: "B09DC4")
    private let mountainFront = Color(hex: "9D8AB5")

    // Sunrise colors
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
                                sunriseRadiance.opacity(0.7),
                                sunriseGlow.opacity(0.5),
                                sunriseGlow.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 220)
                    .offset(y: 80)
            }

            // Back layer
            MountainShape(peaks: [0.2, 0.5, 0.8], heights: [0.35, 0.5, 0.3])
                .fill(mountainBack.opacity(0.5))
                .offset(y: 60)

            // Middle layer
            MountainShape(peaks: [0.15, 0.45, 0.75], heights: [0.45, 0.6, 0.38])
                .fill(mountainMid.opacity(0.65))
                .offset(y: 100)

            // Front layer
            MountainShape(peaks: [0.1, 0.4, 0.7, 0.9], heights: [0.4, 0.55, 0.65, 0.35])
                .fill(mountainFront.opacity(0.8))
                .offset(y: 140)

            // Warm glow overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    sunriseGlow.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .offset(y: 120)
        }
    }
}

#Preview {
    CommitmentCongratulationsScreen(
        userName: "Zak",
        onContinue: {}
    )
}
