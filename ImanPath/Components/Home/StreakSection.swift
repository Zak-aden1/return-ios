//
//  StreakSection.swift
//  ImanPath
//

import SwiftUI

struct StreakSection: View {
    let days: Int
    let timerString: String

    var body: some View {
        VStack(spacing: 4) {
            Text("You have been clean for")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "94A3B8"))

            // Big number + Days on same row
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(days)")
                    .font(.system(size: 72, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("Days")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .foregroundColor(.white)

                Text("✨")
                    .font(.system(size: 16))
                    .offset(y: -24)
            }

            // Timer pill
            Text(timerString)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hex: "CBD5E1"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "131C2D").opacity(0.5))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "334155"), lineWidth: 1)
                )
                .padding(.top, 16)
        }
    }
}

#Preview {
    StreakSection(days: 86, timerString: "16h 46m 45s")
        .background(Color(hex: "0A1628"))
}
