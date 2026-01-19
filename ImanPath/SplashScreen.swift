//
//  SplashScreen.swift
//  ImanPath
//
//  Splash screen with Quranic verse - first impression
//

import SwiftUI

struct SplashScreen: View {
    @State private var showContent = false
    @State private var starOpacity: [Double] = Array(repeating: 0.0, count: 20)

    var onComplete: () -> Void

    // Night sky palette
    private let bgTop = Color(hex: "0A1628")
    private let bgBottom = Color(hex: "0F1D32")
    private let textMuted = Color(hex: "8A9BAE")

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [bgTop, bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle stars
            GeometryReader { geo in
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: starSize(for: i), height: starSize(for: i))
                        .position(starPosition(for: i, in: geo.size))
                        .opacity(starOpacity[i])
                }
            }
            .ignoresSafeArea()

            // Subtle white glow behind logo - barely perceptible
            RadialGradient(
                colors: [
                    Color.white.opacity(0.06),
                    Color.white.opacity(0.02),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 120
            )
            .offset(y: -40)
            .ignoresSafeArea()

            // Content - tighter spacing
            VStack(spacing: 40) {
                // Logo
                Image("ReturnLogo")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
                    .foregroundColor(.white)

                // Verse + Reference grouped
                VStack(spacing: 12) {
                    Text("Allah does not burden a soul\nbeyond what it can bear.")
                        .font(.system(size: 18, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)

                    Text("Surah Al-Baqarah · 2:286")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(textMuted.opacity(0.8))
                        .tracking(0.5)
                }

                // Loading dots - subtle pulse, neutral color
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 5, height: 5)
                            .opacity(showContent ? 0.6 : 0.25)
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: showContent
                            )
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 15)
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    // Star helpers
    private func starSize(for index: Int) -> CGFloat {
        let sizes: [CGFloat] = [1.5, 2, 1, 2.5, 1.5, 2, 1, 1.5, 2, 1]
        return sizes[index % sizes.count]
    }

    private func starPosition(for index: Int, in size: CGSize) -> CGPoint {
        // Pseudo-random but deterministic positions
        let positions: [(CGFloat, CGFloat)] = [
            (0.1, 0.15), (0.85, 0.1), (0.2, 0.3), (0.75, 0.25),
            (0.15, 0.5), (0.9, 0.45), (0.3, 0.7), (0.8, 0.65),
            (0.05, 0.8), (0.95, 0.75), (0.4, 0.12), (0.6, 0.2),
            (0.25, 0.88), (0.7, 0.85), (0.5, 0.08), (0.35, 0.4),
            (0.65, 0.55), (0.12, 0.65), (0.88, 0.35), (0.45, 0.92)
        ]
        let pos = positions[index % positions.count]
        return CGPoint(x: size.width * pos.0, y: size.height * pos.1)
    }

    private func startAnimationSequence() {
        // Animate stars twinkling
        for i in 0..<20 {
            let delay = Double.random(in: 0...1.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: Double.random(in: 1.5...3.0)).repeatForever(autoreverses: true)) {
                    starOpacity[i] = Double.random(in: 0.2...0.5)
                }
            }
        }

        // Content fades in together
        withAnimation(.easeOut(duration: 0.8)) {
            showContent = true
        }

        // Complete and transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            onComplete()
        }
    }
}


#Preview {
    SplashScreen(onComplete: {})
}
