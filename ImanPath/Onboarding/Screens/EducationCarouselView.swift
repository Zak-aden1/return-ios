//
//  EducationCarouselView.swift
//  ImanPath
//
//  Onboarding: 4 pain screens + 1 hope screen education carousel
//

import SwiftUI
import Lottie

struct EducationCarouselView: View {
    var onComplete: () -> Void
    var onBack: () -> Void

    @State private var currentSlide: Int = 0
    @State private var showContent: Bool = false

    private let totalSlides = 5

    // Pain slides (red background)
    private let painSlides: [EducationSlide] = [
        EducationSlide(
            title: "Porn rewires your brain",
            description: "Using porn releases a chemical in the brain called **dopamine**. This chemical makes you **feel good** — it's why you feel pleasure when you **watch porn**.",
            lottieFile: "brain_animation", // Add to project later
            sfSymbolFallback: "brain.head.profile",
            backgroundColor: Color(hex: "DC2626")
        ),
        EducationSlide(
            title: "Porn destroys relationships",
            description: "Porn **reduces** your hunger for a **real relationship** and replaces it with the hunger for more porn.",
            lottieFile: "heart_broken_animation",
            sfSymbolFallback: "heart.slash.fill",
            backgroundColor: Color(hex: "DC2626")
        ),
        EducationSlide(
            title: "Porn dims your iman",
            description: "Porn doesn't just affect your mind. It numbs your **soul**. It makes **salah** feel harder, **du'a** feel distant, and **iman** feel low.",
            lottieFile: "faith_animation",
            sfSymbolFallback: "moon.stars.fill",
            backgroundColor: Color(hex: "DC2626"),
            quranVerse: "No one guards his private parts except the believers",
            quranReference: "Qur'an 70:29-30"
        ),
        EducationSlide(
            title: "Allah sees, yet offers mercy",
            description: "Even when no one sees, **Allah does**. Yet, He still offers you **mercy**, every time you turn back.",
            lottieFile: "mercy_animation",
            sfSymbolFallback: "eye.fill",
            backgroundColor: Color(hex: "DC2626"),
            quranVerse: "He knows the secret and what is even more hidden",
            quranReference: "Qur'an 20:7"
        )
    ]

    // Hope slide (different color - our amber/green)
    private let hopeSlide = EducationSlide(
        title: "There is a way out",
        description: "Recovery is possible. By **abstaining from porn**, your brain can **reset its dopamine sensitivity**, leading to healthier relationships and **improved well-being**.",
        lottieFile: "plant_growing_animation",
        sfSymbolFallback: "leaf.fill",
        backgroundColor: Color(hex: "065F46") // Dark green for hope
    )

    private var allSlides: [EducationSlide] {
        painSlides + [hopeSlide]
    }

    private var currentSlideData: EducationSlide {
        allSlides[currentSlide]
    }

    var body: some View {
        ZStack {
            // Background color changes based on slide
            currentSlideData.backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: currentSlide)

            VStack(spacing: 0) {
                // Back button (only on first slide)
                HStack {
                    if currentSlide == 0 {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.15)))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .opacity(showContent ? 1 : 0)

                Spacer()

                // Slide content
                VStack(spacing: 20) {
                    // Lottie or SF Symbol (always show)
                    LottieOrSymbolView(
                        lottieFile: currentSlideData.lottieFile,
                        sfSymbol: currentSlideData.sfSymbolFallback,
                        size: 180
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

                    // Title
                    Text(currentSlideData.title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .id("title_\(currentSlide)")
                        .transition(.opacity)

                    // Description with bold words
                    MarkdownText(currentSlideData.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .id("desc_\(currentSlide)")
                        .transition(.opacity)

                    // Quran verse (if present) - shown below description
                    if let verse = currentSlideData.quranVerse,
                       let reference = currentSlideData.quranReference {
                        VStack(spacing: 6) {
                            Text("\"" + verse + "\"")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .italic()
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                            Text(reference)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 32)
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentSlide)

                Spacer()

                // Pagination dots
                HStack(spacing: 8) {
                    ForEach(0..<totalSlides, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentSlide)
                    }
                }
                .padding(.bottom, 24)
                .opacity(showContent ? 1 : 0)

                // Next button
                Button(action: {
                    if currentSlide < totalSlides - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentSlide += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentSlide < totalSlides - 1 ? "Next" : "Continue")
                            .font(.system(size: 17, weight: .semibold))

                        if currentSlide < totalSlides - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(currentSlideData.backgroundColor)
                    .frame(width: 160, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.white)
                    )
                }
                .padding(.bottom, 50)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Swipe left to go next
                    if value.translation.width < -50 && currentSlide < totalSlides - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentSlide += 1
                        }
                    }
                    // Swipe right to go back
                    if value.translation.width > 50 && currentSlide > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentSlide -= 1
                        }
                    }
                }
        )
    }
}

// MARK: - Education Slide Data
struct EducationSlide {
    let title: String
    let description: String
    let lottieFile: String
    let sfSymbolFallback: String
    let backgroundColor: Color
    var quranVerse: String? = nil
    var quranReference: String? = nil
}

// MARK: - Quran Verse Card (Islamic arch design)
struct QuranVerseCard: View {
    let verse: String
    let reference: String

    var body: some View {
        VStack(spacing: 16) {
            // Crescent moon icon
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "F59E0B"))

            // Verse text
            Text(verse)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Reference
            Text(reference)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "92400E"), Color(hex: "78350F")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "F59E0B").opacity(0.5), lineWidth: 2)
                )
        )
    }
}

// MARK: - Lottie or SF Symbol View
struct LottieOrSymbolView: View {
    let lottieFile: String
    let sfSymbol: String
    let size: CGFloat

    @State private var useFallback: Bool = false

    var body: some View {
        ZStack {
            // Light backdrop circle for contrast
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: size + 60, height: size + 60)

            Group {
                if useFallback {
                    // SF Symbol fallback
                    Image(systemName: sfSymbol)
                        .font(.system(size: size * 0.6))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: size, height: size)
                } else {
                    // Try Lottie animation
                    LottieView(animation: .named(lottieFile))
                        .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                        .frame(width: size, height: size)
                        .onAppear {
                            // Check if animation exists, if not use fallback
                            if LottieAnimation.named(lottieFile) == nil {
                                useFallback = true
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Markdown-style Text (bold words between **)
struct MarkdownText: View {
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
            // Add text before **
            let before = String(remaining[..<startRange.lowerBound])
            result = result + Text(before)

            // Find closing **
            let afterStart = remaining[startRange.upperBound...]
            if let endRange = afterStart.range(of: "**") {
                let boldText = String(afterStart[..<endRange.lowerBound])
                result = result + Text(boldText).fontWeight(.bold)
                remaining = String(afterStart[endRange.upperBound...])
            } else {
                // No closing **, just add the rest
                remaining = String(remaining[startRange.upperBound...])
                break
            }
        }

        // Add any remaining text
        result = result + Text(remaining)
        return result
    }
}

#Preview {
    EducationCarouselView(onComplete: {}, onBack: {})
}
