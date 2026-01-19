//
//  RelapsedFlowView.swift
//  ImanPath
//
//  Relapse Flow - Compassionate Tawbah guidance
//

import SwiftUI
import UIKit

struct RelapsedFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var onComplete: (() -> Void)? = nil

    @State private var currentStep: Int = 1
    @State private var currentStreak: Int = 0
    @State private var totalCleanDays: Int = 0

    // Colors - warm, compassionate tones
    private let warmAmber = Color(hex: "C4956A")
    private let softGold = Color(hex: "D4A574")
    private let deepBrown = Color(hex: "8B6B4A")
    private let cardBg = Color(hex: "1A2737")

    var body: some View {
        ZStack {
            SpaceBackground()

            switch currentStep {
            case 1:
                AcknowledgmentView(onContinue: { currentStep = 2 }, onDismiss: { dismiss() })
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case 2:
                TawbahGuidanceView(onContinue: { currentStep = 3 }, onDismiss: { dismiss() })
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case 3:
                JournalPromptView(onContinue: { currentStep = 4 }, onSkip: { currentStep = 4 }, onDismiss: { dismiss() })
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case 4:
                ResetConfirmationView(
                    onConfirm: {
                        resetStreak()
                        currentStep = 5
                    },
                    onDismiss: { dismiss() },
                    previousStreak: currentStreak,
                    totalDaysClean: totalCleanDays
                )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case 5:
                RecommitmentView(onComplete: {
                    // Don't call dismiss() here - let parent's dismiss handle both
                    // This prevents PanicView from briefly flashing
                    onComplete?()
                })
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: currentStep)
        .navigationBarHidden(true)
        .onAppear {
            loadStreakData()
        }
    }

    private func loadStreakData() {
        let dataManager = DataManager(modelContext: modelContext)
        let stats = dataManager.getHomeStats()
        currentStreak = stats.currentStreak
        totalCleanDays = stats.totalCleanDays
    }

    private func resetStreak() {
        // Track analytics before reset (while currentStreak still has previous value)
        AnalyticsManager.shared.trackRelapse(previousStreak: currentStreak)

        let dataManager = DataManager(modelContext: modelContext)
        dataManager.resetStreak(reason: "relapse")
    }
}

// MARK: - Screen 1: Acknowledgment
struct AcknowledgmentView: View {
    var onContinue: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false

