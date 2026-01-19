//
//  ChecklistSection.swift
//  ImanPath
//

import SwiftUI
import UIKit

struct ChecklistSection: View {
    var onMyWhyTap: () -> Void = {}

    // Telegram community link
    private let communityURL = "https://t.me/+jjOxY8c7g10zNjI0"

    @State private var notificationsEnabled = false
    @State private var communityJoined = false
    @State private var myWhySetUp = false

    private var completedCount: Int {
        [notificationsEnabled, communityJoined, myWhySetUp].filter { $0 }.count
    }

    private var allCompleted: Bool {
        completedCount == 3
    }

    var body: some View {
        // Hide section when all completed
        if !allCompleted {
            VStack(spacing: 16) {
                // Section header with lines
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color(hex: "334155"))
                        .frame(height: 1)

                    HStack(spacing: 6) {
                        Text("Checklist")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("\(completedCount)/3")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                    .fixedSize()

                    Rectangle()
                        .fill(Color(hex: "334155"))
                        .frame(height: 1)
                }

                // Checklist card
                VStack(spacing: 0) {
                    ChecklistItem(
                        icon: "bell.fill",
                        title: "Enable notifications",
                        subtitle: "Get daily reminders to stay on track.",
                        cta: "Tap to enable.",
                        isCompleted: notificationsEnabled
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            notificationsEnabled = true
                        }
                        // TODO: Actually request notification permission
                    }

                    Divider()
                        .background(Color(hex: "334155"))

                    ChecklistItem(
                        icon: "person.3.fill",
                        title: "Join community",
                        subtitle: "Connect with others on the same journey.",
                        cta: "Tap to join.",
                        isCompleted: communityJoined
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            communityJoined = true
                        }
                        if let url = URL(string: communityURL) {
                            UIApplication.shared.open(url)
                        }
                    }

                    Divider()
                        .background(Color(hex: "334155"))

                    ChecklistItem(
                        icon: "heart.text.square.fill",
                        title: "Set up My Why",
                        subtitle: "Define your reasons for this journey.",
                        cta: "Tap to add.",
                        isCompleted: myWhySetUp
                    ) {
                        onMyWhyTap()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "131C2D"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

struct ChecklistItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let cta: String
    let isCompleted: Bool
    let action: () -> Void

    private let primaryGreen = Color(hex: "74B886")

    var body: some View {
        Button(action: {
            if !isCompleted {
                action()
            }
        }) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? primaryGreen.opacity(0.2) : Color(hex: "1E293B"))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(isCompleted ? primaryGreen : Color(hex: "64748B"))
                }

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isCompleted ? Color(hex: "64748B") : .white)
                        .strikethrough(isCompleted, color: Color(hex: "64748B"))

                    // Subtitle with bold CTA
                    (Text(subtitle + " ")
                        .foregroundColor(Color(hex: "64748B"))
                    + Text(cta)
                        .foregroundColor(Color(hex: "8A9BAE"))
                        .fontWeight(.semibold))
                        .font(.system(size: 12))
                        .lineSpacing(2)
                }

                Spacer()

                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isCompleted ? primaryGreen : Color(hex: "334155"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isCompleted {
                        Circle()
                            .fill(primaryGreen)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChecklistSection()
        .padding()
        .background(Color(hex: "0A1628"))
}
