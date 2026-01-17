//
//  DailyVerseCard.swift
//  ImanPath
//

import SwiftUI

struct DailyVerseCard: View {
    let verse: String
    let reference: String

    private let primaryGreen = Color(hex: "74B886")

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "151E32"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )

            // Quote icon
            Image(systemName: "quote.opening")
                .font(.system(size: 32, weight: .thin))
                .foregroundColor(.white.opacity(0.1))
                .padding(.top, 16)
                .padding(.trailing, 16)

            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text("DAILY VERSE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(Color(hex: "94A3B8").opacity(0.6))

                Text("\"\(verse)\"")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "E0E7EB"))
                    .lineSpacing(4)

                Text(reference)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(primaryGreen)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }
}

#Preview {
    DailyVerseCard(
        verse: "Verily, with hardship comes ease.",
        reference: "Quran 94:6"
    )
    .padding()
    .background(Color(hex: "0A1628"))
}
