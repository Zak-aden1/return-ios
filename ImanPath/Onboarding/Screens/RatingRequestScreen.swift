//
//  RatingRequestScreen.swift
//  Return
//
//  Onboarding Step 28: Rating request with testimonials
//  Strategic placement after commitment high, before paywall
//

import SwiftUI
import StoreKit
import UIKit

struct RatingRequestScreen: View {
    var onContinue: () -> Void

    @Environment(\.requestReview) private var requestReview
    @State private var showContent: Bool = false
    @State private var hasRated: Bool = false

    // Colors - Fajr Dawn palette
    private let bgTop = Color(hex: "FDF8F5")
    private let bgUpperMid = Color(hex: "F7EDE8")
    private let bgLowerMid = Color(hex: "EBE0E8")
    private let bgBottom = Color(hex: "DED0E0")

    private let accentViolet = Color(hex: "7B5E99")
    private let sunriseGlow = Color(hex: "F6C177")

    private let textHeading = Color(hex: "2D2438")
    private let textBody = Color(hex: "5A4A66")
    private let textMuted = Color(hex: "9A8A9E")

    private let cardBg = Color.white
    private let starColor = Color(hex: "F6C177")

    // Testimonials data
    private let testimonials: [(name: String, age: Int, quote: String)] = [
        (
            "Anonymous",
            24,
            "After 3 weeks, I felt closer to Allah than I had in years. This app truly understands our struggle."
        ),
        (
            "Anonymous",
            31,
            "I finally stopped hiding. My wife noticed the change in me. Alhamdulillah for this app."
        ),
        (
            "Anonymous",
            19,
            "It's not just 'don't watch porn' — it's real Islamic guidance with mercy, not shame."
        )
    ]

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [bgTop, bgUpperMid, bgLowerMid, bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Mountains at bottom
            VStack {
                Spacer()
                RatingMountainsView()
                    .frame(height: 200)
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // Main heading with heart
                    VStack(spacing: 12) {
                        Text("We're a small team,")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(textHeading)

                        HStack(spacing: 8) {
                            Text("so a rating goes a long way")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(textHeading)

                            Text("❤️")
                                .font(.system(size: 26))
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    // Subtitle
                    Text("We're building Return for our ummah.\nYour support helps us reach more Muslims.")
                        .font(.system(size: 16))
                        .foregroundColor(textBody)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Testimonials
                    VStack(spacing: 16) {
                        ForEach(Array(testimonials.prefix(2).enumerated()), id: \.offset) { index, testimonial in
                            TestimonialCard(
                                name: testimonial.name,
                                age: testimonial.age,
                                quote: testimonial.quote,
                                starColor: starColor,
                                textBody: textBody,
                                textMuted: textMuted
                            )
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.3 + Double(index) * 0.1), value: showContent)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    Spacer().frame(height: 32)

                    // Rate / Continue button (two-stage)
                    Button(action: {
                        triggerHaptic(.medium)

                        if hasRated {
                            // Second tap: advance to next screen
                            onContinue()
                        } else {
                            // First tap: trigger rating, transform button
                            requestReview()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                hasRated = true
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text(hasRated ? "Continue Your Journey" : "Rate the app")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(hasRated ? .white : textHeading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(hasRated ? accentViolet : cardBg)
                                .shadow(color: accentViolet.opacity(hasRated ? 0.3 : 0.15), radius: 12, x: 0, y: 6)
                        )
                    }
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)

                    Spacer().frame(height: 120)
                }
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

// MARK: - Testimonial Card
private struct TestimonialCard: View {
    let name: String
    let age: Int
    let quote: String
    let starColor: Color
    let textBody: Color
    let textMuted: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and stars
            HStack {
                // Avatar placeholder
                Circle()
                    .fill(Color(hex: "E8E0F0"))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "9A8A9E"))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(name), \(age)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(textBody)
                }

                Spacer()

                // 5 stars
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(starColor)
                    }
                }
            }

            // Quote
            Text("\"\(quote)\"")
                .font(.system(size: 15))
                .foregroundColor(textBody)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Rating Mountains View
struct RatingMountainsView: View {
    private let mountainBack = Color(hex: "C4B0D0")
    private let mountainMid = Color(hex: "B09DC4")
    private let mountainFront = Color(hex: "9D8AB5")
    private let sunriseGlow = Color(hex: "F6C177")

    var body: some View {
        ZStack {
            // Sunrise glow
            VStack {
                Spacer()
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                sunriseGlow.opacity(0.5),
                                sunriseGlow.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 150)
                    .offset(y: 50)
            }

            // Mountain layers
            MountainShape(peaks: [0.2, 0.5, 0.8], heights: [0.3, 0.45, 0.25])
                .fill(mountainBack.opacity(0.4))
                .offset(y: 40)

            MountainShape(peaks: [0.15, 0.45, 0.75], heights: [0.4, 0.55, 0.35])
                .fill(mountainMid.opacity(0.55))
                .offset(y: 70)

            MountainShape(peaks: [0.1, 0.4, 0.7, 0.9], heights: [0.35, 0.5, 0.6, 0.3])
                .fill(mountainFront.opacity(0.7))
                .offset(y: 100)
        }
    }
}

#Preview {
    RatingRequestScreen(onContinue: {})
}
