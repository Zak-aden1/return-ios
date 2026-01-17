//
//  JourneyRingView.swift
//  ImanPath
//

import SwiftUI

struct JourneyRingView: View {
    let currentDay: Int
    let totalDays: Int
    let accentColor: Color

    @State private var animationProgress: Double = 0

    private var percentage: Int {
        Int((Double(currentDay) / Double(totalDays)) * 100)
    }

    private var progress: Double {
        min(Double(currentDay) / Double(totalDays), 1.0)
    }

    // Calculate completion date
    private var goalDate: String {
        let daysRemaining = max(totalDays - currentDay, 0)
        let targetDate = Calendar.current.date(byAdding: .day, value: daysRemaining, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: targetDate)
    }

    // Arc configuration
    private let arcStartAngle: Double = 135  // 7 o'clock position
    private let arcEndAngle: Double = 405    // 5 o'clock position (135 + 270)
    private let arcSpan: Double = 270        // Total degrees of the arc
    private let strokeWidth: CGFloat = 14
    private let arcSize: CGFloat = 220       // Increased for more room

    var body: some View {
        // Arc container - label now inside
        ZStack {
                // Background track
                Circle()
                    .trim(from: 0, to: arcSpan / 360)
                    .stroke(
                        Color(hex: "1E293B"),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(arcStartAngle))
                    .frame(width: arcSize, height: arcSize)

                // Progress arc
                Circle()
                    .trim(from: 0, to: (arcSpan / 360) * progress * animationProgress)
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.8), accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(arcStartAngle))
                    .frame(width: arcSize, height: arcSize)
                    .shadow(color: accentColor.opacity(0.4), radius: 8, x: 0, y: 0)

                // Progress indicator dot
                Circle()
                    .fill(accentColor)
                    .frame(width: 18, height: 18)
                    .shadow(color: accentColor.opacity(0.6), radius: 6, x: 0, y: 0)
                    .offset(x: dotOffset.x, y: dotOffset.y)

            // Center content
            VStack(spacing: 6) {
                // Label - now inside the ring
                Text("Journey Completion")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "64748B"))

                // Percentage
                Text("\(Int(Double(percentage) * animationProgress))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())

                // Goal pill
                HStack(spacing: 6) {
                    Text("🎯")
                        .font(.system(size: 12))
                    Text("Goal: \(goalDate)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "94A3B8"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(hex: "1E293B"))
                )
            }
            .offset(y: 8)
        }
        .frame(width: arcSize + 40, height: arcSize + 20)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }

    // Calculate dot position on the arc
    private var dotOffset: (x: CGFloat, y: CGFloat) {
        let currentAngle = arcStartAngle + (arcSpan * progress * animationProgress)
        let angleInRadians = currentAngle * .pi / 180
        let radius = arcSize / 2

        let x = cos(angleInRadians) * radius
        let y = sin(angleInRadians) * radius

        return (x, y)
    }
}

#Preview {
    VStack(spacing: 40) {
        JourneyRingView(
            currentDay: 1,
            totalDays: 90,
            accentColor: Color(hex: "74B886")
        )

        JourneyRingView(
            currentDay: 45,
            totalDays: 90,
            accentColor: Color(hex: "74B886")
        )

        JourneyRingView(
            currentDay: 86,
            totalDays: 90,
            accentColor: Color(hex: "74B886")
        )
    }
    .padding()
    .background(Color(hex: "0A1628"))
}
