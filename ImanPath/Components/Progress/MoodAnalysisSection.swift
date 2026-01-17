//
//  MoodAnalysisSection.swift
//  ImanPath
//

import SwiftUI

struct MoodAnalysisSection: View {
    let moodData: [RadarDataPoint]

    private let primaryGreen = Color(hex: "74B886")

    // Calculate overall score
    private var overallScore: Int {
        guard !moodData.isEmpty else { return 0 }
        let total = moodData.reduce(0) { $0 + $1.value }
        return Int(total / Double(moodData.count))
    }

    // Get individual scores
    private func scoreFor(_ label: String) -> Int {
        Int(moodData.first { $0.label == label }?.value ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Mood Analysis")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(.white)

            // Subtitle
            Text("See how your emotional well-being is improving over time through your daily check-ins.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "94A3B8"))
                .lineSpacing(2)

            // Encouragement message
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(primaryGreen)

                Text("Continue to complete more check-ins to compare your growth!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "64748B"))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(primaryGreen.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(primaryGreen.opacity(0.2), lineWidth: 1)
                    )
            )

            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                // Row 1
                MoodScoreCard(label: "Overall", score: overallScore, isHighlighted: true, accentColor: primaryGreen)
                MoodScoreCard(label: "Mood", score: scoreFor("Mood"), accentColor: primaryGreen)
                MoodScoreCard(label: "Energy", score: scoreFor("Energy"), accentColor: primaryGreen)

                // Row 2
                MoodScoreCard(label: "Self Control", score: scoreFor("Self Control"), accentColor: primaryGreen)
                MoodScoreCard(label: "Confidence", score: scoreFor("Confidence"), accentColor: primaryGreen)
                MoodScoreCard(label: "Faith", score: scoreFor("Faith"), accentColor: primaryGreen)
            }

            // Chart section
            VStack(spacing: 16) {
                Text("Mood Analysis Chart")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Radar chart
                RadarChartView(
                    data: moodData,
                    accentColor: primaryGreen
                )
                .frame(height: 280)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "0F172A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Mood Score Card
struct MoodScoreCard: View {
    let label: String
    let score: Int
    var isHighlighted: Bool = false
    let accentColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "94A3B8"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(score)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? accentColor : .white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "131C2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isHighlighted ? accentColor.opacity(0.3) : Color(hex: "334155").opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    ScrollView {
        MoodAnalysisSection(
            moodData: [
                RadarDataPoint(label: "Mood", value: 75),
                RadarDataPoint(label: "Energy", value: 60),
                RadarDataPoint(label: "Self Control", value: 85),
                RadarDataPoint(label: "Faith", value: 90),
                RadarDataPoint(label: "Confidence", value: 55)
            ]
        )
        .padding()
    }
    .background(Color(hex: "0A1628"))
}
