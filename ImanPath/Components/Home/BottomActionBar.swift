//
//  BottomActionBar.swift
//  ImanPath
//

import SwiftUI

struct BottomActionBar: View {
    let onPanicTap: () -> Void
    let onChatTap: () -> Void
    let onCheckInTap: () -> Void
    let onLessonTap: () -> Void

    @State private var isExpanded: Bool = false

    private let panicRed = Color(hex: "E54D42")
    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Dimmed overlay when expanded
            if isExpanded {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }
            }

            VStack(spacing: 0) {
                // Mini menu options (shown when expanded)
                if isExpanded {
                    VStack(spacing: 12) {
                        MenuOption(
                            icon: "message.fill",
                            label: "Start a New Chat",
                            description: "Get guidance and support from your AI companion",
                            color: Color(hex: "8B5CF6"),
                            delay: 0.0
                        ) {
                            closeAndRun(onChatTap)
                        }

                        MenuOption(
                            icon: "pencil",
                            label: "New Check-In Entry",
                            description: "Review your day and track your progress",
                            color: Color(hex: "F59E0B"),
                            delay: 0.05
                        ) {
                            closeAndRun(onCheckInTap)
                        }

                        MenuOption(
                            icon: "book.fill",
                            label: "Daily Lesson",
                            description: "Engage with today's Islamic teachings",
                            color: tealAccent,
                            delay: 0.1
                        ) {
                            closeAndRun(onLessonTap)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // Main action bar
                HStack(spacing: 12) {
                    // Panic Button
                    Button(action: {
                        if isExpanded {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isExpanded = false
                            }
                        }
                        onPanicTap()
                    }) {
                        HStack(spacing: 10) {
                            // White circle with exclamation mark
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 28, height: 28)
                                Text("!")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(panicRed)
                            }

                            Text("Panic Button")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(panicRed)
                        .cornerRadius(28)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 6)
                    }

                    // Plus/Close Button
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isExpanded ? 45 : 0))
                            .frame(width: 56, height: 56)
                            .background(isExpanded ? Color(hex: "374151") : Color.black)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
        }
    }

    private func closeAndRun(_ action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isExpanded = false
        }
        // Small delay to let animation start before navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            action()
        }
    }
}

// MARK: - Menu Option

struct MenuOption: View {
    let icon: String
    let label: String
    let description: String
    let color: Color
    let delay: Double
    let action: () -> Void

    @State private var appeared: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "1A2332"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(delay)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0A1628").ignoresSafeArea()

        VStack {
            Spacer()
            BottomActionBar(
                onPanicTap: { },
                onChatTap: { },
                onCheckInTap: { },
                onLessonTap: { }
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}
