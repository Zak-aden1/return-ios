//
//  MilestoneCelebrationView.swift
//  ImanPath
//
//  Two-phase celebration: Unlock animation -> Details page
//

import SwiftUI

// MARK: - Confetti Particle
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    let rotation: Double
    let rotationSpeed: Double
    let xVelocity: CGFloat
    let yVelocity: CGFloat
    let shape: ConfettiShape

    enum ConfettiShape {
        case circle, rectangle, star
    }
}

// MARK: - Celebration Data
struct CelebrationMilestone {
    let day: Int
    let title: String
    let islamicName: String
    let meaning: String
    let verse: String?
    let verseReference: String?
    let badgeIcon: String
    let badgeColors: [Color]
}

// MARK: - Celebration Phase
enum CelebrationPhase {
    case unlock      // Semi-transparent with lock animation
    case details     // Solid background with full details
}

// MARK: - Main Celebration View
struct MilestoneCelebrationView: View {
    let milestone: CelebrationMilestone
    let onDismiss: () -> Void

    @State private var phase: CelebrationPhase = .unlock

    var body: some View {
        ZStack {
            switch phase {
            case .unlock:
                UnlockAnimationView(
                    milestone: milestone,
                    onComplete: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            phase = .details
                        }
                    }
                )

            case .details:
                MilestoneDetailsView(
                    milestone: milestone,
                    onDismiss: onDismiss
                )
            }
        }
    }
}

// MARK: - Phase 1: Unlock Animation
struct UnlockAnimationView: View {
    let milestone: CelebrationMilestone
    let onComplete: () -> Void

    @State private var showOverlay: Bool = false
    @State private var lockScale: CGFloat = 0.5
    @State private var lockOpacity: Double = 0
    @State private var isUnlocking: Bool = false
    @State private var shackleOffset: CGFloat = 0
    @State private var shackleRotation: Double = 0
    @State private var showSparkles: Bool = false
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var particleTimer: Timer?
    @State private var hasStarted: Bool = false

    private let confettiColors: [Color] = [
        Color(hex: "74B886"),
        Color(hex: "E8B86D"),
        Color(hex: "60A5FA"),
        Color(hex: "F472B6"),
        Color(hex: "FBBF24"),
        Color(hex: "A78BDA"),
        Color(hex: "5B9A9A"),
    ]

