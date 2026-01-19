//
//  SolutionsCarouselView.swift
//  Return
//
//  Onboarding Step 20: Solutions carousel showcasing app features
//

import SwiftUI
import Lottie

struct SolutionsCarouselView: View {
    var onComplete: () -> Void
    var onBack: () -> Void

    @State private var currentSlide: Int = 0
    @State private var showContent: Bool = false

    private let totalSlides = 6

    // Colors
    private let bgColor = Color(hex: "0A1628")
    private let warmAmber = Color(hex: "C4956A")
    private let starColor = Color(hex: "F59E0B")

    // Slide data (6 slides - benefit-focused like Unchaind/Quittr)
    private let slides: [SolutionSlide] = [
        // Slide 1: Welcome (like Quittr/Unchaind)
        SolutionSlide(
            title: "Welcome to Return",
            description: "Designed to help **Muslims** break free from porn and reconnect with **Allah**, Return combines science-backed methods with Islamic guidance.",
            lottieFile: "welcome_animation",
            sfSymbolFallback: "hands.sparkles.fill",
            accentColor: Color(hex: "C4956A") // Amber
        ),
        // Slide 2: Victory promise (like Unchaind's trophy)
        SolutionSlide(
            title: "Finally Break the Cycle",
            description: "The cycle of temptation, guilt, and shame ends here. Return helps you resist urges, stay accountable, and walk in **Allah's mercy**.",
            lottieFile: "trophy_animation",
            sfSymbolFallback: "trophy.fill",
            accentColor: Color(hex: "F59E0B") // Gold
        ),
        // Slide 3: Brain science (like Quittr)
        SolutionSlide(
            title: "Rewire Your Brain",
            description: "**Science-backed** exercises help you rewire your brain, rebuild your dopamine receptors, and **avoid setbacks**.",
            lottieFile: "brain_rewire_animation",
            sfSymbolFallback: "brain.head.profile",
            accentColor: Color(hex: "3B82F6") // Blue
        ),
        // Slide 4: Faith/Iman (like Unchaind's "Strengthen your spirit")
        SolutionSlide(
            title: "Strengthen Your Iman",
            description: "Porn separates you from Allah, but His **mercy** is greater. Restore your connection with daily **du'as** and spiritual practices.",
            lottieFile: "iman_animation",
            sfSymbolFallback: "moon.stars.fill",
            accentColor: Color(hex: "10B981") // Green
        ),
        // Slide 5: Stay motivated (like both apps)
        SolutionSlide(
            title: "Stay Motivated",
            description: "Each day you resist is a **victory**. Track your progress, build momentum, and stay committed to your **recovery**.",
            lottieFile: "progress_chart_animation",
            sfSymbolFallback: "chart.line.uptrend.xyaxis",
            accentColor: Color(hex: "5B9A9A") // Teal
        ),
        // Slide 6: Benefits/Level up (like Quittr's final slide)
        SolutionSlide(
            title: "Reclaim Your Life",
            description: "As you break free, your **mind** becomes sharper, your **focus** stronger. Expect your mood, energy, and connection with Allah to **flourish**.",
            lottieFile: "clapping_hands_animation",
            sfSymbolFallback: "hands.clap.fill",
            accentColor: Color(hex: "8B5CF6") // Purple
        )
    ]

