//
//  CommitmentIntroScreen.swift
//  ImanPath
//
//  Onboarding Step 24: Personalized commitment intro
//  "[Name], Today is a new beginning"
//

import SwiftUI

struct CommitmentIntroScreen: View {
    let userName: String
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var showContent: Bool = false
    @State private var isHovering: Bool = false

    // Colors
    private let topColor = Color(hex: "1A1A2E")
    private let midColor = Color(hex: "16213E")
    private let bottomColor = Color(hex: "0F3460")
    private let accentPurple = Color(hex: "533483")

    var body: some View {
        ZStack {
            // Gradient background with purple tones
            LinearGradient(
                colors: [
                    topColor,
                    midColor,
                    accentPurple.opacity(0.6),
                    bottomColor
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Mountain layers at bottom
            VStack {
                Spacer()
                MountainLayersView()
                    .frame(height: 280)
            }
            .ignoresSafeArea()

            // Soft glow behind hands
            VStack {
                Spacer()
                RadialGradient(
                    colors: [
                        Color(hex: "F59E0B").opacity(0.15),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 200
                )
                .frame(width: 400, height: 400)
                .offset(y: 100)
            }

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

                // Top icon (crescent moon and star - Islamic symbol)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 24)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                // Personalized title
                Text("\(userName), Today is a\nnew beginning")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                // Subtitle
                Text("Freedom starts with a choice. Today, you make a commitment to yourself and Allah to break free from porn and temptation.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                Spacer()

                // Du'a hands (Islamic supplication gesture)
                Text("🤲")
                    .font(.system(size: 120))
                    .offset(y: isHovering ? -8 : 8)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isHovering
                    )
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)

                Spacer()

                // CTA Button
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Make Your Niyyah")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "0A1628"))
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
                .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)
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

// MARK: - Mountain Layers View
struct MountainLayersView: View {
    var body: some View {
        ZStack {
            // Back mountain layer (darkest)
            MountainShape(peaks: [0.3, 0.5, 0.7], heights: [0.4, 0.6, 0.35])
                .fill(Color(hex: "1A1A2E").opacity(0.8))
                .offset(y: 40)

            // Middle mountain layer
            MountainShape(peaks: [0.2, 0.45, 0.75], heights: [0.5, 0.7, 0.45])
                .fill(Color(hex: "2D2D44").opacity(0.7))
                .offset(y: 80)

            // Front mountain layer (lightest)
            MountainShape(peaks: [0.15, 0.5, 0.85], heights: [0.55, 0.75, 0.5])
                .fill(Color(hex: "3D3D5C").opacity(0.6))
                .offset(y: 120)

            // Sunrise glow at horizon
            LinearGradient(
                colors: [
                    Color(hex: "F59E0B").opacity(0.3),
                    Color(hex: "F59E0B").opacity(0.1),
                    Color.clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 150)
            .offset(y: 130)
        }
    }
}

// MARK: - Mountain Shape
struct MountainShape: Shape {
    let peaks: [CGFloat] // X positions (0-1)
    let heights: [CGFloat] // Heights (0-1)

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.height))

        // Start from bottom left
        path.addLine(to: CGPoint(x: 0, y: rect.height * (1 - heights[0] * 0.5)))

        // Create mountain peaks with curves
        for i in 0..<peaks.count {
            let peakX = rect.width * peaks[i]
            let peakY = rect.height * (1 - heights[i])

            let prevX = i == 0 ? 0 : rect.width * peaks[i-1]
            let controlX1 = prevX + (peakX - prevX) * 0.5
            let controlX2 = peakX - (peakX - prevX) * 0.3

            path.addCurve(
                to: CGPoint(x: peakX, y: peakY),
                control1: CGPoint(x: controlX1, y: path.currentPoint!.y),
                control2: CGPoint(x: controlX2, y: peakY + 20)
            )

            // Down slope
            if i < peaks.count - 1 {
                let nextX = rect.width * peaks[i+1]
                let valleyY = rect.height * (1 - heights[i] * 0.6)
                let midX = peakX + (nextX - peakX) * 0.5

                path.addCurve(
                    to: CGPoint(x: midX, y: valleyY),
                    control1: CGPoint(x: peakX + 30, y: peakY + 10),
                    control2: CGPoint(x: midX - 20, y: valleyY)
                )
            }
        }

        // End at bottom right
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.6))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    CommitmentIntroScreen(
        userName: "Zak",
        onContinue: {},
        onBack: {}
    )
}
