//
//  DhikrCounterView.swift
//  ImanPath
//
//  Dhikr counter - seek refuge in Allah
//

import SwiftUI
import UIKit

struct DhikrCounterView: View {
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)? = nil

    @State private var currentDhikrIndex: Int = 0
    @State private var count: Int = 0
    @State private var isCompleted: Bool = false
    @State private var showRenewPromise: Bool = false
    @State private var circleScale: CGFloat = 1.0

    private let targetCount = 3

    // Dhikr data
    private let dhikrs: [(arabic: String, transliteration: String, translation: String)] = [
        (
            "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
            "A'udhu billahi min ash-shaytan ir-rajim",
            "I seek refuge in Allah from the accursed Satan"
        ),
        (
            "سُبْحَانَ اللَّهِ",
            "SubhanAllah",
            "Glory be to Allah"
        ),
        (
            "الْحَمْدُ لِلَّهِ",
            "Alhamdulillah",
            "All praise is due to Allah"
        )
    ]

    private var currentDhikr: (arabic: String, transliteration: String, translation: String) {
        dhikrs[currentDhikrIndex]
    }

    private var overallProgress: String {
        "\(currentDhikrIndex + 1)/\(dhikrs.count)"
    }

    // Colors
    private let softBlue = Color(hex: "6B8CAE")
    private let deepBlue = Color(hex: "4A6B8A")
    private let glowBlue = Color(hex: "8BAFD0")

    var body: some View {
        ZStack {
            // Background
            SpaceBackground()

            // Ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            softBlue.opacity(0.2),
                            softBlue.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 30)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer().frame(height: 24)

                // Title with progress
                VStack(spacing: 8) {
                    Text("Recite with your heart")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundColor(.white)

                    if !isCompleted {
                        // Progress pills
                        HStack(spacing: 8) {
                            ForEach(0..<dhikrs.count, id: \.self) { index in
                                Capsule()
                                    .fill(index <= currentDhikrIndex ? softBlue : Color.white.opacity(0.2))
                                    .frame(width: index == currentDhikrIndex ? 24 : 8, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: currentDhikrIndex)
                            }
                        }
                    }
                }

                Spacer().frame(height: 32)

                // Dhikr Card
                VStack(spacing: 24) {
                    // Arabic text
                    Text(currentDhikr.arabic)
                        .font(.system(size: currentDhikrIndex == 0 ? 26 : 32, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .id(currentDhikrIndex) // Force refresh animation

                    // Transliteration
                    Text(currentDhikr.transliteration)
                        .font(.system(size: 15, weight: .medium))
                        .italic()
                        .foregroundColor(softBlue)
                        .multilineTextAlignment(.center)

                    // Translation
                    Text("\"\(currentDhikr.translation)\"")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "8A9BAE"))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "1A2737"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(softBlue.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .animation(.easeInOut(duration: 0.3), value: currentDhikrIndex)

                Spacer().frame(height: 48)

                // Tap Counter Circle
                if !isCompleted {
                    Button(action: { incrementCount() }) {
                        ZStack {
                            // Outer glow rings
                            ForEach(0..<3) { i in
                                Circle()
                                    .stroke(
                                        softBlue.opacity(0.1 - Double(i) * 0.03),
                                        lineWidth: 1
                                    )
                                    .frame(width: 160 + CGFloat(i * 30), height: 160 + CGFloat(i * 30))
                            }

                            // Main circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            glowBlue.opacity(0.3),
                                            softBlue.opacity(0.5),
                                            deepBlue.opacity(0.7)
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 150, height: 150)
                                .shadow(color: softBlue.opacity(0.4), radius: 20, x: 0, y: 0)
                                .scaleEffect(circleScale)

                            // Count display
                            VStack(spacing: 4) {
                                Text("\(count)")
                                    .font(.system(size: 48, weight: .light, design: .rounded))
                                    .foregroundColor(.white)
                                    .contentTransition(.numericText())

                                Text("of \(targetCount)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer().frame(height: 16)

                    Text("Tap to recite")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "8A9BAE"))
                } else {
                    // Completion state
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(softBlue)

                        Text("MashaAllah")
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                // Bottom verse
                VStack(spacing: 12) {
                    Text("\"Indeed, Allah is with the patient.\"")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)

                    Text("— Quran 2:153")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(softBlue)
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 32)

                // Bottom button
                if isCompleted {
                    Button(action: { showRenewPromise = true }) {
                        Text("Renew My Promise")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(softBlue)
                                    .shadow(color: softBlue.opacity(0.4), radius: 12, y: 4)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                } else {
                    // Skip option
                    Button(action: { showRenewPromise = true }) {
                        Text("I'm better, continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 26)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showRenewPromise) {
            RenewPromiseView(onComplete: {
                dismiss()
                onComplete?()
            })
        }
    }

    private func incrementCount() {
        guard !isCompleted else { return }

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Animate tap
        withAnimation(.easeOut(duration: 0.1)) {
            circleScale = 0.95
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.15)) {
                circleScale = 1.0
            }
        }

        // Increment
        withAnimation(.easeInOut(duration: 0.2)) {
            count += 1
        }

        // Check if current dhikr is complete
        if count >= targetCount {
            // Check if all dhikrs are done
            if currentDhikrIndex >= dhikrs.count - 1 {
                // All complete!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let successGenerator = UINotificationFeedbackGenerator()
                    successGenerator.notificationOccurred(.success)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isCompleted = true
                    }
                }
            } else {
                // Move to next dhikr
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentDhikrIndex += 1
                        count = 0
                    }
                }
            }
        }
    }
}

#Preview {
    DhikrCounterView()
}
