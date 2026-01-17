//
//  GoalsIntroScreen.swift
//  ImanPath
//
//  Onboarding Step 22: Goals intro screen before goal selection
//

import SwiftUI
import Lottie

struct GoalsIntroScreen: View {
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var showContent: Bool = false
    @State private var isHovering: Bool = false

    // Colors
    private let bgColor = Color(hex: "0A1628")
    private let warmAmber = Color(hex: "C4956A")
    private let mutedText = Color(hex: "8A9BAE")

    var body: some View {
        ZStack {
            // Background
            bgColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
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
                .padding(.top, 12)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: showContent)

                Spacer()

                // Main content - centered
                VStack(spacing: 24) {
                    // Target/Goal animation
                    GoalTargetView(size: 160)
                        .offset(y: isHovering ? -6 : 6)
                        .animation(
                            .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                            value: isHovering
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    // Title
                    Text("Every Journey\nBegins with Goals")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Subtitle
                    Text("Let's start by setting yours")
                        .font(.system(size: 17))
                        .foregroundColor(mutedText)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                }

                Spacer()

                // Continue button
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(bgColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            isHovering = true
        }
    }
}

// MARK: - Goal Target View (Lottie or SF Symbol fallback)
struct GoalTargetView: View {
    let size: CGFloat

    @State private var useFallback: Bool = false

    var body: some View {
        Group {
            if useFallback {
                // SF Symbol fallback - target/bullseye
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: size + 40, height: size + 40)

                    Image(systemName: "target")
                        .font(.system(size: size * 0.6))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
            } else {
                // Try Lottie animation
                LottieView(animation: .named("target_animation"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                    .frame(width: size, height: size)
                    .onAppear {
                        if LottieAnimation.named("target_animation") == nil {
                            useFallback = true
                        }
                    }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    GoalsIntroScreen(
        onContinue: {},
        onBack: {}
    )
}
