//
//  CheckInFlowView.swift
//  ImanPath
//
//  Daily Check-In Flow - Redesigned with spiritual depth
//

import SwiftUI
import SwiftData
import UIKit

struct CheckInFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var onComplete: (() -> Void)? = nil

    // Current streak from SwiftData
    @State private var currentStreak: Int = 0

    // Total screens: 1 (Self-Awareness) + 2 (Daily Anchor) + 3 (Journey) + 4-8 (5 Pledges) + 9 (Dua) + 10 (Complete)
    @State private var currentStep: Int = 1

    // Screen 1: Self-Awareness ratings
    @State private var moodRating: Int = 0
    @State private var energyRating: Int = 0
    @State private var confidenceRating: Int = 0
    @State private var faithRating: Int = 0
    @State private var selfControlRating: Int = 0

    // Screen 2: Daily anchor text
    @State private var progressReflection: String = ""

    // Screen 3: Journey reflection text
    @State private var journeyReflection: String = ""

    // Screen 4: Gratitude
    @State private var gratitudeText: String = ""

    private let totalSteps = 11

    var body: some View {
        ZStack {
            // Static dark background to prevent white flash
            Color(hex: "0A0D12")
                .ignoresSafeArea()

            // Dynamic gradient overlay (no animation on this)
            currentBackground
                .ignoresSafeArea()
                .animation(nil, value: currentStep)

            Group {
                switch currentStep {
                case 1:
                    SelfAwarenessScreenV2(
                        moodRating: $moodRating,
                        energyRating: $energyRating,
                        confidenceRating: $confidenceRating,
                        faithRating: $faithRating,
                        selfControlRating: $selfControlRating,
                        progress: progressValue,
                        onContinue: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 2 } },
                        onDismiss: { dismiss() }
                    )
                case 2:
                    DailyAnchorScreenV2(
                        currentStreak: currentStreak,
                        reflection: $progressReflection,
                        progress: progressValue,
                        onContinue: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 3 } },
                        onBack: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 1 } },
                        onDismiss: { dismiss() }
                    )
                case 3:
                    JourneyReflectionScreenV2(
                        currentStreak: currentStreak,
                        reflection: $journeyReflection,
                        progress: progressValue,
                        onContinue: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 4 } },
                        onBack: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 2 } },
                        onDismiss: { dismiss() }
                    )
                case 4:
                    GratitudeScreen(
                        gratitudeText: $gratitudeText,
                        progress: progressValue,
                        onContinue: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 5 } },
                        onBack: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 3 } },
                        onDismiss: { dismiss() }
                    )
                case 5...9:
                    PledgeScreenV2(
                        pledgeIndex: currentStep - 5,
                        progress: progressValue,
                        onContinue: { withAnimation(.easeInOut(duration: 0.35)) { currentStep += 1 } },
                        onBack: { withAnimation(.easeInOut(duration: 0.35)) { currentStep -= 1 } },
                        onDismiss: { dismiss() }
                    )
                    .id(currentStep) // Force view recreation for each pledge
                case 10:
                    DuaScreen(
                        progress: progressValue,
                        onContinue: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 11 } },
                        onBack: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 9 } },
                        onDismiss: { dismiss() }
                    )
                case 11:
                    CheckInCompleteScreenV2(
                        currentStreak: currentStreak,
                        overallScore: calculateOverallScore(),
                        onComplete: {
                            submitCheckIn()
                            dismiss()
                            onComplete?()
                        }
                    )
                default:
                    EmptyView()
                }
            }
            .transition(.move(edge: .trailing))
        }
        .animation(.easeInOut(duration: 0.35), value: currentStep)
        .navigationBarHidden(true)
        .onAppear {
            loadCurrentStreak()
        }
    }

    // MARK: - Data Operations

    private func loadCurrentStreak() {
        let dataManager = DataManager(modelContext: modelContext)
        currentStreak = dataManager.calculateCurrentStreakDays()

        // Prefill with today's check-in if exists
        if let existing = dataManager.getTodaysCheckin() {
            moodRating = existing.moodRating
            energyRating = existing.energyRating
            confidenceRating = existing.confidenceRating
            faithRating = existing.faithRating
            selfControlRating = existing.selfControlRating
            progressReflection = existing.progressReflection ?? ""
            journeyReflection = existing.journeyReflection ?? ""
            gratitudeText = existing.gratitude ?? ""
        }
    }

    private func submitCheckIn() {
        let dataManager = DataManager(modelContext: modelContext)
        _ = dataManager.submitCheckin(
            moodRating: moodRating,
            energyRating: energyRating,
            confidenceRating: confidenceRating,
            faithRating: faithRating,
            selfControlRating: selfControlRating,
            progressReflection: progressReflection.isEmpty ? nil : progressReflection,
            journeyReflection: journeyReflection.isEmpty ? nil : journeyReflection,
            gratitude: gratitudeText.isEmpty ? nil : gratitudeText,
            stayedClean: true  // Check-in implies staying clean
        )
    }

    private var progressValue: Double {
        Double(currentStep) / Double(totalSteps)
    }

    private var currentBackground: some View {
        Group {
            switch currentStep {
            case 1:
                CheckInGradient.awareness
            case 2:
                CheckInGradient.reflection
            case 3:
                CheckInGradient.journey
            case 4:
                CheckInGradient.gratitude
            case 5...9:
                CheckInGradient.pledge
            case 10:
                CheckInGradient.dua
            case 11:
                CheckInGradient.complete
            default:
                CheckInGradient.awareness
            }
        }
    }

    private func calculateOverallScore() -> Int {
        let total = moodRating + energyRating + confidenceRating + faithRating + selfControlRating
        return Int((Double(total) / 50.0) * 100)
    }
}

