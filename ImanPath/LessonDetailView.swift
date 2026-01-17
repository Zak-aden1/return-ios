//
//  LessonDetailView.swift
//  ImanPath
//
//  Reading view for a single lesson with beautiful typography
//

import SwiftUI

struct LessonDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let lesson: LessonContent
    let isCompleted: Bool
    let savedReflection: String?
    let onComplete: (String?) -> Void

    @State private var reflectionText: String = ""
    @State private var showReflectionInput: Bool = false
    @State private var hasMarkedComplete: Bool = false
    @State private var showConfetti: Bool = false
    @State private var pendingFocus: Bool = false
    @FocusState private var isReflectionFocused: Bool

    private let tealAccent = Color(hex: "5B9A9A")
    private let goldAccent = Color(hex: "E8B86D")

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                colors: [
                    Color(hex: "0A1628"),
                    Color(hex: "0A0E14"),
                    Color(hex: "080B0F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    // Progress dots
                    HStack(spacing: 6) {
                        ForEach(1...min(LessonContent.totalLessons, 10), id: \.self) { day in
                            Circle()
                                .fill(day == lesson.day ? tealAccent : Color(hex: "334155"))
                                .frame(width: day == lesson.day ? 8 : 6, height: day == lesson.day ? 8 : 6)
                        }
                        if LessonContent.totalLessons > 10 {
                            Text("...")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "64748B"))
                        }
                    }

                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color(hex: "1E293B")))
                        }
                        Spacer()

                        Text("Day \(lesson.day) of \(LessonContent.totalLessons)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "94A3B8"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Verse Card
                        VerseCard(
                            arabic: lesson.verse,
                            translation: lesson.verseTranslation,
                            reference: lesson.verseReference,
                            tealAccent: tealAccent
                        )
                        .padding(.horizontal, 20)

                        // Title Section
                        VStack(spacing: 8) {
                            Text(lesson.title.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .tracking(2)
                                .foregroundColor(tealAccent)

                            Text("Day \(lesson.day)")
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(.white)

                            // Read time
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                Text("\(lesson.readTimeMinutes) min read")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "64748B"))
                        }
                        .padding(.horizontal, 20)

                        // Divider
                        Rectangle()
                            .fill(Color(hex: "1E293B"))
                            .frame(height: 1)
                            .padding(.horizontal, 40)

                        // Main Content
                        Text(lesson.content)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "CBD5E1"))
                            .lineSpacing(8)
                            .padding(.horizontal, 24)

                        // Reflection Card
                        LessonReflectionCard(
                            question: lesson.reflection,
                            reflectionText: $reflectionText,
                            showInput: $showReflectionInput,
                            pendingFocus: $pendingFocus,
                            isReflectionFocused: $isReflectionFocused,
                            isCompleted: isCompleted || hasMarkedComplete,
                            hasSavedReflection: savedReflection != nil && !savedReflection!.isEmpty,
                            tealAccent: tealAccent,
                            goldAccent: goldAccent
                        )
                        .padding(.horizontal, 20)

                        // Complete Button
                        if !isCompleted && !hasMarkedComplete {
                            Button(action: completeLesson) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Mark as Complete")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [tealAccent, tealAccent.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: tealAccent.opacity(0.4), radius: 12, y: 4)
                                )
                            }
                            .padding(.horizontal, 20)
                        } else {
                            // Already completed state
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 18))
                                Text("Lesson Completed")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(tealAccent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(tealAccent.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(tealAccent.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
                .scrollDismissesKeyboard(.interactively)
            }

            // Confetti overlay
            if showConfetti {
                LessonConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tealAccent)
            }
        }
        .onAppear {
            // Load saved reflection if exists
            if let saved = savedReflection, !saved.isEmpty {
                reflectionText = saved
                showReflectionInput = true
            }
        }
        }
    }

    private func hideKeyboard() {
        isReflectionFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func completeLesson() {
        // Dismiss keyboard first
        hideKeyboard()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Mark complete immediately
        hasMarkedComplete = true
        let reflection = reflectionText.isEmpty ? nil : reflectionText
        onComplete(reflection)

        // Show confetti
        showConfetti = true

        // Hide confetti after animation completes (burst 0.4s + fall 2.0s + buffer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            showConfetti = false
        }
    }
}

// MARK: - Verse Card

struct VerseCard: View {
    let arabic: String
    let translation: String
    let reference: String
    let tealAccent: Color

