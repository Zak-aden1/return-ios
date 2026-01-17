//
//  CommitmentCardScreen.swift
//  ImanPath
//
//  Onboarding Step 25: The actual commitment/niyyah card
//

import SwiftUI
import UIKit

struct CommitmentCardScreen: View {
    let userName: String
    var onCommit: (Date) -> Void
    var onBack: () -> Void

    @State private var showContent: Bool = false
    @State private var hasCommitted: Bool = false
    @State private var cardScale: CGFloat = 1.0

    // Colors
    private let bgColor = Color(hex: "0A1628")
    private let warmAmber = Color(hex: "C4956A")
    private let goldAccent = Color(hex: "F59E0B")
    private let cardGradientTop = Color(hex: "1A2332")
    private let cardGradientBottom = Color(hex: "0F1722")

    // Goal date (90 days from now)
    private var goalDate: Date {
        Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
    }

    private var formattedGoalDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: goalDate).uppercased()
    }

    private var daysFromNow: Int {
        90
    }

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            // Subtle radial glow
            RadialGradient(
                colors: [
                    warmAmber.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: showContent)

                Spacer()

                // The Commitment Card
                VStack(spacing: 0) {
                    // Card header decoration
                    HStack {
                        IslamicPatternLine()
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(goldAccent)
                        Spacer()
                        IslamicPatternLine()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    // Title
                    Text("MY NIYYAH")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(3)
                        .foregroundColor(goldAccent)
                        .padding(.top, 16)

                    // Pledge text
                    VStack(spacing: 8) {
                        Text("\"I commit to quitting")
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundColor(.white)

                        Text("pornography")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(warmAmber)

                        Text("for the sake of Allah.\"")
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                    // Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, warmAmber.opacity(0.5), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                        .padding(.top, 28)

                    // Goal date section
                    VStack(spacing: 8) {
                        Text("Porn-free by")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8A9BAE"))

                        Text(formattedGoalDate)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("(\(daysFromNow) days from today)")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8A9BAE"))
                    }
                    .padding(.top, 20)

                    // User's name
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(warmAmber.opacity(0.3))
                            .frame(width: 160, height: 1)

                        Text(userName)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                            .italic()
                    }
                    .padding(.top, 24)

                    // Card footer decoration
                    HStack {
                        IslamicPatternLine()
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(goldAccent)
                        Spacer()
                        IslamicPatternLine()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [cardGradientTop, cardGradientBottom],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            warmAmber.opacity(0.5),
                                            warmAmber.opacity(0.2),
                                            warmAmber.opacity(0.1)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: warmAmber.opacity(0.15), radius: 30, x: 0, y: 10)
                )
                .padding(.horizontal, 24)
                .scaleEffect(cardScale)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)

                Spacer()

                // Commit button
                Button(action: {
                    triggerHaptic(.heavy)

                    // Animate card
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        cardScale = 1.05
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cardScale = 1.0
                            hasCommitted = true
                        }
                    }

                    // Proceed after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        onCommit(goalDate)
                    }
                }) {
                    HStack(spacing: 12) {
                        if hasCommitted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                        }

                        Text(hasCommitted ? "Committed" : "I Commit")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(bgColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                hasCommitted
                                    ? Color(hex: "10B981") // Green when committed
                                    : warmAmber
                            )
                    )
                }
                .disabled(hasCommitted)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)

                // Reassurance text
                Text("Your commitment is private and stored only on your device")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8A9BAE"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.6), value: showContent)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Islamic Pattern Line (decorative)
struct IslamicPatternLine: View {
    private let goldAccent = Color(hex: "F59E0B")

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Diamond()
                    .fill(goldAccent.opacity(0.6 - Double(i) * 0.15))
                    .frame(width: 6, height: 6)
            }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [goldAccent.opacity(0.4), goldAccent.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 1)
        }
    }
}

// MARK: - Diamond Shape
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let halfWidth = rect.width / 2
        let halfHeight = rect.height / 2

        path.move(to: CGPoint(x: center.x, y: center.y - halfHeight))
        path.addLine(to: CGPoint(x: center.x + halfWidth, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + halfHeight))
        path.addLine(to: CGPoint(x: center.x - halfWidth, y: center.y))
        path.closeSubpath()

        return path
    }
}

#Preview {
    CommitmentCardScreen(
        userName: "Zak",
        onCommit: { _ in },
        onBack: {}
    )
}