    var body: some View {
        ZStack {
            // Semi-transparent dark overlay - can see through
            Color.black
                .opacity(showOverlay ? 0.7 : 0)
                .ignoresSafeArea()

            // Confetti layer
            ForEach(confettiParticles) { particle in
                ConfettiView(particle: particle)
            }

            // Lock animation
            VStack(spacing: 24) {
                ZStack {
                    // Glow behind lock
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [milestone.badgeColors[0].opacity(0.4), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .opacity(showSparkles ? 1 : 0)

                    // Lock body
                    ZStack {
                        // Shackle (top part that opens)
                        ShackleShape()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "94A3B8"), Color(hex: "64748B")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .frame(width: 60, height: 50)
                            .offset(y: -55 + shackleOffset)
                            .rotationEffect(.degrees(shackleRotation), anchor: .bottomTrailing)

                        // Lock body
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: milestone.badgeColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 80)
                            .overlay(
                                // Keyhole
                                VStack(spacing: 0) {
                                    Circle()
                                        .fill(Color(hex: "1E293B"))
                                        .frame(width: 20, height: 20)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "1E293B"))
                                        .frame(width: 12, height: 20)
                                        .offset(y: -4)
                                }
                            )
                            .shadow(color: milestone.badgeColors[0].opacity(0.5), radius: 20)
                    }

                    // Sparkle particles when unlocked
                    if showSparkles {
                        ForEach(0..<8, id: \.self) { i in
                            Image(systemName: "sparkle")
                                .font(.system(size: CGFloat.random(in: 12...24)))
                                .foregroundColor(milestone.badgeColors[i % 2])
                                .offset(
                                    x: cos(Double(i) * .pi / 4) * 80,
                                    y: sin(Double(i) * .pi / 4) * 80
                                )
                                .opacity(showSparkles ? 1 : 0)
                                .scaleEffect(showSparkles ? 1 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(i) * 0.05),
                                    value: showSparkles
                                )
                        }
                    }
                }
                .scaleEffect(lockScale)
                .opacity(lockOpacity)

                // "Tap to unlock" or milestone name
                Text(isUnlocking ? milestone.islamicName : "Milestone Unlocked!")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .opacity(lockOpacity)
            }
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            startUnlockAnimation()
        }
        .onTapGesture {
            if !isUnlocking {
                performUnlock()
            }
        }
        .onDisappear {
            particleTimer?.invalidate()
        }
    }

    private func startUnlockAnimation() {
        // Haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Fade in overlay
        withAnimation(.easeOut(duration: 0.3)) {
            showOverlay = true
        }

        // Scale in lock
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            lockScale = 1.0
            lockOpacity = 1.0
        }

        // Auto-unlock after brief pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            performUnlock()
        }
    }

    private func performUnlock() {
        guard !isUnlocking else { return }
        isUnlocking = true

        // Heavy haptic
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // Unlock animation - shackle opens
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            shackleOffset = -15
            shackleRotation = -30
        }

        // Show sparkles
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            showSparkles = true
        }

        // Start confetti burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            startConfetti()
        }

        // Transition to details after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }

    private func startConfetti() {
        // Initial burst
        for _ in 0..<40 {
            addConfettiParticle(burst: true)
        }

        // Continuous particles
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            if confettiParticles.count < 80 {
                addConfettiParticle(burst: false)
            }
            confettiParticles.removeAll { $0.y > UIScreen.main.bounds.height + 50 }
        }
    }

    private func addConfettiParticle(burst: Bool) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let particle = ConfettiParticle(
            x: burst ? screenWidth / 2 + CGFloat.random(in: -30...30) : CGFloat.random(in: 0...screenWidth),
            y: burst ? screenHeight / 2 - 50 : -20,
            color: confettiColors.randomElement()!,
            size: CGFloat.random(in: 6...12),
            rotation: Double.random(in: 0...360),
            rotationSpeed: Double.random(in: -360...360),
            xVelocity: burst ? CGFloat.random(in: -10...10) : CGFloat.random(in: -2...2),
            yVelocity: burst ? CGFloat.random(in: -12...(-4)) : CGFloat.random(in: 2...5),
            shape: [.circle, .rectangle, .star].randomElement()!
        )

        confettiParticles.append(particle)
        animateParticle(particle)
    }

    private func animateParticle(_ particle: ConfettiParticle) {
        guard let index = confettiParticles.firstIndex(where: { $0.id == particle.id }) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
            if let idx = self.confettiParticles.firstIndex(where: { $0.id == particle.id }) {
                self.confettiParticles[idx].x += particle.xVelocity
                self.confettiParticles[idx].y += particle.yVelocity + 3
                self.animateParticle(self.confettiParticles[idx])
            }
        }
    }
}

// MARK: - Shackle Shape
struct ShackleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.4))
        path.addQuadCurve(
            to: CGPoint(x: width, y: height * 0.4),
            control: CGPoint(x: width / 2, y: -height * 0.2)
        )
        path.addLine(to: CGPoint(x: width, y: height))

        return path
    }
}

// MARK: - Phase 2: Details View
struct MilestoneDetailsView: View {
    let milestone: CelebrationMilestone
    let onDismiss: () -> Void

    @AppStorage("userName") private var userName: String = "Brother"

    @State private var showContent: Bool = false
    @State private var badgeScale: CGFloat = 0.5
    @State private var glowOpacity: Double = 0

