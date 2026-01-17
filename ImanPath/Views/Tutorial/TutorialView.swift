//
//  TutorialView.swift
//  Return
//
//  Post-onboarding tutorial carousel
//  Introduces key features before showing home screen
//

import SwiftUI

struct TutorialView: View {
    var onComplete: () -> Void

    @State private var currentStep: Int = 0

    private let totalSteps = 5

    // Colors
    private let bgPrimary = Color(hex: "0A1628")
    private let accentAmber = Color(hex: "C4956A")
    private let accentViolet = Color(hex: "7B5E99")
    private let glowBlue = Color(hex: "1E3A5F")

    // Tutorial content
    private let steps: [TutorialStepData] = [
        TutorialStepData(
            heading: "Welcome to Return!",
            subtitle: "Bismillah. Here's how your journey begins.",
            callout: "Emergency support when you need it",
            screenshotName: "tutorial_panic" // Will use placeholder for now
        ),
        TutorialStepData(
            heading: "Track Your Progress",
            subtitle: "Watch your streak grow and unlock milestones",
            callout: "Your journey at a glance",
            screenshotName: "tutorial_streak"
        ),
        TutorialStepData(
            heading: "Daily Spiritual Practice",
            subtitle: "5 minutes a day to strengthen your recovery",
            callout: "Build habits that last",
            screenshotName: "tutorial_daily"
        ),
        TutorialStepData(
            heading: "You're Never Alone",
            subtitle: "Your AI Coach and tools are always here",
            callout: "24/7 support",
            screenshotName: "tutorial_tools"
        ),
        TutorialStepData(
            heading: "Honor Your Niyyah",
            subtitle: "You've done the hard part. All that's left is to show up each day. Allah sees every effort you make.",
            callout: "Complete your daily check-in",
            screenshotName: "tutorial_commitment"
        )
    ]

    var body: some View {
        ZStack {
            // Background
            bgPrimary.ignoresSafeArea()

            // Subtle star field
            StarFieldView()

            VStack(spacing: 0) {
                // TabView carousel
                TabView(selection: $currentStep) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        TutorialPageView(
                            step: steps[index],
                            accentAmber: accentAmber,
                            accentViolet: accentViolet,
                            glowBlue: glowBlue
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom section
                VStack(spacing: 20) {
                    // Pagination dots
                    HStack(spacing: 8) {
                        ForEach(0..<totalSteps, id: \.self) { index in
                            Capsule()
                                .fill(index == currentStep ? accentAmber : Color.white.opacity(0.3))
                                .frame(width: index == currentStep ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentStep)
                        }
                    }

                    // Button
                    Button(action: {
                        if currentStep < totalSteps - 1 {
                            withAnimation { currentStep += 1 }
                        } else {
                            onComplete()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentStep == totalSteps - 1 ? "Bismillah, Let's Begin" : "Continue")
                                .font(.system(size: 17, weight: .semibold))
                            if currentStep < totalSteps - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundColor(currentStep == totalSteps - 1 ? bgPrimary : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(accentAmber)
                        )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Data
struct TutorialStepData {
    let heading: String
    let subtitle: String
    let callout: String
    let screenshotName: String
}

// MARK: - Tutorial Page View
struct TutorialPageView: View {
    let step: TutorialStepData
    let accentAmber: Color
    let accentViolet: Color
    let glowBlue: Color

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Phone with circular glow backdrop
            ZStack {
                // Circular glow backdrop (like Quittr)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                glowBlue.opacity(0.8),
                                glowBlue.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)

                // Phone mockup
                PhoneFrameView(
                    screenshotName: step.screenshotName,
                    accentAmber: accentAmber
                )
            }
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 40)

            // Heading
            Text(step.heading)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 16)

            // Subtitle
            Text(step.subtitle)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "8A9BAE"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

// MARK: - Phone Frame View (Quittr style - gold frame with glow)
struct PhoneFrameView: View {
    let screenshotName: String
    let accentAmber: Color

    // Frame colors - champagne/gold like Quittr
    private let frameOuter = Color(hex: "8B7355")
    private let frameInner = Color(hex: "A08060")
    private let screenBg = Color(hex: "0A1628")

    var body: some View {
        ZStack {
            // Outer frame (gold/champagne)
            RoundedRectangle(cornerRadius: 36)
                .fill(
                    LinearGradient(
                        colors: [frameInner, frameOuter, frameInner],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 360)
                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)

            // Screen area
            RoundedRectangle(cornerRadius: 30)
                .fill(screenBg)
                .frame(width: 164, height: 344)

            // Screenshot or placeholder content
            ScreenshotContent(name: screenshotName, accentAmber: accentAmber)
                .frame(width: 164, height: 344)
                .clipShape(RoundedRectangle(cornerRadius: 30))

            // Dynamic island
            Capsule()
                .fill(Color.black)
                .frame(width: 60, height: 22)
                .offset(y: -152)
        }
    }
}

// MARK: - Screenshot Content (placeholder until real screenshots added)
struct ScreenshotContent: View {
    let name: String
    let accentAmber: Color

    var body: some View {
        // Try to load image from assets, fall back to placeholder
        if let _ = UIImage(named: name) {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // Placeholder content based on screen type
            PlaceholderScreenContent(type: name, accentAmber: accentAmber)
        }
    }
}

// MARK: - Placeholder Screen Content
struct PlaceholderScreenContent: View {
    let type: String
    let accentAmber: Color

    var body: some View {
        ZStack {
            Color(hex: "0A1628")

            VStack(spacing: 12) {
                switch type {
                case "tutorial_panic":
                    PanicPlaceholder(accentAmber: accentAmber)
                case "tutorial_streak":
                    StreakPlaceholder(accentAmber: accentAmber)
                case "tutorial_daily":
                    DailyPlaceholder(accentAmber: accentAmber)
                case "tutorial_tools":
                    ToolsPlaceholder(accentAmber: accentAmber)
                case "tutorial_commitment":
                    CommitmentPlaceholder(accentAmber: accentAmber)
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Compact Placeholders
struct PanicPlaceholder: View {
    let accentAmber: Color
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.red)
                    .frame(width: 60, height: 60)
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            Text("Panic Button")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
    }
}

struct StreakPlaceholder: View {
    let accentAmber: Color
    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            Text("0")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("DAYS")
                .font(.system(size: 12, weight: .semibold))
                .tracking(2)
                .foregroundColor(accentAmber)
            Spacer().frame(height: 16)
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .stroke(accentAmber.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }
            }
            Spacer()
        }
    }
}

struct DailyPlaceholder: View {
    let accentAmber: Color
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            ForEach(["Check-in", "Lesson", "Dhikr"], id: \.self) { item in
                HStack(spacing: 8) {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                    Text(item)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
}

struct ToolsPlaceholder: View {
    let accentAmber: Color
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(["message.fill", "wind", "book.fill", "hands.sparkles.fill"], id: \.self) { icon in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 50)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundColor(accentAmber)
                        )
                }
            }
            .padding(.horizontal, 16)
            Spacer()
        }
    }
}

struct CommitmentPlaceholder: View {
    let accentAmber: Color
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28))
                .foregroundColor(accentAmber)
            Text("Your Niyyah")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            Text("90 Days")
                .font(.system(size: 10))
                .foregroundColor(accentAmber)
            Spacer()
        }
    }
}

// MARK: - Star Field
struct StarFieldView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<40, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.2...0.6)))
                    .frame(width: CGFloat.random(in: 1...2))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    TutorialView(onComplete: {})
}