// MARK: - Gradient Backgrounds
struct CheckInGradient {
    static var awareness: some View {
        LinearGradient(
            colors: [
                Color(hex: "1A1F2E"),
                Color(hex: "0F1419"),
                Color(hex: "0A0E14")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [Color(hex: "5B9A9A").opacity(0.08), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
        )
    }

    static var reflection: some View {
        LinearGradient(
            colors: [
                Color(hex: "1E2A3A"),
                Color(hex: "0F1820"),
                Color(hex: "0A1015")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            RadialGradient(
                colors: [Color(hex: "6B8E9A").opacity(0.1), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 350
            )
        )
    }

    static var journey: some View {
        LinearGradient(
            colors: [
                Color(hex: "1A2535"),
                Color(hex: "0D1520"),
                Color(hex: "080C12")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [Color(hex: "8B9A6B").opacity(0.08), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
        )
    }

    static var gratitude: some View {
        LinearGradient(
            colors: [
                Color(hex: "1A2530"),
                Color(hex: "0F1518"),
                Color(hex: "0A0D10")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [Color(hex: "E8B86D").opacity(0.08), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
        )
    }

    static var pledge: some View {
        LinearGradient(
            colors: [
                Color(hex: "1F2530"),
                Color(hex: "141920"),
                Color(hex: "0A0D12")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            RadialGradient(
                colors: [Color(hex: "D4A574").opacity(0.08), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 350
            )
        )
    }

    static var dua: some View {
        LinearGradient(
            colors: [
                Color(hex: "1A2030"),
                Color(hex: "0F1520"),
                Color(hex: "080B10")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [Color(hex: "74B886").opacity(0.1), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
        )
    }

    static var complete: some View {
        LinearGradient(
            colors: [
                Color(hex: "1A2A35"),
                Color(hex: "0F1A22"),
                Color(hex: "0A1015")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            RadialGradient(
                colors: [Color(hex: "5B9A9A").opacity(0.15), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 350
            )
        )
    }
}

// MARK: - Progress Bar
struct CheckInProgressBar: View {
    let progress: Double

    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)

                // Progress fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tealAccent.opacity(0.8), tealAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Top Bar V2
struct CheckInTopBarV2: View {
    let progress: Double
    var onDismiss: () -> Void
    var onBack: (() -> Void)? = nil
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                if let onBack = onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                    }
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }

                Spacer()

                Text(dateString)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(0.5)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
            }

            CheckInProgressBar(progress: progress)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - Screen 1: Self-Awareness V2
struct SelfAwarenessScreenV2: View {
    @Binding var moodRating: Int
    @Binding var energyRating: Int
    @Binding var confidenceRating: Int
    @Binding var faithRating: Int
    @Binding var selfControlRating: Int

    let progress: Double
    var onContinue: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false

    // Unique colors for each dimension
    private let moodColor = Color(hex: "E8B86D")       // Warm gold
    private let energyColor = Color(hex: "74B886")      // Soft green
    private let confidenceColor = Color(hex: "6BA3D6")  // Calm blue
    private let faithColor = Color(hex: "A78BDA")       // Gentle purple
    private let selfControlColor = Color(hex: "E88B6D") // Warm coral

    private var activeCardIndex: Int {
        if moodRating == 0 { return 0 }
        if energyRating == 0 { return 1 }
        if confidenceRating == 0 { return 2 }
        if faithRating == 0 { return 3 }
        if selfControlRating == 0 { return 4 }
        return 5
    }

    private var allRated: Bool { activeCardIndex == 5 }

    var body: some View {
        VStack(spacing: 0) {
            CheckInTopBarV2(progress: progress, onDismiss: onDismiss)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 10) {
                        Text("How are you feeling?")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("Rate each area from 1-10")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    // Rating cards with unique colors
                    VStack(spacing: 14) {
                        RatingCardV2(
                            icon: "face.smiling",
                            title: "Mood",
                            subtitle: "Your emotional state today",
                            rating: $moodRating,
                            accentColor: moodColor,
                            isActive: activeCardIndex >= 0,
                            isComplete: moodRating > 0
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                        RatingCardV2(
                            icon: "bolt.fill",
                            title: "Energy",
                            subtitle: "Your motivation and vitality",
                            rating: $energyRating,
                            accentColor: energyColor,
                            isActive: activeCardIndex >= 1,
                            isComplete: energyRating > 0
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.15), value: showContent)

                        RatingCardV2(
                            icon: "shield.fill",
                            title: "Confidence",
                            subtitle: "Belief in your journey",
                            rating: $confidenceRating,
                            accentColor: confidenceColor,
                            isActive: activeCardIndex >= 2,
                            isComplete: confidenceRating > 0
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                        RatingCardV2(
                            icon: "moon.stars.fill",
                            title: "Faith",
                            subtitle: "Your connection with Allah",
                            rating: $faithRating,
                            accentColor: faithColor,
                            isActive: activeCardIndex >= 3,
                            isComplete: faithRating > 0
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.25), value: showContent)

                        RatingCardV2(
                            icon: "hand.raised.fill",
                            title: "Self Control",
                            subtitle: "Managing urges and temptations",
                            rating: $selfControlRating,
                            accentColor: selfControlColor,
                            isActive: activeCardIndex >= 4,
                            isComplete: selfControlRating > 0
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 120)
                }
            }

            // Bottom button
            CheckInBottomButtonV2(
                title: "Continue",
                isEnabled: allRated,
                showContent: showContent,
                action: {
                    triggerHaptic(.medium)
                    onContinue()
                }
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Rating Card V2
struct RatingCardV2: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var rating: Int
    let accentColor: Color
    let isActive: Bool
    let isComplete: Bool

    private let cardBg = Color(hex: "1A2230")

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                // Icon with accent background
                ZStack {
                    Circle()
                        .fill(isComplete ? accentColor.opacity(0.15) : Color(hex: "252D3D"))
                        .frame(width: 46, height: 46)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isComplete ? accentColor : (isActive ? .white.opacity(0.6) : .white.opacity(0.3)))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isActive ? .white : .white.opacity(0.4))

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(isActive ? .white.opacity(0.5) : .white.opacity(0.25))
                }

                Spacer()

                // Checkmark when complete
                if isComplete {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.2))
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                }
            }

            // Rating pills
            HStack(spacing: 6) {
                ForEach(1...10, id: \.self) { index in
                    Button(action: {
                        if isActive {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            rating = index
                        }
                    }) {
                        Text("\(index)")
                            .font(.system(size: 14, weight: index == rating ? .bold : .medium))
                            .foregroundColor(index == rating ? .white : (isActive ? .white.opacity(0.5) : .white.opacity(0.2)))
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(
                                Capsule()
                                    .fill(index == rating ? accentColor : Color(hex: "252D3D"))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isActive)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isComplete ? accentColor.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(isActive ? 1 : 0.5)
    }
}

// MARK: - Screen 2: Daily Anchor V2
struct DailyAnchorScreenV2: View {
    let currentStreak: Int
    @Binding var reflection: String
    let progress: Double
    var onContinue: () -> Void
    var onBack: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    private let accentColor = Color(hex: "6BA3D6")

    private var dayPrefix: String {
        switch currentStreak {
        case 0: return "A fresh start"
        case 1: return "Day 1 — a new beginning"
        case 2: return "Day 2 — building momentum"
        case 3: return "Day 3 shows real commitment"
        case 4...6: return "You're building strength"
        case 7: return "One week strong"
        case 8...13: return "Keep pushing forward"
        case 14: return "Two weeks of discipline"
        case 15...20: return "Habits are forming"
        case 21: return "21 days — a habit is born"
        case 22...29: return "You're transforming"
        case 30: return "One month clean"
        case 31...39: return "Allah sees your effort"
        case 40: return "40 days — a sacred number"
        case 41...59: return "You're not the same person"
        case 60: return "Two months of strength"
        case 61...89: return "Freedom is becoming real"
        case 90: return "90 days — full reboot"
        default: return "Every day matters"
        }
    }

    private var canContinue: Bool {
        reflection.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    var body: some View {
        VStack(spacing: 0) {
            CheckInTopBarV2(progress: progress, onDismiss: onDismiss, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 32)

                    // Icon
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 36))
                            .foregroundColor(accentColor)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)

                    // Title section
                    VStack(spacing: 12) {
                        Text(dayPrefix)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(accentColor)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text("How do you feel\nabout your progress?")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    // Text input area
                    ZStack(alignment: .topLeading) {
                        if reflection.isEmpty {
                            Text("Share your thoughts and feelings...")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.top, 16)
                                .padding(.leading, 4)
                        }

                        TextEditor(text: $reflection)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 140)
                            .focused($isTextFieldFocused)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1A2230"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    Spacer().frame(height: 120)
                }
            }

            CheckInBottomButtonV2(
                title: "Continue",
                isEnabled: canContinue,
                showContent: showContent,
                action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    isTextFieldFocused = false
                    onContinue()
                }
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Screen 3: Journey Reflection V2
struct JourneyReflectionScreenV2: View {
    let currentStreak: Int
    @Binding var reflection: String
    let progress: Double
    var onContinue: () -> Void
    var onBack: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    private let accentColor = Color(hex: "74B886")

    private var stageLabel: String {
        switch currentStreak {
        case 0...7: return "Foundation Stage"
        case 8...14: return "Growth Stage"
        case 15...30: return "Deeper Faith"
        default: return "Maintenance"
        }
    }

    private var journeyQuestion: String {
        switch currentStreak {
        case 0...7:
            let questions = [
                "What triggered you most recently?",
                "Why did you start this journey?",
                "What do you hope to achieve?",
                "What's your biggest challenge right now?",
                "What time of day is hardest for you?",
                "Who or what are you doing this for?",
                "What would freedom look like for you?"
            ]
            return questions[min(currentStreak, questions.count - 1)]
        case 8...14:
            let questions = [
                "What victory are you most proud of?",
                "How have you changed since Day 1?",
                "What new habit has helped you most?",
                "When did you feel closest to Allah this week?",
                "What strategy is working best for you?",
                "How has your self-control improved?",
                "What would you tell yourself on Day 1?"
            ]
            return questions[(currentStreak - 8) % questions.count]
        case 15...30:
            let questions = [
                "How has your connection to Allah changed?",
                "What does tawbah mean to you now?",
                "How has this journey affected your salah?",
                "What spiritual growth have you noticed?",
                "How do you handle urges differently now?",
                "What verse or hadith strengthens you most?",
                "How has your heart changed?"
            ]
            return questions[(currentStreak - 15) % questions.count]
        default:
            let questions = [
                "What advice would you give someone starting?",
                "How can you help others on this path?",
                "What are you most grateful for?",
                "How will you maintain this freedom?",
                "What does this journey mean for your future?",
                "How has Allah blessed your effort?",
                "What's your next goal?"
            ]
            return questions[(currentStreak - 31) % questions.count]
        }
    }

    private var canContinue: Bool {
        reflection.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    var body: some View {
        VStack(spacing: 0) {
            CheckInTopBarV2(progress: progress, onDismiss: onDismiss, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 32)

                    // Icon
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 36))
                            .foregroundColor(accentColor)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)

                    // Title section
                    VStack(spacing: 12) {
                        Text(stageLabel)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(accentColor)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text(journeyQuestion)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    // Text input area
                    ZStack(alignment: .topLeading) {
                        if reflection.isEmpty {
                            Text("Reflect and write...")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.top, 16)
                                .padding(.leading, 4)
                        }

                        TextEditor(text: $reflection)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 140)
                            .focused($isTextFieldFocused)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1A2230"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Skip option
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        isTextFieldFocused = false
                        onContinue()
                    }) {
                        Text("Skip for now")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 120)
                }
            }

            CheckInBottomButtonV2(
                title: "Continue",
                isEnabled: canContinue,
                showContent: showContent,
                action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    isTextFieldFocused = false
                    onContinue()
                }
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Screen 4: Gratitude
struct GratitudeScreen: View {
    @Binding var gratitudeText: String
    let progress: Double
    var onContinue: () -> Void
    var onBack: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    private let accentColor = Color(hex: "E8B86D") // Warm gold

    private var canContinue: Bool {
        gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    // Rotating gratitude prompts
    private var gratitudePrompt: String {
        let prompts = [
            "What blessing are you thankful for today?",
            "What made you smile recently?",
            "What's something small you're grateful for?",
            "Who in your life are you thankful for?",
            "What ability or strength are you grateful to have?"
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return prompts[dayOfYear % prompts.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            CheckInTopBarV2(progress: progress, onDismiss: onDismiss, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 32)

                    // Icon
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "heart.fill")
                            .font(.system(size: 36))
                            .foregroundColor(accentColor)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)

                    // Title section
                    VStack(spacing: 12) {
                        Text("Gratitude")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(accentColor)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text(gratitudePrompt)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    // Hadith about gratitude
                    Text("\"He who does not thank people, does not thank Allah.\"")
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)

                    // Text input area
                    ZStack(alignment: .topLeading) {
                        if gratitudeText.isEmpty {
                            Text("I'm grateful for...")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.top, 16)
                                .padding(.leading, 4)
                        }

                        TextEditor(text: $gratitudeText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 120)
                            .focused($isTextFieldFocused)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1A2230"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    Spacer().frame(height: 120)
                }
            }

            CheckInBottomButtonV2(
                title: "Continue",
                isEnabled: canContinue,
                showContent: showContent,
                accentColor: accentColor,
                action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    isTextFieldFocused = false
                    onContinue()
                }
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Screen 5-9: Pledge Screens
struct PledgeScreenV2: View {
    let pledgeIndex: Int
    let progress: Double
    var onContinue: () -> Void
    var onBack: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false
    @State private var hasCommitted: Bool = false

    private let accentColor = Color(hex: "D4A574")

    private var pledge: (title: String, text: String, verse: String, reference: String) {
        let pledges = [
            (
                title: "Guard Your Gaze",
                text: "I pledge to lower my gaze and protect my eyes from what displeases Allah.",
                verse: "Tell the believing men to lower their gaze and guard their private parts. That is purer for them.",
                reference: "Quran 24:30"
            ),
            (
                title: "Seek Allah's Help",
                text: "I pledge to turn to Allah in every moment of temptation, knowing He is always near.",
                verse: "And when My servants ask you concerning Me - indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.",
                reference: "Quran 2:186"
            ),
            (
                title: "Be Patient",
                text: "I pledge to remain patient through every urge, trusting in Allah's plan for me.",
                verse: "Indeed, Allah is with the patient.",
                reference: "Quran 8:46"
            ),
            (
                title: "Protect My Heart",
                text: "I pledge to guard my heart from corrupting influences and fill it with remembrance of Allah.",
                verse: "Verily, in the remembrance of Allah do hearts find rest.",
                reference: "Quran 13:28"
            ),
            (
                title: "Stay Committed",
                text: "I pledge to stay committed to this path, no matter how many times I stumble.",
                verse: "And whoever is mindful of Allah - He will make for him a way out and will provide for him from where he does not expect.",
                reference: "Quran 65:2-3"
            )
        ]
        return pledges[pledgeIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            CheckInTopBarV2(progress: progress, onDismiss: onDismiss, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    // Pledge indicator
                    Text("Pledge \(pledgeIndex + 1) of 5")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(accentColor)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 32)

                    // Decorative element
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(accentColor.opacity(0.3))
                            .frame(width: 24, height: 1)

                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(accentColor.opacity(0.5))

                        Rectangle()
                            .fill(accentColor.opacity(0.3))
                            .frame(width: 24, height: 1)
                    }
                    .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 32)

                    // Pledge title
                    Text(pledge.title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Spacer().frame(height: 24)

                    // Pledge text
                    Text(pledge.text)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    Spacer().frame(height: 40)

                    // Verse card
                    VStack(spacing: 16) {
                        Text("\"\(pledge.verse)\"")
                            .font(.system(size: 15, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)

                        Text("— \(pledge.reference)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1A2230").opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 28)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    Spacer().frame(height: 140)
                }
            }

            // Commit button
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.clear, Color(hex: "0A0D12").opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)

                VStack(spacing: 0) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            hasCommitted = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onContinue()
                        }
                    }) {
                        HStack(spacing: 10) {
                            if hasCommitted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            Text(hasCommitted ? "Insha'Allah" : "Bismillah, I Commit")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(hasCommitted ? accentColor : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(hasCommitted ? accentColor.opacity(0.15) : accentColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(hasCommitted ? accentColor : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .disabled(hasCommitted)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
                .background(Color(hex: "0A0D12").opacity(0.8))
            }
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            hasCommitted = false
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}

// MARK: - Screen 9: Dua Screen
struct DuaScreen: View {
    let progress: Double
    var onContinue: () -> Void
    var onBack: () -> Void
    var onDismiss: () -> Void

    @State private var showContent: Bool = false
    @State private var ameenText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private let accentColor = Color(hex: "74B886")

    private var isAmeenTyped: Bool {
        let text = ameenText.lowercased().trimmingCharacters(in: .whitespaces)
        return text == "ameen" || text == "amin" || text == "آمين"
    }

    private let duaArabic = "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ"

    private let duaTranslation = "O Allah, help me to remember You, to be grateful to You, and to worship You in an excellent manner."

    var body: some View {
        VStack(spacing: 0) {
            CheckInTopBarV2(progress: progress, onDismiss: onDismiss, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 48)

                    // Decorative crescent
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.08))
                            .frame(width: 100, height: 100)

                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 44))
                            .foregroundColor(accentColor)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)

                    Spacer().frame(height: 32)

                    // Title
                    Text("Close with Dua")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Spacer().frame(height: 8)

                    Text("Seal your commitment with supplication")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                        .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 40)

                    // Dua card
                    VStack(spacing: 24) {
                        // Arabic text
                        Text(duaArabic)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)

                        // Divider
                        Rectangle()
                            .fill(accentColor.opacity(0.3))
                            .frame(width: 60, height: 1)

                        // Translation
                        Text(duaTranslation)
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)

                        // Source
                        Text("Hadith - Abu Dawud")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(accentColor.opacity(0.8))
                            .tracking(0.5)
                    }
                    .padding(28)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "1A2230").opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    Spacer().frame(height: 36)

                    // Ameen input
                    VStack(spacing: 14) {
                        Text("Type \"Ameen\" to complete")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))