    var body: some View {
        VStack(spacing: 16) {
            // Bismillah ornament
            Text("﷽")
                .font(.system(size: 24))
                .foregroundColor(tealAccent.opacity(0.6))

            // Arabic verse
            Text(arabic)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .environment(\.layoutDirection, .rightToLeft)

            // Divider
            Rectangle()
                .fill(tealAccent.opacity(0.3))
                .frame(width: 60, height: 2)

            // Translation
            Text("\"\(translation)\"")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(Color(hex: "94A3B8"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Reference
            Text("— \(reference)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(tealAccent)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            tealAccent.opacity(0.12),
                            tealAccent.opacity(0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(tealAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Reflection Card

struct LessonReflectionCard: View {
    let question: String
    @Binding var reflectionText: String
    @Binding var showInput: Bool
    @Binding var pendingFocus: Bool
    var isReflectionFocused: FocusState<Bool>.Binding
    let isCompleted: Bool
    let hasSavedReflection: Bool
    let tealAccent: Color
    let goldAccent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(goldAccent.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: hasSavedReflection ? "text.quote" : "thought.bubble.fill")
                        .font(.system(size: 16))
                        .foregroundColor(goldAccent)
                }

                Text(hasSavedReflection ? "YOUR REFLECTION" : "REFLECTION")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(goldAccent)
            }

            // Question
            Text(question)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)

            // Show saved reflection or input area
            if showInput {
                // Editable TextField
                TextField("Write your thoughts...", text: $reflectionText, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .lineLimit(4...10)
                    .focused(isReflectionFocused)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "0A1628"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isReflectionFocused.wrappedValue ? goldAccent.opacity(0.5) : Color(hex: "334155"),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .onAppear {
                        // Request focus only after TextField is in view hierarchy
                        if pendingFocus {
                            pendingFocus = false
                            isReflectionFocused.wrappedValue = true
                        }
                    }
            } else if hasSavedReflection && isCompleted {
                // Saved reflection - tappable to edit
                Button(action: {
                    pendingFocus = true
                    showInput = true
                }) {
                    Text(reflectionText)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "CBD5E1"))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "0A1628"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(tealAccent.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            } else if isCompleted {
                // Completed but no reflection saved
                Text("No reflection saved")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "64748B"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "0A1628"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "334155"), lineWidth: 1)
                            )
                    )
            } else {
                // Not completed - prompt to write
                Button(action: {
                    pendingFocus = true
                    showInput = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                        Text("Write your reflection...")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "64748B"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "0A1628"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "334155"), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(hasSavedReflection ? tealAccent.opacity(0.3) : goldAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Confetti View (Bursts up, then falls down)

struct LessonConfettiView: View {
    @State private var particles: [LessonConfettiParticle] = []

    private let colors: [Color] = [
        Color(hex: "5B9A9A"),  // Teal
        Color(hex: "E8B86D"),  // Gold
        Color(hex: "74B886"),  // Green
        Color(hex: "60A5FA"),  // Blue
        Color(hex: "F472B6"),  // Pink
        Color.white
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    LessonConfettiPiece(particle: particle, screenHeight: geo.size.height)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let centerX = size.width / 2
        let startY = size.height * 0.6  // Start from center-ish

        particles = (0..<50).map { _ in
            // Random horizontal spread
            let xSpread = CGFloat.random(in: -150...150)
            // How high it goes (negative = up)
            let peakHeight = CGFloat.random(in: 200...400)

            return LessonConfettiParticle(
                startX: centerX + CGFloat.random(in: -20...20),
                startY: startY,
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 8...14),
                rotation: Double.random(in: 0...360),
                xSpread: xSpread,
                peakHeight: peakHeight,
                delay: Double.random(in: 0...0.1)
            )
        }
    }
}

struct LessonConfettiParticle: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let color: Color
    let size: CGFloat
    let rotation: Double
    let xSpread: CGFloat
    let peakHeight: CGFloat
    let delay: Double
}

struct LessonConfettiPiece: View {
    let particle: LessonConfettiParticle
    let screenHeight: CGFloat

    @State private var phase: Int = 0  // 0 = start, 1 = peak, 2 = fallen
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var currentRotation: Double = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 0.6)
            .scaleEffect(scale)
            .rotationEffect(.degrees(currentRotation))
            .position(x: particle.startX + offsetX, y: particle.startY + offsetY)
            .opacity(opacity)
            .onAppear {
                // Phase 0 -> 1: Burst UP (fast)
                withAnimation(.easeOut(duration: 0.4).delay(particle.delay)) {
                    scale = 1
                    offsetX = particle.xSpread * 0.7
                    offsetY = -particle.peakHeight  // Go UP
                    currentRotation = particle.rotation + 360
                }

                // Phase 1 -> 2: Fall DOWN (slow, floaty)
                withAnimation(.easeIn(duration: 2.0).delay(particle.delay + 0.4)) {
                    offsetX = particle.xSpread
                    offsetY = screenHeight - particle.startY + 100  // Fall past bottom
                    currentRotation = particle.rotation + 720
                }

                // Fade out near end
                withAnimation(.easeIn(duration: 0.6).delay(particle.delay + 1.8)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    LessonDetailView(
        lesson: LessonContent.allLessons[0],
        isCompleted: false,
        savedReflection: nil,
        onComplete: { _ in }
    )
}