    private let warmAmber = Color(hex: "C4956A")

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            // Central content
            VStack(spacing: 32) {
                // Warm embrace icon
                ZStack {
                    Circle()
                        .fill(warmAmber.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(warmAmber.opacity(0.3), lineWidth: 1)
                        .frame(width: 120, height: 120)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundColor(warmAmber)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)

                VStack(spacing: 16) {
                    Text("It's okay.")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("You're still here.")
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(warmAmber)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Text("A setback doesn't erase your journey.\nWhat matters is that you came back.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "8A9BAE"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Continue button
            Button(action: {
                triggerHaptic(.medium)
                onContinue()
            }) {
                Text("I'm Ready to Repent")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(warmAmber)
                            .shadow(color: warmAmber.opacity(0.4), radius: 12, y: 4)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Screen 2: Tawbah Guidance
struct TawbahGuidanceView: View {
    var onContinue: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false
    @State private var currentStepIndex: Int = 0

    private let warmAmber = Color(hex: "C4956A")
    private let softGold = Color(hex: "D4A574")
    private let cardBg = Color(hex: "1A2737")

    private let tawbahSteps: [(title: String, description: String, icon: String)] = [
        ("Stop", "Cease the sin immediately and remove yourself from the situation.", "hand.raised.fill"),
        ("Regret", "Feel genuine remorse in your heart for disobeying Allah.", "heart.fill"),
        ("Resolve", "Make a sincere intention to never return to this sin.", "arrow.up.heart.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer().frame(height: 24)

            // Title
            VStack(spacing: 8) {
                Text("The Path of Tawbah")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("Three steps to repentance")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "8A9BAE"))
            }
            .opacity(showContent ? 1 : 0)

            Spacer().frame(height: 32)

            // Tawbah steps
            VStack(spacing: 16) {
                ForEach(0..<tawbahSteps.count, id: \.self) { index in
                    TawbahStepCard(
                        step: tawbahSteps[index],
                        stepNumber: index + 1,
                        isActive: index <= currentStepIndex,
                        accentColor: warmAmber
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(x: showContent ? 0 : -30)
                    .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.15 + 0.3), value: showContent)
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            // Verse card
            VStack(spacing: 16) {
                Text("قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                Text("\"Say: O My servants who have transgressed against themselves, do not despair of the mercy of Allah.\"")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "8A9BAE"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("— Quran 39:53")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(warmAmber)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(warmAmber.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.7), value: showContent)

            Spacer()

            // Continue button
            Button(action: {
                triggerHaptic(.medium)
                onContinue()
            }) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(warmAmber)
                            .shadow(color: warmAmber.opacity(0.4), radius: 12, y: 4)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            // Animate through steps
            for i in 0..<tawbahSteps.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4 + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStepIndex = i
                    }
                }
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Tawbah Step Card
struct TawbahStepCard: View {
    let step: (title: String, description: String, icon: String)
    let stepNumber: Int
    let isActive: Bool
    let accentColor: Color

    var body: some View {
        HStack(spacing: 16) {
            // Step number circle
            ZStack {
                Circle()
                    .fill(isActive ? accentColor.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 48, height: 48)

                Circle()
                    .stroke(isActive ? accentColor : Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: 48, height: 48)

                Image(systemName: step.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? accentColor : Color.white.opacity(0.4))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isActive ? .white : .white.opacity(0.5))

                Text(step.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(isActive ? Color(hex: "8A9BAE") : Color(hex: "8A9BAE").opacity(0.5))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isActive ? 0.05 : 0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isActive ? accentColor.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Screen 3: Journal Prompt
struct JournalPromptView: View {
    var onContinue: () -> Void
    var onSkip: () -> Void
    var onDismiss: () -> Void

    @State private var journalText: String = ""
    @State private var showContent: Bool = false
    @FocusState private var isTextEditorFocused: Bool

    private let warmAmber = Color(hex: "C4956A")
    private let cardBg = Color(hex: "1A2737")

    private var hasWritten: Bool {
        journalText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 24)

                    // Title
                    VStack(spacing: 8) {
                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 32))
                            .foregroundColor(warmAmber)

                        Text("Reflect & Learn")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("Optional, but powerful")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "8A9BAE"))
                    }
                    .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 24)

                    // Prompt card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What triggered this relapse?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Understanding your triggers helps you prepare for next time. Be honest with yourself.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "8A9BAE"))
                            .lineSpacing(4)

                        // Text editor
                        ZStack(alignment: .topLeading) {
                            if journalText.isEmpty {
                                Text("I was feeling... I was doing... Next time I will...")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "5A6A7A"))
                                    .padding(.top, 12)
                                    .padding(.leading, 4)
                            }

                            TextEditor(text: $journalText)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 120)
                                .focused($isTextEditorFocused)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(warmAmber.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 24)

                    // Reminder
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "8A9BAE"))

                        Text("This stays private on your device")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "8A9BAE"))
                    }
                    .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 32)
                }
            }

            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    triggerHaptic(.medium)
                    // TODO: Save journal entry
                    onContinue()
                }) {
                    Text(hasWritten ? "Save & Continue" : "Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(hasWritten ? warmAmber : warmAmber.opacity(0.7))
                                .shadow(color: warmAmber.opacity(0.4), radius: 12, y: 4)
                        )
                }

                if !hasWritten {
                    Button(action: {
                        triggerHaptic(.light)
                        onSkip()
                    }) {
                        Text("Skip for now")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "8A9BAE"))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
        .onTapGesture {
            isTextEditorFocused = false
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Screen 4: Reset Confirmation
struct ResetConfirmationView: View {
    var onConfirm: () -> Void
    var onDismiss: () -> Void
    var previousStreak: Int
    var totalDaysClean: Int

    @State private var showContent: Bool = false

    private let warmAmber = Color(hex: "C4956A")
    private let cardBg = Color(hex: "1A2737")

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            VStack(spacing: 32) {
                // Title
                VStack(spacing: 8) {
                    Text("Before We Reset")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("Your journey so far")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "8A9BAE"))
                }
                .opacity(showContent ? 1 : 0)

                // Stats card
                VStack(spacing: 20) {
                    HStack(spacing: 24) {
                        StatItem(value: "\(previousStreak)", label: "Day Streak", icon: "flame.fill", color: warmAmber)

                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1, height: 60)

                        StatItem(value: "\(totalDaysClean)", label: "Total Clean", icon: "calendar", color: Color(hex: "6B8CAE"))
                    }

                    Divider()
                        .background(Color.white.opacity(0.1))

                    Text("This streak will reset to Day 0")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "8A9BAE"))
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(warmAmber.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Encouragement
                VStack(spacing: 8) {
                    Text("But remember...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "8A9BAE"))

                    Text("Your \(totalDaysClean) total clean days\nare never erased.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
            }

            Spacer()

            // Confirm button
            Button(action: {
                triggerHaptic(.medium)
                onConfirm()
            }) {
                Text("Reset My Streak")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(warmAmber)
                            .shadow(color: warmAmber.opacity(0.4), radius: 12, y: 4)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "8A9BAE"))
        }
    }
}

// MARK: - Screen 5: Recommitment
struct RecommitmentView: View {
    var onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    private let warmAmber = Color(hex: "C4956A")
    private let calmTeal = Color(hex: "5B9A9A")

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                // Day 0 badge with pulse
                ZStack {
                    // Pulse rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(calmTeal.opacity(0.1 - Double(i) * 0.03), lineWidth: 2)
                            .frame(width: 160 + CGFloat(i * 40), height: 160 + CGFloat(i * 40))
                            .scaleEffect(pulseScale)
                    }

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    calmTeal.opacity(0.3),
                                    calmTeal.opacity(0.5),
                                    calmTeal.opacity(0.7)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: calmTeal.opacity(0.5), radius: 20, x: 0, y: 0)

                    VStack(spacing: 4) {
                        Text("Day")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        Text("0")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)

                // Message
                VStack(spacing: 16) {
                    Text("You're Back")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("This is a new beginning,\nnot the end of your journey.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(hex: "8A9BAE"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Verse
                VStack(spacing: 8) {
                    Text("\"And whoever fears Allah, He will make for him a way out.\"")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)

                    Text("— Quran 65:2")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(calmTeal)
                }
                .padding(.horizontal, 32)
                .opacity(showContent ? 1 : 0)
            }

            Spacer()

            // Continue button
            Button(action: {
                triggerHaptic(.medium)
                onComplete()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                    Text("Start Fresh")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(calmTeal)
                        .shadow(color: calmTeal.opacity(0.4), radius: 12, y: 4)
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
            // Pulse animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

#Preview {
    RelapsedFlowView()
}
