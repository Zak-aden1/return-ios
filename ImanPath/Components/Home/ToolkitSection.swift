//
//  ToolkitSection.swift
//  ImanPath
//

import SwiftUI

struct ToolkitSection: View {
    var onMyWhyTap: () -> Void = {}
    var onJournalTap: () -> Void = {}
    var onDuasTap: () -> Void = {}
    var onBreathingTap: () -> Void = {}
    var onGroundingTap: () -> Void = {}

    @State private var showBlockerAlert: Bool = false
    @State private var showAccountabilityAlert: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // Section header with lines
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color(hex: "334155"))
                    .frame(height: 1)

                Text("Toolkit")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .fixedSize()

                Rectangle()
                    .fill(Color(hex: "334155"))
                    .frame(height: 1)
            }

            // Horizontal scroll of tools
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // My Why - first and prominent
                    ToolkitCard(
                        icon: "heart.text.square.fill",
                        title: "My Why",
                        subtitle: "Your reasons",
                        color: Color(hex: "E8B86D")
                    ) { onMyWhyTap() }

                    ToolkitCard(
                        icon: "book.fill",
                        title: "Journal",
                        subtitle: "Write your thoughts",
                        color: Color(hex: "74B886")
                    ) { onJournalTap() }

                    ToolkitCard(
                        icon: "hands.sparkles.fill",
                        title: "Duas",
                        subtitle: "Prayers for strength",
                        color: Color(hex: "60A5FA")
                    ) { onDuasTap() }

                    ToolkitCard(
                        icon: "wind",
                        title: "Breathing",
                        subtitle: "Calm your mind",
                        color: Color(hex: "74B886")
                    ) { onBreathingTap() }

                    ToolkitCard(
                        icon: "hand.raised.fingers.spread.fill",
                        title: "Grounding",
                        subtitle: "5-4-3-2-1 technique",
                        color: Color(hex: "5B9A9A")
                    ) { onGroundingTap() }

                    ToolkitCard(
                        icon: "shield.checkered",
                        title: "Blocker",
                        subtitle: "Coming soon",
                        color: Color(hex: "F59E0B")
                    ) { showBlockerAlert = true }

                    ToolkitCard(
                        icon: "person.2.fill",
                        title: "Accountability",
                        subtitle: "Coming soon",
                        color: Color(hex: "A78BFA")
                    ) { showAccountabilityAlert = true }
                }
            }
        }
        .alert("Content Blocker", isPresented: $showBlockerAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Content blocking is coming soon. This feature will help you block harmful websites and apps using Screen Time.")
        }
        .alert("Accountability Partner", isPresented: $showAccountabilityAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Accountability partners are coming soon. You'll be able to invite a trusted person to support your journey.")
        }
    }
}

struct ToolkitCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "64748B"))
                }
            }
            .frame(width: 120)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "131C2D"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ToolkitSection()
        .padding()
        .background(Color(hex: "0A1628"))
}
