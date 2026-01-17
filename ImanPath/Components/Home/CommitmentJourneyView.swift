//
//  CommitmentJourneyView.swift
//  ImanPath
//

import SwiftUI

struct CommitmentJourneyView: View {
    let currentDay: Int
    let commitmentDays: Int

    @State private var isPulsing = false
    @State private var hasAppeared = false

    private let primaryGreen = Color(hex: "74B886")
    private let trackColor = Color(hex: "1E293B")
    private let mutedText = Color(hex: "64748B")

    private var progress: CGFloat {
        min(CGFloat(currentDay) / CGFloat(commitmentDays), 1.0)
    }

    private var daysRemaining: Int {
        max(commitmentDays - currentDay, 0)
    }

    private var progressPercent: Int {
        Int(progress * 100)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Progress Track
            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                let orbX = trackWidth * (hasAppeared ? progress : 0)

                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(trackColor)
                        .frame(height: 3)

                    // Filled track with glow
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [primaryGreen.opacity(0.6), primaryGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(orbX, 0), height: 3)
                        .shadow(color: primaryGreen.opacity(0.4), radius: 8, x: 0, y: 0)

                // Milestone markers (commitment progress)
                ForEach(MilestoneCatalog.commitmentDays, id: \.self) { milestone in
                        let milestoneX = trackWidth * (CGFloat(milestone) / CGFloat(commitmentDays))

                        Circle()
                            .fill(currentDay >= milestone ? primaryGreen : trackColor)
                            .frame(width: 6, height: 6)
                            .overlay(
                                Circle()
                                    .stroke(currentDay >= milestone ? primaryGreen.opacity(0.3) : Color.clear, lineWidth: 2)
                            )
                            .position(x: milestoneX, y: 10)
                    }

                    // Glowing journey orb
                    Circle()
                        .fill(primaryGreen)
                        .frame(width: 14, height: 14)
                        .shadow(color: primaryGreen.opacity(isPulsing ? 0.9 : 0.5), radius: isPulsing ? 12 : 6)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 6, height: 6)
                                .offset(x: -2, y: -2)
                        )
                        .position(x: max(orbX, 7), y: 10)

                    // Destination crescent
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(daysRemaining == 0 ? primaryGreen : mutedText)
                        .position(x: trackWidth - 2, y: 10)
                }
            }
            .frame(height: 20)

            // Labels row
            HStack {
                // Start
                Text("0%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(mutedText)

                Spacer()

                // Current progress
                Text("\(progressPercent)% complete")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(primaryGreen)

                Spacer()

                // Goal
                Text("100%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(mutedText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "0F172A").opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                hasAppeared = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    CommitmentJourneyView(currentDay: 86, commitmentDays: 90)
        .padding()
        .background(Color(hex: "0A1628"))
}