                        TextField("", text: $ameenText)
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .placeholder(when: ameenText.isEmpty) {
                                Text("Ameen")
                                    .font(.system(size: 22, weight: .semibold, design: .serif))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "1A2230"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isAmeenTyped ? accentColor : Color.white.opacity(0.08),
                                                lineWidth: isAmeenTyped ? 2 : 1
                                            )
                                    )
                            )
                            .focused($isTextFieldFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 40)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                    Spacer().frame(height: 140)
                }
            }

            CheckInBottomButtonV2(
                title: "Complete Check-In",
                isEnabled: isAmeenTyped,
                showContent: showContent,
                accentColor: accentColor,
                action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    isTextFieldFocused = false
                    onContinue()
                }
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Screen 10: Complete V2
struct CheckInCompleteScreenV2: View {
    let currentStreak: Int
    let overallScore: Int
    var onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var showConfetti: Bool = false

    private let accentColor = Color(hex: "5B9A9A")

    private var completionVerse: (text: String, reference: String) {
        let verses = [
            ("And whoever is mindful of Allah, He will make a way out for them.", "Quran 65:2"),
            ("Verily, with hardship comes ease.", "Quran 94:6"),
            ("And be patient. Indeed, Allah is with the patient.", "Quran 8:46"),
            ("So remember Me; I will remember you.", "Quran 2:152"),
            ("Allah does not burden a soul beyond that it can bear.", "Quran 2:286")
        ]
        return verses[currentStreak % verses.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                // Success badge with glow
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(accentColor.opacity(0.08 - Double(i) * 0.02), lineWidth: 2)
                            .frame(width: 160 + CGFloat(i * 40), height: 160 + CGFloat(i * 40))
                            .scaleEffect(pulseScale)
                    }

                    // Main circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accentColor.opacity(0.5), accentColor.opacity(0.8)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: accentColor.opacity(0.5), radius: 30)

                    VStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)

