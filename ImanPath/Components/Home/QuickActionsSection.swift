//
//  QuickActionsSection.swift
//  ImanPath
//

import SwiftUI

struct QuickActionsSection: View {
    var onCheckInTap: () -> Void = {}
    var onProgressTap: () -> Void = {}
    var onCommunityTap: () -> Void = {}
    var onChatTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 24) {
            QuickActionButton(icon: "calendar.badge.checkmark", label: "Check-in", action: onCheckInTap)
            QuickActionButton(icon: "chart.line.uptrend.xyaxis", label: "Progress", action: onProgressTap)
            QuickActionButton(icon: "person.3.fill", label: "Community", action: onCommunityTap)
            QuickActionButton(icon: "bubble.left.fill", label: "Chat", action: onChatTap)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    private let primaryGreen = Color(hex: "74B886")

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "131C2D"))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "334155"), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "CBD5E1"))
                }

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "94A3B8"))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuickActionsSection()
        .padding()
        .background(Color(hex: "0A1628"))
}
