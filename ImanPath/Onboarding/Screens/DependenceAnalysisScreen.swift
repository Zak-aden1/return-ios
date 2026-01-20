//
//  DependenceAnalysisScreen.swift
//  ImanPath
//
//  Onboarding Step 17: Shows dependence analysis results
//

import SwiftUI

struct DependenceAnalysisScreen: View {
    let quizResponses: [String: String]
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var showContent: Bool = false
    @State private var userBarHeight: CGFloat = 0
    @State private var avgBarHeight: CGFloat = 0

    private let warmAmber = Color(hex: "C4956A")
    private let mutedText = Color(hex: "8A9BAE")
    private let dangerRed = Color(hex: "EF4444")
    private let successGreen = Color(hex: "10B981")

    // Fixed score - always shows 64% (like Quittr)
    private let dependenceScore: Int = 64

    private let averageScore: Int = 40

    // Exaggerated bar heights for visual impact (like Quittr)
    private let userBarMaxHeight: CGFloat = 200
    private let avgBarMaxHeight: CGFloat = 60

    private var severityMessage: String {
        switch dependenceScore {
        case 70...: return "a significant dependence"
        case 55..<70: return "a clear dependence"
        default: return "signs of dependence"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Simple back button (no progress bar - quiz is done)
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
            .padding(.vertical, 12)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: showContent)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer().frame(height: 8)

                    // Header with checkmark
                    HStack(spacing: 8) {
                        Text("Analysis Complete")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(successGreen)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Subheading
                    Text("We've got some news to break to you...")
                        .font(.system(size: 16))
                        .foregroundColor(mutedText)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                    // Main message
                    Text("Your responses indicate \(severityMessage) on internet porn*")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)

                    Spacer().frame(height: 24)

                    // Bar chart comparison - clean bars, no containers
                    HStack(alignment: .bottom, spacing: 48) {
                        // User score bar
                        VStack(spacing: 12) {
                            // Percentage label above bar
                            Text("\(dependenceScore)%")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(dangerRed)

                            // Just the bar - no container
                            RoundedRectangle(cornerRadius: 10)
                                .fill(dangerRed)
                                .frame(width: 80, height: userBarHeight)

                            Text("Your Score")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(mutedText)
                        }

                        // Average bar
                        VStack(spacing: 12) {
                            // Percentage label above bar
                            Text("\(averageScore)%")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(successGreen)

                            // Just the bar - no container
                            RoundedRectangle(cornerRadius: 10)
                                .fill(successGreen)
                                .frame(width: 80, height: avgBarHeight)

                            Text("Average")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(mutedText)
                        }
                    }
                    .frame(height: userBarMaxHeight + 80) // Space for labels + bar
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)

                    Spacer().frame(height: 12)

                    // Percentage higher callout - shows user's score as the "higher" number
                    HStack(spacing: 6) {
                        Text("\(dependenceScore)%")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(dangerRed)

                        Text("higher dependence on porn")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)

                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 16))
                            .foregroundColor(dangerRed)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.9), value: showContent)

                    // Disclaimer
                    Text("* This result is an indication only, not a medical diagnosis.")
                        .font(.system(size: 12))
                        .foregroundColor(mutedText.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(1.0), value: showContent)

                    Spacer().frame(height: 100)
                }
            }

            // Simple bottom button - no gradient overlay, no card
            VStack(spacing: 0) {
                Button(action: onContinue) {
                    Text("Check your symptoms")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(warmAmber)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(1.1), value: showContent)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            animateBars()
        }
    }

    private func animateBars() {
        // Delay before animating
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Animate user bar to full exaggerated height
            withAnimation(.easeOut(duration: 0.8)) {
                userBarHeight = userBarMaxHeight
            }

            // Animate average bar with slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.8)) {
                    avgBarHeight = avgBarMaxHeight
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()
        DependenceAnalysisScreen(
            quizResponses: [
                "struggle_duration": "5_10",
                "frequency": "few_week",
                "escalation": "yes",
                "quit_pattern": "weeks"
            ],
            onContinue: {},
            onBack: {}
        )
    }
}
