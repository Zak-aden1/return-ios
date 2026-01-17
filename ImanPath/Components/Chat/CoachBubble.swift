//
//  CoachBubble.swift
//  ImanPath
//
//  Chat message bubble with citation support for Streak Coach
//

import SwiftUI

struct CoachBubble: View {
    let message: ChatMessage
    let citationMap: CitationMap
    var onCitationTap: ((String) -> Void)?
    var onRetry: (() -> Void)?

    private var isUser: Bool { message.sender == .user }
    private var isError: Bool { message.isError }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !isUser {
                coachAvatar
            } else {
                Spacer(minLength: 60)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
                // Message content
                HStack(spacing: 8) {
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(isError ? Color(hex: "F87171") : (isUser ? .white : Color(hex: "E2E8F0")))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isError ? Color(hex: "7F1D1D").opacity(0.3) : (isUser ? Color(hex: "2563EB") : Color(hex: "1A2737")))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isError ? Color(hex: "F87171").opacity(0.5) : Color.clear, lineWidth: 1)
                        )

                    // Retry button for errors
                    if isError, let onRetry = onRetry {
                        Button(action: onRetry) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "F87171"))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "7F1D1D").opacity(0.3))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Citations (assistant only, not for errors)
                if !isUser && !message.citations.isEmpty && !isError {
                    citationChips
                }

                // Timestamp
                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "64748B"))
            }

            if isUser {
                Spacer().frame(width: 4)
            } else {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
    }

    // MARK: - Subviews

    private var coachAvatar: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "1E3A5F"))
                .frame(width: 32, height: 32)

            Image(systemName: "sparkles")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "74B886"))
        }
    }

    private var citationChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(message.citations, id: \.self) { citationId in
                    CitationChip(
                        label: labelFor(citationId),
                        icon: iconFor(citationId)
                    ) {
                        onCitationTap?(citationId)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func labelFor(_ citationId: String) -> String {
        if citationId.hasPrefix("journal:") {
            if let journal = citationMap.journals[citationId] {
                return formatDateLabel(journal.date) + " Journal"
            }
            return "Journal"
        } else if citationId.hasPrefix("checkin:") {
            if let checkIn = citationMap.checkIns[citationId] {
                return formatDateLabel(checkIn.date) + " Check-in"
            }
            return "Check-in"
        } else if citationId.hasPrefix("why:") {
            if let why = citationMap.whyEntries[citationId] {
                return why.category
            }
            return "My Why"
        } else if citationId == "streak" {
            return "Streak Info"
        }
        return citationId
    }

    private func iconFor(_ citationId: String) -> String {
        if citationId.hasPrefix("journal:") {
            return "book.fill"
        } else if citationId.hasPrefix("checkin:") {
            return "checkmark.circle.fill"
        } else if citationId.hasPrefix("why:") {
            return "heart.fill"
        } else if citationId == "streak" {
            return "flame.fill"
        }
        return "doc.fill"
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct CitationChip: View {
    let label: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))

                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(Color(hex: "74B886"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1E3A2F"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "74B886").opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        // User message
        CoachBubble(
            message: {
                let msg = ChatMessage(sender: .user, content: "I'm struggling tonight")
                return msg
            }(),
            citationMap: CitationMap()
        )

        // Assistant message with citations
        CoachBubble(
            message: {
                let msg = ChatMessage(sender: .assistant, content: "I hear you - nights have been tough. Your Jan 10 entry mentioned the same pattern. You're on Day 12, just 2 days from your Istiqamah milestone.")
                msg.citations = ["journal:abc12345", "checkin:2026-01-10"]
                return msg
            }(),
            citationMap: CitationMap()
        )
    }
    .padding(.vertical, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