                        Text("Day \(currentStreak)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.7)

                // Message
                VStack(spacing: 12) {
                    Text("Check-In Complete")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("Today's wellness score")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))

                    Text("\(overallScore)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(accentColor)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                // Verse
                VStack(spacing: 12) {
                    Text("\"\(completionVerse.text)\"")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)

                    Text("— \(completionVerse.reference)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                .padding(.horizontal, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
            }

            Spacer()

            // Done button
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onComplete()
            }) {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(accentColor)
                            .shadow(color: accentColor.opacity(0.4), radius: 12, y: 4)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// MARK: - Bottom Button V2
struct CheckInBottomButtonV2: View {
    let title: String
    let isEnabled: Bool
    let showContent: Bool
    var accentColor: Color = Color(hex: "5B9A9A")
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.clear, Color(hex: "0A0D12").opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            VStack(spacing: 0) {
                Button(action: action) {
                    HStack(spacing: 10) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))

                        if isEnabled {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(isEnabled ? .white : .white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isEnabled ? accentColor : Color(hex: "1A2230"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isEnabled ? Color.clear : Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
                }
                .disabled(!isEnabled)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
            .background(Color(hex: "0A0D12").opacity(0.9))
        }
        .opacity(showContent ? 1 : 0)
    }
}

#Preview {
    CheckInFlowView()
}
