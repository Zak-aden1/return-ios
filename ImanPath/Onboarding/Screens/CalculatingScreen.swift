//
//  CalculatingScreen.swift
//  ImanPath
//
//  Onboarding Step 16: Calculating animation before showing score
//

import SwiftUI

struct CalculatingScreen: View {
    var onComplete: () -> Void
    var onBack: () -> Void

    @State private var progress: CGFloat = 0
    @State private var currentPhase: Int = 0
    @State private var showContent: Bool = false

    private let warmAmber = Color(hex: "C4956A")
    private let mutedText = Color(hex: "8A9BAE")

    private let phases = [
        "Analyzing your answers...",
        "Understanding your journey...",
        "Calculating your dependence...",
        "Preparing your results..."
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Simple back button (no progress bar - quiz is done)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: showContent)

            Spacer()

            // Central content
            VStack(spacing: 40) {
                // Circular progress
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 12)
                        .frame(width: 180, height: 180)

                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [warmAmber, warmAmber.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))

                    // Percentage text
                    VStack(spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())

                        Text("Complete")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(mutedText)
                    }
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
                .animation(.easeOut(duration: 0.5), value: showContent)

                // Phase text
                VStack(spacing: 12) {
                    Text(phases[currentPhase])
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .id(currentPhase) // Force view refresh for animation
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))

                    // Animated dots
                    HStack(spacing: 6) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(warmAmber)
                                .frame(width: 8, height: 8)
                                .opacity(dotOpacity(for: index))
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            startAnimation()
        }
    }

    private func dotOpacity(for index: Int) -> Double {
        let baseDelay = Double(index) * 0.15
        let cycle = (progress * 10).truncatingRemainder(dividingBy: 1)
        let opacity = sin((cycle + baseDelay) * .pi * 2) * 0.5 + 0.5
        return max(0.3, opacity)
    }

    private func startAnimation() {
        // Animate progress from 0 to 1 over ~7.5 seconds
        let totalDuration: Double = 7.5
        let steps = 100
        let stepDuration = totalDuration / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                withAnimation(.easeInOut(duration: stepDuration)) {
                    progress = CGFloat(i) / CGFloat(steps)
                }

                // Update phase text at 25%, 50%, 75%
                let newPhase = min(Int(progress * 4), 3)
                if newPhase != currentPhase {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPhase = newPhase
                    }
                }

                // Complete - advance to next screen
                if i == steps {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()
        CalculatingScreen(onComplete: {}, onBack: {})
    }
}
