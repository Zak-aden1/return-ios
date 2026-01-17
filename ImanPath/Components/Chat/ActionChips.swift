//
//  ActionChips.swift
//  ImanPath
//
//  Quick action buttons for Streak Coach responses
//

import SwiftUI

struct ActionChips: View {
    var suggestedAction: String?
    var onBreathing: () -> Void = {}
    var onJournal: () -> Void = {}
    var onCheckIn: () -> Void = {}
    var onPanic: () -> Void = {}
    var onDua: () -> Void = {}

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ActionChip(
                    icon: "wind",
                    label: "Breathing",
                    isHighlighted: suggestedAction == "breathing",
                    action: onBreathing
                )

                ActionChip(
                    icon: "book.fill",
                    label: "Journal",
                    isHighlighted: suggestedAction == "journal",
                    action: onJournal
                )

                ActionChip(
                    icon: "checkmark.circle.fill",
                    label: "Check-in",
                    isHighlighted: suggestedAction == "checkin",
                    action: onCheckIn
                )

                ActionChip(
                    icon: "exclamationmark.shield.fill",
                    label: "Panic",
                    isHighlighted: suggestedAction == "panic",
                    action: onPanic
                )

                ActionChip(
                    icon: "hands.sparkles.fill",
                    label: "Dua",
                    isHighlighted: suggestedAction == "dua",
                    action: onDua
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

struct ActionChip: View {
    let icon: String
    let label: String
    var isHighlighted: Bool = false
    let action: () -> Void

    private let highlightColor = Color(hex: "74B886")
    private let normalBg = Color(hex: "1A2737")
    private let highlightBg = Color(hex: "1E3A2F")

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))

                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isHighlighted ? highlightColor : Color(hex: "94A3B8"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isHighlighted ? highlightBg : normalBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isHighlighted ? highlightColor.opacity(0.5) : Color(hex: "334155"),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        ActionChips(suggestedAction: "breathing")
        ActionChips(suggestedAction: nil)
    }
    .padding(.vertical, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
