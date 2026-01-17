//
//  PaywallScreen.swift
//  ImanPath
//
//  Onboarding Step 31: Subscription paywall
//  Final step - pricing and subscription options
//

import SwiftUI
import StoreKit
import UIKit

struct PaywallScreen: View {
    var onSubscribe: () -> Void
    var onRestorePurchases: () -> Void

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var showContent: Bool = false
    @State private var isPurchasing: Bool = false

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
    private let selectedBorder = Color(hex: "7B5E99")
    private let unselectedBorder = Color(hex: "E0D4E8")

    // Badge color
    private let badgeGreen = Color(hex: "10B981")

    enum SubscriptionPlan {
        case yearly
        case monthly
    }

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
                PaywallMountainsView()
                    .frame(height: 180)
            }
            .ignoresSafeArea()

            // Radial glow
            RadialGradient(
                colors: [
                    sunriseGlow.opacity(0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 250
            )
            .offset(y: -100)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 50)

                    // Header
                    VStack(spacing: 12) {
                        Text("🕌")
                            .font(.system(size: 60))
                            .shadow(color: sunriseGlow.opacity(0.3), radius: 15, x: 0, y: 8)

                        Text("Start Your Journey\nto Freedom")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(textHeading)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)

                        Text("Join thousands of Muslims reclaiming\ntheir spiritual connection")
                            .font(.system(size: 16))
                            .foregroundColor(textBody)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    Spacer().frame(height: 32)

                    // Features list
                    VStack(spacing: 14) {
                        FeatureRow(icon: "checkmark.circle.fill", text: "Personalized recovery plan")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Daily Islamic guidance & reminders")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Emergency panic button")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Progress tracking & streaks")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Community accountability")
                    }
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    Spacer().frame(height: 32)

                    // Pricing cards
                    VStack(spacing: 12) {
                        // Yearly plan (recommended)
                        PricingCard(
                            title: "Yearly",
                            price: "$49.99",
                            period: "/year",
                            subtext: "Just $4.17/month",
                            badge: "SAVE 58%",
                            isSelected: selectedPlan == .yearly,
                            selectedBorder: selectedBorder,
                            unselectedBorder: unselectedBorder,
                            badgeColor: badgeGreen,
                            textHeading: textHeading,
                            textBody: textBody,
                            textMuted: textMuted
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = .yearly
                            }
                            triggerHaptic(.light)
                        }

                        // Monthly plan
                        PricingCard(
                            title: "Monthly",
                            price: "$9.99",
                            period: "/month",
                            subtext: nil,
                            badge: nil,
                            isSelected: selectedPlan == .monthly,
                            selectedBorder: selectedBorder,
                            unselectedBorder: unselectedBorder,
                            badgeColor: badgeGreen,
                            textHeading: textHeading,
                            textBody: textBody,
                            textMuted: textMuted
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = .monthly
                            }
                            triggerHaptic(.light)
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                    Spacer().frame(height: 24)

                    // Free trial note
                    HStack(spacing: 6) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 14))
                            .foregroundColor(sunriseGlow)

                        Text("Start with a 3-day free trial")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(textBody)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)

                    Spacer().frame(height: 24)

                    // Subscribe button
                    Button(action: {
                        triggerHaptic(.medium)
                        isPurchasing = true
                        // TODO: Implement actual StoreKit purchase
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isPurchasing = false
                            onSubscribe()
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text("Start Free Trial")
                                    .font(.system(size: 17, weight: .semibold))

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(accentViolet)
                                .shadow(color: accentViolet.opacity(0.4), radius: 16, x: 0, y: 8)
                        )
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)

                    // Reassurance text
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(badgeGreen)

                        Text("Cancel anytime. No commitment.")
                            .font(.system(size: 13))
                            .foregroundColor(textMuted)
                    }
                    .padding(.top, 12)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.6), value: showContent)

                    Spacer().frame(height: 24)

                    // Bottom links
                    VStack(spacing: 12) {
                        Button(action: {
                            triggerHaptic(.light)
                            onRestorePurchases()
                        }) {
                            Text("Restore Purchases")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(accentViolet)
                        }

                        HStack(spacing: 16) {
                            Button(action: {
                                // TODO: Open terms
                            }) {
                                Text("Terms of Use")
                                    .font(.system(size: 13))
                                    .foregroundColor(textMuted)
                            }

                            Text("•")
                                .font(.system(size: 13))
                                .foregroundColor(textMuted)

                            Button(action: {
                                // TODO: Open privacy policy
                            }) {
                                Text("Privacy Policy")
                                    .font(.system(size: 13))
                                    .foregroundColor(textMuted)
                            }
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.7), value: showContent)

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

// MARK: - Feature Row
private struct FeatureRow: View {
    let icon: String
    let text: String

    private let accentViolet = Color(hex: "7B5E99")
    private let textBody = Color(hex: "5A4A66")

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(accentViolet)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(textBody)

            Spacer()
        }
    }
}

// MARK: - Pricing Card
private struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    let subtext: String?
    let badge: String?
    let isSelected: Bool
    let selectedBorder: Color
    let unselectedBorder: Color
    let badgeColor: Color
    let textHeading: Color
    let textBody: Color
    let textMuted: Color

    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Radio button
                ZStack {
                    Circle()
                        .stroke(isSelected ? selectedBorder : unselectedBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(selectedBorder)
                            .frame(width: 14, height: 14)
                    }
                }

                // Plan details
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(textHeading)

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(badgeColor)
                                )
                        }
                    }

                    if let subtext = subtext {
                        Text(subtext)
                            .font(.system(size: 13))
                            .foregroundColor(textMuted)
                    }
                }

                Spacer()

                // Price
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(price)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textHeading)

                    Text(period)
                        .font(.system(size: 14))
                        .foregroundColor(textMuted)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? selectedBorder : unselectedBorder, lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? selectedBorder.opacity(0.15) : Color.clear, radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Paywall Mountains View
struct PaywallMountainsView: View {
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
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 140)
                    .offset(y: 50)
            }

            // Mountain layers
            MountainShape(peaks: [0.2, 0.5, 0.8], heights: [0.3, 0.4, 0.25])
                .fill(mountainBack.opacity(0.4))
                .offset(y: 35)

            MountainShape(peaks: [0.15, 0.45, 0.75], heights: [0.38, 0.5, 0.32])
                .fill(mountainMid.opacity(0.55))
                .offset(y: 60)

            MountainShape(peaks: [0.1, 0.4, 0.7, 0.9], heights: [0.32, 0.45, 0.55, 0.28])
                .fill(mountainFront.opacity(0.7))
                .offset(y: 90)
        }
    }
}

#Preview {
    PaywallScreen(
        onSubscribe: {},
        onRestorePurchases: {}
    )
}
