//
//  TypingIndicator.swift
//  ImanPath
//
//  Animated typing indicator for Streak Coach
//

import SwiftUI

struct TypingIndicator: View {
    @State private var animationPhase = 0

    private let dotColor = Color(hex: "64748B")
    private let dotSize: CGFloat = 8
    private let spacing: CGFloat = 4

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Coach icon
            ZStack {
                Circle()
                    .fill(Color(hex: "1E3A5F"))
                    .frame(width: 32, height: 32)

                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "74B886"))
            }

            // Bubble with dots
            HStack(spacing: spacing) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(dotColor)
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: animationPhase == index ? -4 : 0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: "1A2737"))
            )

            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

#Preview {
    VStack {
        TypingIndicator()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
