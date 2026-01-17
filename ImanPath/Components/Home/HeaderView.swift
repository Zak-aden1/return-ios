//
//  HeaderView.swift
//  ImanPath
//

import SwiftUI

struct HeaderView: View {
    let streakBadge: Int
    var onProfileTap: () -> Void = {}

    private let primaryGreen = Color(hex: "74B886")

    var body: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(primaryGreen.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 14))
                        .foregroundColor(primaryGreen)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Tazkiyah")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Text("PURIFICATION")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(Color(hex: "94A3B8"))
                }
            }

            Spacer()

            // Streak badge + Avatar
            HStack(spacing: 12) {
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(primaryGreen)
                    Text("\(streakBadge)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(primaryGreen)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(primaryGreen.opacity(0.1))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(primaryGreen.opacity(0.2), lineWidth: 1)
                )

                // Avatar (tappable)
                Button(action: onProfileTap) {
                    Circle()
                        .fill(Color(hex: "1E293B"))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(hex: "64748B"))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "334155"), lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    HeaderView(streakBadge: 12)
        .padding()
        .background(Color(hex: "0A1628"))
}
