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

    @State private var currentStep: Int = 1
    private let totalSteps = 32

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

    // Colors
    private let warmAmber = Color(hex: "C4956A")

    private var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    // Check if relationship impact question should be shown
    private var shouldShowRelationshipImpact: Bool {
        let status = quizResponses["relationship_status"] ?? ""
        return status == "married" || status == "engaged"
    }

    // MARK: - Quiz Questions Data

    private let quizQuestions: [Int: QuizQuestion] = [
        // Step 3: Age
        3: QuizQuestion(
            id: "age",
            question: "How old are you?",
            subtitle: "This helps us personalize your experience",
            options: [
                QuizOption(id: "under_18", text: "Under 18"),
                QuizOption(id: "18_24", text: "18-24"),
                QuizOption(id: "25_34", text: "25-34"),
                QuizOption(id: "35_44", text: "35-44"),
                QuizOption(id: "45_plus", text: "45+")
            ]
        ),
        // Step 4: Gender
        4: QuizQuestion(
            id: "gender",
            question: "What is your gender?",
            subtitle: nil,
            options: [
                QuizOption(id: "male", text: "Male"),
                QuizOption(id: "female", text: "Female")
            ]
        ),
        // Step 5: Struggle duration
        5: QuizQuestion(
            id: "struggle_duration",
            question: "How long have you struggled with this?",
            subtitle: "Be honest — this helps us help you",
            options: [
                QuizOption(id: "less_1", text: "Less than 1 year"),
                QuizOption(id: "1_3", text: "1-3 years"),
                QuizOption(id: "3_5", text: "3-5 years"),
                QuizOption(id: "5_10", text: "5-10 years"),
                QuizOption(id: "10_plus", text: "10+ years")
            ]
        ),
        // Step 6: Frequency
        6: QuizQuestion(
            id: "frequency",
            question: "How often do you watch porn?",
            subtitle: nil,
            options: [
                QuizOption(id: "daily", text: "Daily"),
                QuizOption(id: "few_week", text: "Few times a week"),
                QuizOption(id: "weekly", text: "Weekly"),
                QuizOption(id: "few_month", text: "Few times a month"),
                QuizOption(id: "rarely", text: "Rarely")
            ]
        ),
        // Step 7: Escalation
        7: QuizQuestion(
            id: "escalation",
            question: "Has the content you watch become more extreme over time?",
            subtitle: "This is a common sign of addiction",
            options: [
                QuizOption(id: "yes", text: "Yes"),
                QuizOption(id: "no", text: "No"),
                QuizOption(id: "not_sure", text: "Not sure")
            ]
        ),
        // Step 8: Relationship status
        8: QuizQuestion(
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
        // Step 9: Relationship impact (conditional - only if married/engaged)
        9: QuizQuestion(
            id: "relationship_impact",
            question: "Has this affected your relationship or marriage?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes_significantly", text: "Yes, significantly"),
                QuizOption(id: "somewhat", text: "Somewhat"),
                QuizOption(id: "no", text: "No"),
                QuizOption(id: "partner_unaware", text: "My partner doesn't know")
            ]
        ),
        // Step 10: Connection to Allah
        10: QuizQuestion(
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
        // Step 11: Porn's spiritual impact
        11: QuizQuestion(
            id: "porn_distance_allah",
            question: "Has watching porn made you feel distant from Allah?",
            subtitle: nil,
            options: [
                QuizOption(id: "yes_very", text: "Yes, very much"),
                QuizOption(id: "yes_somewhat", text: "Yes, somewhat"),
                QuizOption(id: "not_sure", text: "Not sure"),
                QuizOption(id: "no", text: "No")
            ]
        ),
        // Step 12: Guilt/shame
        12: QuizQuestion(
            id: "guilt_shame",
            question: "Do you feel guilt or shame after watching?",
            subtitle: nil,
            options: [
                QuizOption(id: "always", text: "Always"),
                QuizOption(id: "sometimes", text: "Sometimes"),
                QuizOption(id: "rarely", text: "Rarely"),
                QuizOption(id: "never", text: "Never")
            ]
        ),
        // Step 13: Repentance
        13: QuizQuestion(
            id: "repentance",
            question: "Do you repent after relapsing?",
            subtitle: nil,
            options: [
                QuizOption(id: "always", text: "Always"),
                QuizOption(id: "sometimes", text: "Sometimes"),
                QuizOption(id: "rarely", text: "Rarely"),
                QuizOption(id: "stopped", text: "I've stopped trying")
            ]
        ),
        // Step 14: Quit attempts
        14: QuizQuestion(
            id: "quit_attempts",
            question: "Have you tried to quit before?",
            subtitle: nil,
            options: [
                QuizOption(id: "many_times", text: "Yes, many times"),
                QuizOption(id: "few_times", text: "Yes, a few times"),
                QuizOption(id: "first_time", text: "This is my first time")
            ]
        ),
        // Step 15: Quit pattern
        15: QuizQuestion(
            id: "quit_pattern",
            question: "What happens when you try to quit?",
            subtitle: "Understanding your pattern helps us help you",
            options: [
                QuizOption(id: "days", text: "I relapse within days"),
                QuizOption(id: "weeks", text: "I last a few weeks"),
                QuizOption(id: "months", text: "I can go months but always come back")
            ]
        )
    ]

    // MARK: - Navigation Logic

    private func nextStep(from current: Int, answer: String? = nil) -> Int {
        // Special case: After relationship status (step 8)
        // Skip relationship impact (step 9) if not married/engaged
        if current == 8 {
            if let status = answer, status == "married" || status == "engaged" {
                return 9 // Show relationship impact
            } else {
                return 10 // Skip to Allah connection
            }
        }
        return current + 1
    }

    private func previousStep(from current: Int) -> Int {
        // Special case: Going back from step 10
        // Skip step 9 if user wasn't married/engaged
        if current == 10 && !shouldShowRelationshipImpact {
            return 8
        }
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
                    WelcomeScreen(onContinue: { currentStep = 2 })

                case 2:
                    WhyHereScreen(
                        onContinue: { reasons in
                            selectedReasons = reasons
                            currentStep = 3
                        },
                        onBack: { currentStep = 1 },
                        progress: progress
                    )

                case 3, 4, 5, 6, 7, 8:
                    if let question = quizQuestions[currentStep] {
                        QuizQuestionScreen(
                            question: question,
                            progress: progress,
                            onContinue: { answer in
                                quizResponses[question.id] = answer
                                currentStep = nextStep(from: currentStep, answer: answer)
                            },
                            onBack: { currentStep = previousStep(from: currentStep) }
                        )
                    }

                case 9:
                    // Relationship impact (conditional)
                    if let question = quizQuestions[9] {
                        QuizQuestionScreen(
                            question: question,
                            progress: progress,
                            onContinue: { answer in
                                quizResponses[question.id] = answer
                                currentStep = 10
                            },
                            onBack: { currentStep = 8 }
                        )
                    }

                case 10, 11, 12, 13, 14, 15:
                    if let question = quizQuestions[currentStep] {
                        QuizQuestionScreen(
                            question: question,
                            progress: progress,
                            onContinue: { answer in
                                quizResponses[question.id] = answer
                                currentStep = currentStep + 1
                            },
                            onBack: { currentStep = previousStep(from: currentStep) }
                        )
                    }

                case 16:
                    // Name input (end of quiz)
                    NameInputScreen(
                        onContinue: { name in
                            userName = name
                            currentStep = 17
                        },
                        onBack: { currentStep = 15 },
                        progress: progress
                    )

                case 17:
                    // Calculating screen (auto-advances)
                    CalculatingScreen(
                        onComplete: { currentStep = 18 },
                        onBack: { currentStep = 16 }
                    )

                case 18:
                    // Dependence Analysis result
                    DependenceAnalysisScreen(
                        quizResponses: quizResponses,
                        onContinue: { currentStep = 19 },
                        onBack: { currentStep = 16 } // Skip back past calculating screen
                    )

                case 19:
                    // Symptoms selection
                    SymptomsScreen(
                        onContinue: { symptoms in
                            selectedSymptoms = symptoms
                            currentStep = 20
                        },
                        onBack: { currentStep = 18 }
                    )

                case 20:
                    // Education carousel (4 pain + 1 hope screens)
                    EducationCarouselView(
                        onComplete: { currentStep = 21 },
                        onBack: { currentStep = 19 }
                    )

                case 21:
                    // Solutions carousel (6 benefit screens)
                    SolutionsCarouselView(
                        onComplete: { currentStep = 22 },
                        onBack: { currentStep = 20 }
                    )

                case 22:
                    // Goals intro
                    GoalsIntroScreen(
                        onContinue: { currentStep = 23 },
                        onBack: { currentStep = 21 }
                    )

                case 23:
                    // Goals selection
                    GoalsSelectionScreen(
                        onContinue: { goals in
                            selectedGoals = goals
                            currentStep = 24
                        },
                        onBack: { currentStep = 22 }
                    )

                case 24:
                    // Personalized commitment intro
                    CommitmentIntroScreen(
                        userName: userName,
                        onContinue: { currentStep = 25 },
                        onBack: { currentStep = 23 }
                    )

                case 25:
                    // 3 pledges with hold-to-commit
                    PledgeFlowScreen(
                        onComplete: { currentStep = 26 },
                        onBack: { currentStep = 24 }
                    )

                case 26:
                    // Commitment card (niyyah)
                    CommitmentCardScreen(
                        userName: userName,
                        onCommit: { goalDate in
                            // Save commitment to SwiftData and start streak
                            dataManager.updateUserName(userName)
                            dataManager.signCommitment(targetDate: goalDate)
                            currentStep = 27
                        },
                        onBack: { currentStep = 25 }
                    )

                case 27:
                    // Congratulations after commitment
                    CommitmentCongratulationsScreen(
                        userName: userName,
                        onContinue: { currentStep = 28 }
                    )

                case 28:
                    // Notification permission request
                    NotificationPermissionScreen(
                        onContinue: { currentStep = 29 }
                    )

                case 29:
                    // Rating request with testimonials
                    RatingRequestScreen(
                        onContinue: { currentStep = 30 }
                    )

                case 30:
                    // Typewriter reveal before paywall
                    TypewriterScreen(
                        onContinue: { currentStep = 31 }
                    )

                case 31:
                    // Pre-paywall benefits screen
                    PrePaywallScreen(
                        userName: userName,
                        onContinue: { currentStep = 32 }
                    )

                case 32:
                    // Paywall - subscription options
                    PaywallScreen(
                        onSubscribe: {
                            // Mark onboarding complete - ContentView will auto-navigate to HomeView
                            dataManager.completeOnboarding()
                        },
                        onRestorePurchases: {
                            // Restore purchases and complete onboarding if valid subscription found
                            // TODO: Implement actual StoreKit restore logic
                            dataManager.completeOnboarding()
                        }
                    )

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
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .animation(.easeInOut(duration: 0.35), value: currentStep)
    }
}

#Preview {
    OnboardingFlowView()
}
