//
//  SymptomsScreen.swift
//  ImanPath
//
//  Onboarding Step 18: Symptoms selection
//

import SwiftUI
import UIKit

struct SymptomsScreen: View {
    var onContinue: (Set<String>) -> Void
    var onBack: () -> Void

    @State private var selectedSymptoms: Set<String> = []
    @State private var showContent: Bool = false

    private let warmAmber = Color(hex: "C4956A")
    private let dangerOrange = Color(hex: "F97316")
    private let dangerRed = Color(hex: "EF4444")
    private let cardBg = Color(hex: "1A2332")
    private let mutedText = Color(hex: "8A9BAE")

    // Spiritual first - core differentiator for Islamic recovery app
    private let spiritualSymptoms: [(id: String, text: String, boldWord: String)] = [
        ("distant_allah", "Feeling distant from Allah", "distant"),
        ("guilt_prayer", "Guilt or shame during prayer", "shame"),
        ("avoiding_quran", "Avoiding the Quran", "Quran"),
        ("empty_worship", "Worship feels empty", "empty")
    ]

    private let mentalSymptoms: [(id: String, text: String, boldWord: String)] = [
        ("difficulty_concentrating", "Difficulty concentrating", "concentrating"),
        ("brain_fog", "Poor memory or 'brain fog'", "memory"),
        ("unmotivated", "Feeling unmotivated", "unmotivated"),
        ("anxiety", "General anxiety", "anxiety"),
        ("lack_ambition", "Lack of ambition to pursue goals", "ambition")
    ]

    private let socialSymptoms: [(id: String, text: String, boldWord: String)] = [
        ("withdrawing", "Withdrawing from family or friends", "Withdrawing"),
        ("relationships", "Difficulty maintaining relationships", "relationships"),
        ("isolated", "Feeling isolated or alone", "isolated"),
        ("avoiding_social", "Avoiding social gatherings", "Avoiding")
    ]

    private let physicalSymptoms: [(id: String, text: String, boldWord: String)] = [
        ("fatigue", "Fatigue or low energy", "Fatigue"),
        ("sleep_issues", "Sleep problems or insomnia", "Sleep"),
        ("neglecting_health", "Neglecting physical health", "Neglecting"),
        ("restlessness", "Restlessness or tension", "Restlessness")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button and title
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }

                Spacer()

                Text("Symptoms")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                // Invisible spacer for centering
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: showContent)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Warning banner
                    Text("Excessive porn use can have negative impacts psychologically.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(dangerOrange)
                        )
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Instruction
                    Text("Select any symptoms below:")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                    // Spiritual symptoms section (first - core differentiator)
                    symptomSection(
                        title: "Spiritual",
                        symptoms: spiritualSymptoms,
                        baseDelay: 0.35
                    )

                    // Mental symptoms section
                    symptomSection(
                        title: "Mental",
                        symptoms: mentalSymptoms,
                        baseDelay: 0.5
                    )

                    // Social symptoms section
                    symptomSection(
                        title: "Social",
                        symptoms: socialSymptoms,
                        baseDelay: 0.65
                    )

                    // Physical symptoms section
                    symptomSection(
                        title: "Physical",
                        symptoms: physicalSymptoms,
                        baseDelay: 0.8
                    )

                    Spacer().frame(height: 100)
                }
                .padding(.top, 8)
            }

            // Bottom button with gradient background
            VStack(spacing: 0) {
                // Gradient fade for visual anchoring
                LinearGradient(
                    colors: [
                        Color(hex: "0A1628").opacity(0),
                        Color(hex: "0A1628").opacity(0.8),
                        Color(hex: "0A1628")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)

                Button(action: {
                    triggerHaptic(.medium)
                    onContinue(selectedSymptoms)
                }) {
                    Text("Let's break the cycle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(selectedSymptoms.isEmpty ? dangerRed.opacity(0.4) : dangerRed)
                        )
                }
                .disabled(selectedSymptoms.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: selectedSymptoms.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .background(Color(hex: "0A1628"))
            }
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(1.0), value: showContent)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }

    @ViewBuilder
    private func symptomSection(
        title: String,
        symptoms: [(id: String, text: String, boldWord: String)],
        baseDelay: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(mutedText)
                .padding(.horizontal, 20)

            VStack(spacing: 10) {
                ForEach(Array(symptoms.enumerated()), id: \.element.id) { index, symptom in
                    SymptomCard(
                        text: symptom.text,
                        boldWord: symptom.boldWord,
                        isSelected: selectedSymptoms.contains(symptom.id)
                    ) {
                        triggerHaptic(.light)
                        if selectedSymptoms.contains(symptom.id) {
                            selectedSymptoms.remove(symptom.id)
                        } else {
                            selectedSymptoms.insert(symptom.id)
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.4).delay(baseDelay + Double(index) * 0.05), value: showContent)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Symptom Card
private struct SymptomCard: View {
    let text: String
    let boldWord: String
    let isSelected: Bool
    let action: () -> Void

    private let cardBg = Color(hex: "1A2332")
    private let dangerOrange = Color(hex: "F97316")

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Circle checkbox
                ZStack {
                    Circle()
                        .stroke(isSelected ? dangerOrange : Color(hex: "334155"), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isSelected {
                        Circle()
                            .fill(dangerOrange)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Text with bold word
                formattedText
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? dangerOrange : Color(hex: "334155").opacity(0.5), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(SymptomButtonStyle())
    }

    private var formattedText: Text {
        // Split text and bold the specific word
        if let range = text.range(of: boldWord, options: .caseInsensitive) {
            let before = String(text[..<range.lowerBound])
            let bold = String(text[range])
            let after = String(text[range.upperBound...])
            return Text(before) + Text(bold).fontWeight(.bold) + Text(after)
        }
        return Text(text)
    }
}

private struct SymptomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()
        SymptomsScreen(
            onContinue: { _ in },
            onBack: {}
        )
    }
}
