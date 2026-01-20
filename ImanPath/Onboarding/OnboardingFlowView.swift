//
//  OnboardingFlowView.swift
//  ImanPath
//
//  32-step onboarding flow for new users
//

import SwiftUI
import SwiftData
struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    @State private var currentStep: Int = 1
    private let totalSteps = 30

    // Set when user reaches prepaywall - they won't redo onboarding if they leave
    @AppStorage("hasSeenPrepaywall") private var hasSeenPrepaywall: Bool = false

    // DataManager for persistence
    private var dataManager: DataManager {
        DataManager(modelContext: modelContext)
    }

    // User's name (collected at end of quiz)
    @State private var userName: String = ""

    // Collected data from onboarding
    @State private var selectedReasons: Set<String> = []
    @State private var quizResponses: [String: String] = [:]
    @State private var selectedGoals: Set<String> = []
    @State private var selectedSymptoms: Set<String> = []

    // Analytics guards
    @State private var didTrackOnboardingStarted: Bool = false
    @State private var didTrackQuizCompleted: Bool = false
    @State private var didTrackCommitmentSigned: Bool = false
    @State private var didTrackPaywallViewed: Bool = false
    @State private var didTrackOnboardingCompleted: Bool = false

    // Win-back paywall for transaction abandon
    @State private var showWinBackPaywall: Bool = false

    // Colors
    private let warmAmber = Color(hex: "C4956A")
    private let quizRecoveryScore: Int = 64

    private var progress: Double {
        // Quiz is steps 3-14 (12 questions including name)
        // Show quiz progress for these steps
        if currentStep >= 3 && currentStep <= 14 {
            return Double(currentStep - 2) / 12.0
        }
        // For post-quiz steps, continue from where quiz ended
        return Double(currentStep) / Double(totalSteps)
    }


    // MARK: - Quiz Questions Data (12 questions based on Quittr + Unchained + Islamic)

    private let quizQuestions: [Int: QuizQuestion] = [
        // Step 3: Gender
        3: QuizQuestion(
            id: "gender",
            question: "What is your gender?",
            subtitle: nil,
            options: [
                QuizOption(id: "male", text: "Male"),
                QuizOption(id: "female", text: "Female"),
                QuizOption(id: "prefer_not_say", text: "Prefer not to say")
            ]
        ),
        // Step 4: Frequency
        4: QuizQuestion(
            id: "frequency",
            question: "How often do you typically view pornography?",
            subtitle: nil,
            options: [
                QuizOption(id: "multiple_daily", text: "More than once a day"),
                QuizOption(id: "daily", text: "Once a day"),
                QuizOption(id: "few_week", text: "A few times a week"),
                QuizOption(id: "less_weekly", text: "Less than once a week")
            ]
        ),
        // Step 5: Age first exposure
        5: QuizQuestion(
            id: "first_exposure_age",
            question: "When did you first come across pornography?",
            subtitle: nil,
            options: [
                QuizOption(id: "under_13", text: "Under 13"),
                QuizOption(id: "13_16", text: "13-16"),
                QuizOption(id: "17_24", text: "17-24"),
                QuizOption(id: "24_plus", text: "24+")
            ]
        ),
        // Step 6: Usage increased
        6: QuizQuestion(
            id: "usage_increased",
            question: "Has your usage increased over time?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes", text: "Yes"),
                QuizOption(id: "no", text: "No"),
                QuizOption(id: "not_sure", text: "Not sure")
            ]
        ),
        // Step 7: Extreme content escalation
        7: QuizQuestion(
            id: "extreme_content",
            question: "Have you noticed a shift towards more extreme or graphic material?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes", text: "Yes"),
                QuizOption(id: "no", text: "No"),
                QuizOption(id: "not_sure", text: "Not sure")
            ]
        ),
        // Step 8: Arousal difficulty
        8: QuizQuestion(
            id: "arousal_difficulty",
            question: "Do you find it difficult to achieve sexual arousal without porn?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes", text: "Yes"),
                QuizOption(id: "sometimes", text: "Sometimes"),
                QuizOption(id: "no", text: "No")
            ]
        ),
        // Step 9: Coping mechanism
        9: QuizQuestion(
            id: "coping",
            question: "Do you use pornography to cope with stress, boredom, or emotional discomfort?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes", text: "Yes"),
                QuizOption(id: "sometimes", text: "Sometimes"),
                QuizOption(id: "no", text: "No")
            ]
        ),
        // Step 10: Spent money
        10: QuizQuestion(
            id: "spent_money",
            question: "Have you ever spent money on explicit content?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes", text: "Yes"),
                QuizOption(id: "no", text: "No")
            ]
        ),
        // Step 11: Relationship status
        11: QuizQuestion(
            id: "relationship_status",
            question: "What is your relationship status?",
            subtitle: nil,
            options: [
                QuizOption(id: "single", text: "Single"),
                QuizOption(id: "dating", text: "In a relationship"),
                QuizOption(id: "engaged", text: "Engaged"),
                QuizOption(id: "married", text: "Married")
            ]
        ),
        // Step 12: Connection to Allah
        12: QuizQuestion(
            id: "allah_connection",
            question: "How connected do you currently feel to Allah?",
            subtitle: nil,
            options: [
                QuizOption(id: "very_connected", text: "Very connected"),
                QuizOption(id: "somewhat_connected", text: "Somewhat connected"),
                QuizOption(id: "disconnected", text: "Disconnected"),
                QuizOption(id: "very_disconnected", text: "Very disconnected")
            ]
        ),
        // Step 13: Porn's spiritual impact
        13: QuizQuestion(
            id: "porn_distance_allah",
            question: "Has watching porn made you feel distant from Allah?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes_very", text: "Yes, very much"),
                QuizOption(id: "yes_somewhat", text: "Yes, somewhat"),
                QuizOption(id: "not_sure", text: "Not sure"),
                QuizOption(id: "no", text: "No")
            ]
        )
    ]

    // MARK: - Navigation Logic

    private func nextStep(from current: Int) -> Int {
        return current + 1
    }

    private func previousStep(from current: Int) -> Int {
        return current - 1
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0A1628").ignoresSafeArea()

            // Current step
            Group {
                switch currentStep {
                case 1:
                    WelcomeScreen(onContinue: {
                        let transaction = Transaction(animation: nil)
                        withTransaction(transaction) {
                            currentStep = 3
                        }
                    })

                case 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13:
                    // Quiz questions (11 questions, tap to advance)
                    if let question = quizQuestions[currentStep] {
                        QuizQuestionScreen(
                            question: question,
                            progress: progress,
                            onContinue: { answer in
                                quizResponses[question.id] = answer
                                currentStep = nextStep(from: currentStep)
                            },
                            onBack: {
                                if currentStep == 3 {
                                    currentStep = 1
                                } else {
                                    currentStep = previousStep(from: currentStep)
                                }
                            }
                        )
                    }

                case 14:
                    // Name input (end of quiz)
                    NameInputScreen(
                        onContinue: { name in
                            userName = name
                            if !didTrackQuizCompleted {
                                AnalyticsManager.shared.trackQuizCompleted(recoveryScore: quizRecoveryScore)
                                didTrackQuizCompleted = true
                            }
                            currentStep = 15
                        },
                        onBack: { currentStep = 13 },
                        progress: progress
                    )

                case 15:
                    // Calculating screen (auto-advances)
                    CalculatingScreen(
                        onComplete: { currentStep = 16 },
                        onBack: { currentStep = 14 }
                    )

                case 16:
                    // Dependence Analysis result
                    DependenceAnalysisScreen(
                        quizResponses: quizResponses,
                        onContinue: { currentStep = 17 },
                        onBack: { currentStep = 14 } // Skip back past calculating screen
                    )

                case 17:
                    // Symptoms selection
                    SymptomsScreen(
                        onContinue: { symptoms in
                            selectedSymptoms = symptoms
                            currentStep = 18
                        },
                        onBack: { currentStep = 16 }
                    )

                case 18:
                    // Education carousel (4 pain + 1 hope screens)
                    EducationCarouselView(
                        onComplete: { currentStep = 19 },
                        onBack: { currentStep = 17 }
                    )

                case 19:
                    // Solutions carousel (6 benefit screens)
                    SolutionsCarouselView(
                        onComplete: { currentStep = 20 },
                        onBack: { currentStep = 18 }
                    )

                case 20:
                    // Goals intro
                    GoalsIntroScreen(
                        onContinue: { currentStep = 21 },
                        onBack: { currentStep = 19 }
                    )

                case 21:
                    // Goals selection
                    GoalsSelectionScreen(
                        onContinue: { goals in
                            selectedGoals = goals
                            currentStep = 22
                        },
                        onBack: { currentStep = 20 }
                    )

                case 22:
                    // Personalized commitment intro
                    CommitmentIntroScreen(
                        userName: userName,
                        onContinue: { currentStep = 23 },
                        onBack: { currentStep = 21 }
                    )

                case 23:
                    // 3 pledges with hold-to-commit
                    PledgeFlowScreen(
                        onComplete: { currentStep = 24 },
                        onBack: { currentStep = 22 }
                    )

                case 24:
                    // Commitment card (niyyah)
                    CommitmentCardScreen(
                        userName: userName,
                        onCommit: { goalDate in
                            // Save commitment to SwiftData and start streak
                            if !didTrackCommitmentSigned {
                                let daysUntilTarget = Calendar.current.dateComponents([.day], from: Date(), to: goalDate).day ?? 0
                                AnalyticsManager.shared.trackCommitmentSigned(daysUntilTarget: max(0, daysUntilTarget))
                                didTrackCommitmentSigned = true
                            }
                            dataManager.updateUserName(userName)
                            dataManager.signCommitment(targetDate: goalDate)
                            currentStep = 25
                        },
                        onBack: { currentStep = 23 }
                    )

                case 25:
                    // Congratulations after commitment
                    CommitmentCongratulationsScreen(
                        userName: userName,
                        onContinue: { currentStep = 26 }
                    )

                case 26:
                    // Notification permission request
                    NotificationPermissionScreen(
                        onContinue: { currentStep = 27 }
                    )

                case 27:
                    // Rating request with testimonials
                    RatingRequestScreen(
                        onContinue: { currentStep = 28 }
                    )

                case 28:
                    // Typewriter reveal before paywall
                    TypewriterScreen(
                        onContinue: { currentStep = 29 }
                    )

                case 29:
                    // Pre-paywall benefits screen
                    PrePaywallScreen(
                        userName: userName,
                        onContinue: {
                            // If already subscribed (sandbox/restored), skip paywall
                            if subscriptionManager.isSubscribed {
                                dataManager.completeOnboarding()
                                if !didTrackOnboardingCompleted {
                                    AnalyticsManager.shared.trackOnboardingCompleted()
                                    didTrackOnboardingCompleted = true
                                }
                            } else {
                                currentStep = 30
                            }
                        }
                    )
                    .onAppear {
                        // Mark prepaywall seen for resume functionality
                        if !hasSeenPrepaywall {
                            hasSeenPrepaywall = true
                        }
                    }

                case 30:
                    // Paywall - subscription options
                    PaywallScreen(
                        onSubscribe: {
                            // Mark onboarding complete - ContentView will auto-navigate to HomeView
                            dataManager.completeOnboarding()
                            if !didTrackOnboardingCompleted {
                                AnalyticsManager.shared.trackOnboardingCompleted()
                                didTrackOnboardingCompleted = true
                            }
                        },
                        onRestorePurchases: {
                            // Restore purchases and complete onboarding if valid subscription found
                            // TODO: Implement actual StoreKit restore logic
                            dataManager.completeOnboarding()
                            if !didTrackOnboardingCompleted {
                                AnalyticsManager.shared.trackOnboardingCompleted()
                                didTrackOnboardingCompleted = true
                            }
                        },
                        onDismiss: {
                            // Transaction abandon - show win-back paywall
                            showWinBackPaywall = true
                        }
                    )
                    .fullScreenCover(isPresented: $showWinBackPaywall) {
                        WinBackPaywallView(
                            source: .transactionAbandon,
                            onPurchase: {
                                // Successful purchase from win-back
                                showWinBackPaywall = false
                                dataManager.completeOnboarding()
                                if !didTrackOnboardingCompleted {
                                    AnalyticsManager.shared.trackOnboardingCompleted()
                                    didTrackOnboardingCompleted = true
                                }
                            },
                            onDismiss: {
                                // Dismissed win-back - go back to prepaywall
                                showWinBackPaywall = false
                                currentStep = 29
                            }
                        )
                    }

                default:
                    // Placeholder for future steps (24+: Commitment intro, Commitment card, Paywall)
                    VStack(spacing: 20) {
                        OnboardingTopBar(
                            progress: progress,
                            onBack: { currentStep = previousStep(from: currentStep) }
                        )

                        Spacer()

                        Text("Step \(currentStep) of \(totalSteps)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text("Goals Complete!")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(warmAmber)

                        Text("Next: Commitment Intro, Commitment Card, Paywall...")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8A9BAE"))

                        Spacer()

                        OnboardingBottomButton(
                            title: "Continue",
                            isEnabled: true,
                            accentColor: warmAmber
                        ) {
                            currentStep += 1
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentStep)
        .onAppear {
            // Resume at prepaywall if user previously reached it but didn't complete onboarding
            if hasSeenPrepaywall && currentStep == 1 {
                // Resuming - load userName from SwiftData (since @State resets on view recreation)
                userName = dataManager.getOrCreateUser().userName ?? ""
                currentStep = 29
            } else if !didTrackOnboardingStarted {
                // Fresh start - track onboarding analytics (don't double-count on resume)
                AnalyticsManager.shared.trackOnboardingStarted()
                didTrackOnboardingStarted = true
            }
        }
    }
}

#Preview {
    OnboardingFlowView()
}
