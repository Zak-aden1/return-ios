//
//  DailyCheckInCard.swift
//  ImanPath
//

import SwiftUI

struct DailyCheckInCard: View {
    var onTap: () -> Void = {}
    var isCheckedInToday: Bool = false
    var todayScore: Int = 0

    private let primaryGreen = Color(hex: "74B886")
    private let cardBg = Color(hex: "0F172A")

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Green accent bar when completed
                if isCheckedInToday {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(primaryGreen)
                        .frame(width: 4)
                        .padding(.vertical, 12)
                        .padding(.leading, 4)
                }

                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        if isCheckedInToday {
                            // Filled success circle with glow
                            Circle()
                                .fill(primaryGreen)
                                .frame(width: 44, height: 44)
                                .shadow(color: primaryGreen.opacity(0.4), radius: 8, x: 0, y: 0)

                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .fill(Color(hex: "1E293B"))
                                .frame(width: 44, height: 44)

                            Circle()
                                .stroke(Color(hex: "334155"), lineWidth: 1)
                                .frame(width: 44, height: 44)

                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "64748B"))
                        }
                    }

                    // Text
                    VStack(alignment: .leading, spacing: 4) {
                        if isCheckedInToday {
                            Text("Today's check-in complete")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            Text("Great job honoring your commitment")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color(hex: "8A9BAE"))
                        } else {
                            Text("Daily Check-In")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)

                            Text("Tap to log how you're feeling")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color(hex: "8A9BAE"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Chevron (always visible for tap affordance)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isCheckedInToday ? primaryGreen.opacity(0.6) : Color(hex: "64748B"))
                }
                .padding(.horizontal, isCheckedInToday ? 12 : 16)
                .padding(.vertical, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCheckedInToday ? cardBg.opacity(0.8) : cardBg.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCheckedInToday ? primaryGreen.opacity(0.3) : Color(hex: "334155").opacity(0.5),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        // Not checked in
        DailyCheckInCard(isCheckedInToday: false)

        // Checked in with score
        DailyCheckInCard(isCheckedInToday: true, todayScore: 64)
    }
    .padding()
    .background(Color(hex: "0A1628"))
}