    private let primaryGreen = Color(hex: "74B886")
    private let goldAccent = Color(hex: "E8B86D")
    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        ZStack {
            // Solid dark background - NOT see-through
            Color(hex: "0A1628")
                .ignoresSafeArea()

            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    milestone.badgeColors[0].opacity(0.1),
                    Color.clear,
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer()
                        .frame(height: 60)

                    // Personalized greeting
                    VStack(spacing: 8) {
                        Text("Congratulations \(userName)!")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : -20)

                        Text("You have unlocked a new milestone")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "94A3B8"))
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : -20)
                    }
                    .padding(.bottom, 32)

                    // Badge with glow
                    ZStack {
                        // Outer glow rings
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(milestone.badgeColors[0].opacity(0.12 - Double(i) * 0.03))
                                .frame(width: 180 + CGFloat(i * 40), height: 180 + CGFloat(i * 40))
                                .opacity(glowOpacity)
                        }

                        // Badge container
                        ZStack {
                            // Background
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "1E293B"), Color(hex: "0F172A")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 130, height: 130)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(
                                            LinearGradient(
                                                colors: milestone.badgeColors,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: milestone.badgeColors[0].opacity(0.4), radius: 25)

                            // Icon circle
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: milestone.badgeColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)

                                Image(systemName: milestone.badgeIcon)
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .scaleEffect(badgeScale)
                    }
                    .padding(.bottom, 28)

                    // Days Free pill
                    Text("\(milestone.day) DAYS FREE")
                        .font(.system(size: 15, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: milestone.badgeColors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: milestone.badgeColors[0].opacity(0.5), radius: 15, y: 5)
                        )
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .padding(.bottom, 24)

                    // Islamic name
                    Text(milestone.islamicName)
                        .font(.system(size: 44, weight: .bold, design: .serif))
                        .foregroundColor(goldAccent)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    // Title
                    Text(milestone.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(hex: "64748B"))
                        .padding(.top, 4)
                        .opacity(showContent ? 1 : 0)

                    // Meaning
                    Text(milestone.meaning)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "94A3B8"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        .opacity(showContent ? 1 : 0)

                    // Bottom spacing for button
                    Spacer()
                        .frame(height: 100)
                }
            }

            // Fixed bottom button
            VStack {
                Spacer()

                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("Alhamdulillah!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 29)
                                .fill(
                                    LinearGradient(
                                        colors: [primaryGreen, primaryGreen.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: primaryGreen.opacity(0.4), radius: 15, y: 5)
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
            }
        }
        .onAppear {
            startDetailsAnimation()
        }
    }

    private func startDetailsAnimation() {
        // Badge scale in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            badgeScale = 1.0
        }

        // Glow fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            glowOpacity = 1.0
        }

        // Content fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showContent = true
        }

        // Haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }

    private func dismissWithAnimation() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        withAnimation(.easeIn(duration: 0.3)) {
            showContent = false
            glowOpacity = 0
            badgeScale = 0.8
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Confetti Particle View
struct ConfettiView: View {
    let particle: ConfettiParticle

    var body: some View {
        Group {
            switch particle.shape {
            case .circle:
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            case .rectangle:
                Rectangle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * 1.5)
            case .star:
                Image(systemName: "star.fill")
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
            }
        }
        .rotationEffect(.degrees(particle.rotation))
        .position(x: particle.x, y: particle.y)
    }
}

// MARK: - Preview
#Preview("Unlock Phase") {
    MilestoneCelebrationView(
        milestone: CelebrationMilestone(
            day: 7,
            title: "First Week",
            islamicName: "Sabr",
            meaning: "Patience - Steadfastness through difficulty. You've proven you can endure.",
            verse: "Indeed, Allah is with the patient.",
            verseReference: "Quran 2:153",
            badgeIcon: "shield.fill",
            badgeColors: [Color(hex: "60A5FA"), Color(hex: "3B82F6")]
        ),
        onDismiss: {}
    )
}

#Preview("Details Phase") {
    MilestoneDetailsView(
        milestone: CelebrationMilestone(
            day: 75,
            title: "Seventy-Five Days",
            islamicName: "Tawakkul",
            meaning: "Reliance - Complete trust and dependence on Allah.",
            verse: "Whoever relies upon Allah, then He is sufficient for him.",
            verseReference: "Quran 65:3",
            badgeIcon: "hands.sparkles.fill",
            badgeColors: [Color(hex: "A78BDA"), Color(hex: "8B5CF6")]
        ),
        onDismiss: {}
    )
}