    private var currentSlideData: SolutionSlide {
        slides[currentSlide]
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    bgColor,
                    bgColor.opacity(0.95),
                    currentSlideData.accentColor.opacity(0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentSlide)

            // Floating decorative elements
            FloatingStarsView(color: starColor)
                .opacity(showContent ? 0.6 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: showContent)

            VStack(spacing: 0) {
                // Back button (only on first slide)
                HStack {
                    if currentSlide == 0 {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .opacity(showContent ? 1 : 0)

                Spacer()

                // Main content
                VStack(spacing: 24) {
                    // Lottie animation
                    SolutionLottieView(
                        lottieFile: currentSlideData.lottieFile,
                        sfSymbol: currentSlideData.sfSymbolFallback,
                        accentColor: currentSlideData.accentColor,
                        size: 340
                    )
                    .frame(height: 280) // Fixed height so text doesn't move
                    .id("animation_\(currentSlide)")
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))

                    // Title
                    Text(currentSlideData.title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .id("title_\(currentSlide)")
                        .transition(.opacity)

                    // Description with bold words
                    MarkdownTextView(currentSlideData.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                        .id("desc_\(currentSlide)")
                        .transition(.opacity)
                }
                .animation(.easeInOut(duration: 0.35), value: currentSlide)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                Spacer()

                // Pagination dots (elongated current like Unchaind)
                HStack(spacing: 8) {
                    ForEach(0..<totalSlides, id: \.self) { index in
                        Capsule()
                            .fill(index == currentSlide ? warmAmber : Color.white.opacity(0.3))
                            .frame(width: index == currentSlide ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: currentSlide)
                    }
                }
                .padding(.bottom, 32)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)

                // Next / Let's Begin button
                Button(action: {
                    if currentSlide < totalSlides - 1 {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            currentSlide += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentSlide < totalSlides - 1 ? "Next" : "Let's Begin")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: currentSlide < totalSlides - 1 ? "chevron.right" : "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(bgColor)
                    .frame(width: currentSlide < totalSlides - 1 ? 120 : 160, height: 52)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                }
                .animation(.easeInOut(duration: 0.2), value: currentSlide)
                .padding(.bottom, 50)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Swipe left to go next
                    if value.translation.width < -50 && currentSlide < totalSlides - 1 {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            currentSlide += 1
                        }
                    }
                    // Swipe right to go back
                    if value.translation.width > 50 && currentSlide > 0 {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            currentSlide -= 1
                        }
                    }
                }
        )
    }
}

// MARK: - Solution Slide Data
struct SolutionSlide {
    let title: String
    let description: String
    let lottieFile: String
    let sfSymbolFallback: String
    let accentColor: Color
}

// MARK: - Floating Stars Background
struct FloatingStarsView: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Star positions - scattered across screen
                StarShape()
                    .fill(color)
                    .frame(width: 12, height: 12)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.18)

                StarShape()
                    .fill(color.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.22)

                StarShape()
                    .fill(color.opacity(0.8))
                    .frame(width: 10, height: 10)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.35)

                StarShape()
                    .fill(color.opacity(0.5))
                    .frame(width: 6, height: 6)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.4)

                StarShape()
                    .fill(color.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.55)

                // Crescent moon for Islamic touch
                Image(systemName: "moon.fill")
                    .font(.system(size: 14))
                    .foregroundColor(color.opacity(0.4))
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.65)
            }
        }
    }
}

// MARK: - 4-pointed Star Shape
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4

        for i in 0..<8 {
            let angle = Double(i) * .pi / 4 - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Solution Lottie View
struct SolutionLottieView: View {
    let lottieFile: String
    let sfSymbol: String
    let accentColor: Color
    let size: CGFloat

    @State private var isHovering: Bool = false

    // Files that should be frozen (not animated) with hover effect
    private let frozenFiles = ["clapping_hands_animation"]

    private var shouldFreeze: Bool {
        frozenFiles.contains(lottieFile)
    }

    var body: some View {
        Group {
            if LottieAnimation.named(lottieFile) != nil {
                // Lottie animation exists
                LottieView(animation: .named(lottieFile))
                    .playbackMode(shouldFreeze ? .paused(at: .progress(0.04)) : .playing(.toProgress(1, loopMode: .loop)))
                    .frame(width: size, height: size)
            } else {
                // SF Symbol fallback with accent color
                Image(systemName: sfSymbol)
                    .font(.system(size: size * 0.5))
                    .foregroundColor(accentColor)
                    .frame(width: size, height: size)
            }
        }
        .offset(y: isHovering ? -8 : 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isHovering = true
            }
        }
    }
}

// MARK: - Markdown Text View (reusable)
struct MarkdownTextView: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        formattedText
    }

    private var formattedText: Text {
        var result = Text("")
        var remaining = text

        while let startRange = remaining.range(of: "**") {
            let before = String(remaining[..<startRange.lowerBound])
            result = result + Text(before)

            let afterStart = remaining[startRange.upperBound...]
            if let endRange = afterStart.range(of: "**") {
                let boldText = String(afterStart[..<endRange.lowerBound])
                result = result + Text(boldText).fontWeight(.bold)
                remaining = String(afterStart[endRange.upperBound...])
            } else {
                remaining = String(remaining[startRange.upperBound...])
                break
            }
        }

        result = result + Text(remaining)
        return result
    }
}

#Preview {
    SolutionsCarouselView(onComplete: {}, onBack: {})
}
