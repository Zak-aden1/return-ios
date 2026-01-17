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
        HStack(alignment: .center) {
            // Logo - RETURN with diagonal slash
            ReturnLogo()

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

// MARK: - Return Logo

struct ReturnLogo: View {
    var body: some View {
        Image("ReturnLogo")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 36)
            .foregroundColor(.white)
    }
}

#Preview {
    HeaderView(streakBadge: 12)
        .padding()
        .background(Color(hex: "0A1628"))
}

#Preview("Logo Only") {
    ReturnLogo()
        .padding(40)
        .background(Color(hex: "0A1628"))
}
