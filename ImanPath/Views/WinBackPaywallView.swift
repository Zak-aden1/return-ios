//
//  WinBackPaywallView.swift
//  Return
//
//  Win-back paywall for transaction abandonment and quick action upsell
//  Shows a single discounted yearly offer with urgency messaging
//

import SwiftUI
import StoreKit
import UIKit

// MARK: - Win-Back Source

enum WinBackSource {
    case transactionAbandon  // No trial - $39.99/year
    case shortcutAction      // With 3-day trial - $39.99/year

    var productID: SubscriptionManager.ProductID {
        switch self {
        case .transactionAbandon: return .noTrialYearly
        case .shortcutAction: return .trialYearly
        }
    }

    var ctaText: String {
        switch self {
        case .transactionAbandon: return "Claim 90% Off"
        case .shortcutAction: return "Start 3-Day Free Trial"
        }
    }

    var billingText: String {
        switch self {
        case .transactionAbandon: return "Billed yearly at $39.99"
        case .shortcutAction: return "3-day free trial, then $39.99/year"
        }
    }
}

struct WinBackPaywallView: View {
    let source: WinBackSource
    var onPurchase: () -> Void
    var onDismiss: () -> Void

    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var isPurchasing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showContent: Bool = false

    // Colors - Warm cream/beige palette
    private let bgColor = Color(hex: "F5F0EB")
    private let lavenderCard = Color(hex: "D8D0E8")
    private let darkBadge = Color(hex: "2D2438")
    private let textHeading = Color(hex: "1A1A1A")
    private let textSubtitle = Color(hex: "6B6B6B")
    private let textMuted = Color(hex: "9A9A9A")
    private let checkmarkColor = Color(hex: "5A5A5A")
    private let giftIconColor = Color(hex: "7B5E99")

    // Pricing
    private let yearlyPrice: Decimal = 39.99
    private let dailyPrice: String = "$0.11"
    private let originalDailyPrice: String = "$1.10"

    var body: some View {
        ZStack {
            // Background
            bgColor.ignoresSafeArea()

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        triggerHaptic(.light)
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textMuted)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }

            // Main content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                // Headline
                VStack(spacing: 12) {
                    Text("Wait... Don't fall back\nto Sin just yet")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(textHeading)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    Text("We'd hate to see you leave without\nhelping to change your ways.")
                        .font(.system(size: 16))
                        .foregroundColor(textSubtitle)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                }

                Spacer()
                    .frame(height: 24)

                // Offer card with gift icon
                ZStack(alignment: .top) {
                    // Lavender card
                    VStack(spacing: 16) {
                        Spacer()
                            .frame(height: 32) // Space for overlapping gift icon

                        // Discount line
                        HStack(spacing: 6) {
                            Text("Here's a")
                                .font(.system(size: 16))
                                .foregroundColor(textHeading)

                            // 90% off badge
                            Text("90% off")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(darkBadge)
                                )

                            Text("Discount 🙌")
                                .font(.system(size: 16))
                                .foregroundColor(textHeading)
                        }

                        // Price card
                        VStack(spacing: 6) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                // Crossed out original price
                                Text(originalDailyPrice)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(textMuted)
                                    .strikethrough(true, color: textMuted)

                                // Discounted price
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text(dailyPrice)
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(textHeading)

                                    Text("/day")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(textHeading)
                                }
                            }

                            Text("Our lowest price ever")
                                .font(.system(size: 14))
                                .foregroundColor(textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .padding(.horizontal, 16)

                        Spacer()
                            .frame(height: 8)
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(lavenderCard.opacity(0.5))
                    )
                    .padding(.horizontal, 32)

                    // Gift icon - overlapping top
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 64, height: 64)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

                        Image(systemName: "gift")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(giftIconColor)
                    }
                    .offset(y: -32)
                }
                .padding(.top, 32) // Extra space for gift icon overflow
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                Spacer()

                // Bottom section
                VStack(spacing: 16) {
                    // Commitment reassurance
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(checkmarkColor)

                        Text("No commitment, cancel anytime")
                            .font(.system(size: 16))
                            .foregroundColor(textHeading)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)

                    // CTA Button
                    Button(action: {
                        Task {
                            await purchaseYearly()
                        }
                    }) {
                        VStack(spacing: 4) {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text(source.ctaText)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                HStack(spacing: 2) {
                                    Text("⭐⭐⭐⭐⭐")
                                        .font(.system(size: 12))
                                    Text("4.9/5 Rated")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.black)
                        )
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)

                    // Billing info
                    Text(source.billingText)
                        .font(.system(size: 14))
                        .foregroundColor(textMuted)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.6), value: showContent)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            switch source {
            case .transactionAbandon:
                AnalyticsManager.shared.trackWinbackPaywallViewed()
            case .shortcutAction:
                AnalyticsManager.shared.trackShortcutPaywallViewed()
            }
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Purchase

    private func purchaseYearly() async {
        guard let product = subscriptionManager.product(for: source.productID) else {
            errorMessage = "Unable to load subscription. Please try again."
            showError = true
            return
        }

        isPurchasing = true
        triggerHaptic(.medium)

        do {
            let success = try await subscriptionManager.purchase(product)
            isPurchasing = false

            if success {
                triggerHaptic(.success)
                switch source {
                case .transactionAbandon:
                    AnalyticsManager.shared.trackWinbackPurchaseCompleted()
                case .shortcutAction:
                    AnalyticsManager.shared.trackShortcutPurchaseCompleted()
                }
                AnalyticsManager.shared.flush()
                onPurchase()
            }
        } catch {
            isPurchasing = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

#Preview("Transaction Abandon") {
    WinBackPaywallView(
        source: .transactionAbandon,
        onPurchase: {},
        onDismiss: {}
    )
}

#Preview("Shortcut Action") {
    WinBackPaywallView(
        source: .shortcutAction,
        onPurchase: {},
        onDismiss: {}
    )
}
