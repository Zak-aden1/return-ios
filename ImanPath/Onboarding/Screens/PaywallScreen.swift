//
//  PaywallScreen.swift
//  Return
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
    var onDismiss: (() -> Void)? = nil  // Optional - for transaction abandon flow
    var closeButtonDelay: TimeInterval = 5.0

    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProductID: String?
    @State private var showContent: Bool = false
    @State private var isPurchasing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showCloseButton: Bool = false  // Delayed close button
    @State private var expandedFAQIndex: Int? = nil  // For FAQ accordion

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

    // Badge colors
    private let badgeGreen = Color(hex: "43B75D") // Best value
    private let badgePurple = Color(hex: "8361FF") // Popular

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

            // Delayed close button - appears after 5 seconds
            if let onDismiss = onDismiss {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            triggerHaptic(.light)
                            onDismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color(hex: "9A8A9E").opacity(0.7))
                                .frame(width: 30, height: 30)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "E8E0EC").opacity(0.5))
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 12)
                        .opacity(showCloseButton ? 1 : 0)
                        .animation(.easeInOut(duration: 0.4), value: showCloseButton)
                    }
                    Spacer()
                }
                .zIndex(100) // Ensure it's above everything
            }

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 20)

                    // Header
                    VStack(spacing: 12) {
                        // Logo
                        Image("ReturnLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 40)
                            .foregroundColor(textHeading)

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

                    Spacer().frame(height: 12)

                    // Screenshot carousel - Show what they'll get
                    PaywallScreenshotCarousel(
                        accentViolet: accentViolet,
                        sunriseGlow: sunriseGlow
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    Spacer().frame(height: 20)

                    // Pricing cards - Horizontal row with yearly highlighted (ABOVE features like Unchained)
                    pricingSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.25), value: showContent)

                    Spacer().frame(height: 28)

                    // What you get section - explicit feature list for App Store compliance (BELOW pricing like Unchained)
                    whatYouGetSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                    Spacer().frame(height: 32)

                    // Social proof + testimonials section (like Unchained)
                    testimonialsSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: showContent)

                    Spacer().frame(height: 32)

                    // Comparison table - "Everything you need" (like Unchained)
                    comparisonTableSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)

                    Spacer().frame(height: 32)

                    // FAQ section - "Your Questions Answered"
                    faqSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.45), value: showContent)

                    Spacer().frame(height: 32)

                    // Repeated pricing at bottom (like Unchained)
                    bottomPricingSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)

                    // Bottom padding for sticky footer
                    Spacer().frame(height: 200)
                }
            }

            // MARK: - Sticky Footer (like Unchained)
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    // Reassurance text - prominent for trust
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 16))
                            .foregroundColor(badgeGreen)

                        Text("No Commitment. Cancel anytime.")
                            .font(.system(size: 15))
                            .foregroundColor(textBody)
                    }

                    // Subscribe button
                    Button(action: {
                        Task {
                            await purchaseSelectedProduct()
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text("Start My Journey Today 🙌")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(accentViolet)
                                .shadow(color: accentViolet.opacity(0.3), radius: 12, x: 0, y: 6)
                        )
                    }
                    .disabled(isPurchasing || selectedProductID == nil)
                    .opacity(selectedProductID == nil ? 0.6 : 1)

                    // Billed amount - clear and conspicuous (App Store 3.1.2 compliance)
                    if !selectedBillingText.isEmpty {
                        Text(selectedBillingText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textBody)
                    }

                    // Bottom links
                    HStack(spacing: 8) {
                        Button(action: {
                            triggerHaptic(.light)
                            Task {
                                await subscriptionManager.restorePurchases()
                                if subscriptionManager.isSubscribed {
                                    onRestorePurchases()
                                }
                            }
                        }) {
                            Text("Restore Purchases")
                                .font(.system(size: 12))
                                .foregroundColor(textMuted)
                        }

                        Text("•")
                            .font(.system(size: 12))
                            .foregroundColor(textMuted.opacity(0.5))

                        Button(action: {
                            if let url = URL(string: "https://returntoiman.com/terms") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Terms of Use")
                                .font(.system(size: 12))
                                .foregroundColor(textMuted)
                        }

                        Text("•")
                            .font(.system(size: 12))
                            .foregroundColor(textMuted.opacity(0.5))

                        Button(action: {
                            if let url = URL(string: "https://returntoiman.com/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Privacy Policy")
                                .font(.system(size: 12))
                                .foregroundColor(textMuted)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 34)
                .background(
                    // Solid background with clear top border (like Unchained)
                    VStack(spacing: 0) {
                        // Top border line
                        Rectangle()
                            .fill(Color(hex: "D8D0DC"))
                            .frame(height: 1)

                        // Solid background
                        bgBottom
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.35), value: showContent)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }

            // Select yearly by default
            if selectedProductID == nil, let yearlyProduct = subscriptionManager.product(for: .yearly) {
                selectedProductID = yearlyProduct.id
            }
            // Track paywall view
            AnalyticsManager.shared.trackPaywallViewed()
            AnalyticsManager.shared.flush()

            // Show close button after delay (only if onDismiss is provided)
            if onDismiss != nil {
                let delay = max(0, closeButtonDelay)
                if delay == 0 {
                    showCloseButton = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation {
                            showCloseButton = true
                        }
                    }
                }
            }
        }
        .onChange(of: subscriptionManager.products) { _, products in
            // Select yearly by default when products load
            if selectedProductID == nil, let yearlyProduct = products.first(where: { $0.id == SubscriptionManager.ProductID.yearly.rawValue }) {
                selectedProductID = yearlyProduct.id
            }
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - What You Get Section (App Store Guideline 3.1.2 compliance)

    private var whatYouGetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Centered header
            Text("What you get")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(textHeading)
                .frame(maxWidth: .infinity)

            // Feature list
            VStack(alignment: .leading, spacing: 10) {
                PaywallFeatureRow(text: "30-day guided recovery program")
                PaywallFeatureRow(text: "AI-powered Islamic coach")
                PaywallFeatureRow(text: "Daily check-ins & journaling")
                PaywallFeatureRow(text: "Panic button for temptation")
                PaywallFeatureRow(text: "Streak tracking & milestones")
                PaywallFeatureRow(text: "Daily Quranic guidance")
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Testimonials Section (like Unchained's social proof)

    private var testimonialsSection: some View {
        VStack(spacing: 20) {
            // Header - aspirational, no fake metrics
            Text("Join Muslims reclaiming their path")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(textHeading)
                .multilineTextAlignment(.center)

            // Horizontal scrolling testimonial cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Left padding for first card
                    Spacer().frame(width: 12)

                    TestimonialCard(
                        quote: "After years of struggling, this app finally helped me break free. The Islamic approach speaks to my heart.",
                        name: "Ahmad",
                        starColor: sunriseGlow,
                        textHeading: textHeading,
                        textBody: textBody
                    )

                    TestimonialCard(
                        quote: "The daily Quranic reminders and AI coach have been life-changing. I feel closer to Allah than ever.",
                        name: "Yusuf",
                        starColor: sunriseGlow,
                        textHeading: textHeading,
                        textBody: textBody
                    )

                    TestimonialCard(
                        quote: "Finally an app that understands our struggle as Muslims. The panic button has saved me countless times.",
                        name: "Omar",
                        starColor: sunriseGlow,
                        textHeading: textHeading,
                        textBody: textBody
                    )

                    TestimonialCard(
                        quote: "This app helped me rebuild my connection with Allah. The 30-day program is exactly what I needed.",
                        name: "Khalid",
                        starColor: sunriseGlow,
                        textHeading: textHeading,
                        textBody: textBody
                    )

                    // Right padding for last card
                    Spacer().frame(width: 12)
                }
            }
        }
    }

    // MARK: - Comparison Table Section (like Unchained's "Everything you need")

    private var comparisonTableSection: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 6) {
                Text("Everything you need")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(textHeading)

                Text("Get all the tools to break free")
                    .font(.system(size: 14))
                    .foregroundColor(textMuted)
            }

            // Comparison card
            VStack(spacing: 0) {
                // Column headers
                HStack {
                    Text("")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("WITHOUT")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(textMuted)
                        .frame(width: 70)

                    Text("RETURN")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(accentViolet)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Comparison rows
                ComparisonRow(feature: "Desire to Change", hasWithout: true, hasWith: true, accentViolet: accentViolet, textBody: textBody, textMuted: textMuted)
                ComparisonRow(feature: "Personalized Recovery Plan", hasWithout: false, hasWith: true, accentViolet: accentViolet, textBody: textBody, textMuted: textMuted)
                ComparisonRow(feature: "Faith-Based Guidance", hasWithout: false, hasWith: true, accentViolet: accentViolet, textBody: textBody, textMuted: textMuted)
                ComparisonRow(feature: "Real Accountability", hasWithout: false, hasWith: true, accentViolet: accentViolet, textBody: textBody, textMuted: textMuted)
                ComparisonRow(feature: "Daily Spiritual Tools", hasWithout: false, hasWith: true, accentViolet: accentViolet, textBody: textBody, textMuted: textMuted)
                ComparisonRow(feature: "Clear Progress Milestones", hasWithout: false, hasWith: true, accentViolet: accentViolet, textBody: textBody, textMuted: textMuted)
                ComparisonRow(feature: "Stronger Connection with Allah", hasWithout: false, hasWith: true, accentViolet: accentViolet, textBody: textBody, textMuted: textMuted, isLast: true)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - FAQ Section

    private var faqSection: some View {
        VStack(spacing: 20) {
            // Header
            Text("Your Most Asked Questions")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(textHeading)

            // FAQ items - no card, open style like Unchained
            VStack(spacing: 4) {
                FAQItem(
                    question: "Is this app for Muslims?",
                    answer: "Yes, Return is designed specifically for Muslims. Our approach combines Islamic principles, Quranic guidance, and proven recovery methods to help you quit while strengthening your iman.",
                    index: 0,
                    expandedIndex: $expandedFAQIndex,
                    textHeading: textHeading,
                    textBody: textBody,
                    textMuted: textMuted
                )

                FAQItem(
                    question: "How will Return help me quit for good?",
                    answer: "Through a proven Islamic framework combining faith and science. You get a custom recovery plan, daily Quranic guidance, an AI coach, check-ins, and progress tracking. Everything is designed for lasting change.",
                    index: 1,
                    expandedIndex: $expandedFAQIndex,
                    textHeading: textHeading,
                    textBody: textBody,
                    textMuted: textMuted
                )

                FAQItem(
                    question: "Will anyone know I'm using this?",
                    answer: "No, your data and journey are completely private. Nothing is shared, and your identity is never revealed.",
                    index: 2,
                    expandedIndex: $expandedFAQIndex,
                    textHeading: textHeading,
                    textBody: textBody,
                    textMuted: textMuted
                )

                FAQItem(
                    question: "I've tried other apps before. What if this doesn't work for me?",
                    answer: "We hear that a lot, until people try Return. Unlike other apps, this goes beyond just quitting - it deepens your iman and connection with Allah. If you're ready to surrender this struggle to Him, you will find the strength to quit.",
                    index: 3,
                    expandedIndex: $expandedFAQIndex,
                    textHeading: textHeading,
                    textBody: textBody,
                    textMuted: textMuted,
                    isLast: true
                )
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom Pricing Section (repeated at end like Unchained)

    private var bottomPricingSection: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 6) {
                Text("Begin Your Freedom")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(textHeading)

                Text("Choose your plan and start today")
                    .font(.system(size: 14))
                    .foregroundColor(textMuted)
            }

            // Reuse pricing cards
            pricingSection
        }
    }

    // MARK: - Pricing Section (Extracted for compiler)

    @ViewBuilder
    private var pricingSection: some View {
        if subscriptionManager.isLoading && subscriptionManager.products.isEmpty {
            ProgressView()
                .padding(.vertical, 40)
                .padding(.horizontal, 24)
        } else if subscriptionManager.products.isEmpty {
            Text("Unable to load subscription options")
                .font(.system(size: 15))
                .foregroundColor(textMuted)
                .padding(.vertical, 40)
                .padding(.horizontal, 24)
        } else {
            pricingCardsRow
        }
    }

    // MARK: - Localized Price Helpers

    /// Gets the billed price string for card display (e.g., "$4.99 / Week")
    /// This is the ACTUAL billed amount - App Store 3.1.2 compliant
    private func billedPriceString(for product: Product) -> String {
        switch product.id {
        case "yearly_50":
            return "\(product.displayPrice) / Year"
        case "month_10":
            return "\(product.displayPrice) / Month"
        case "week_5":
            return "\(product.displayPrice) / Week"
        default:
            return product.displayPrice
        }
    }

    /// Gets the selected product for billing display
    private var selectedProduct: Product? {
        guard let id = selectedProductID else { return nil }
        return subscriptionManager.products.first(where: { $0.id == id })
    }

    /// Gets the billing text for display below CTA (e.g., "Only $49.99 every year")
    private var selectedBillingText: String {
        guard let product = selectedProduct else { return "" }
        switch product.id {
        case "yearly_50":
            return "Only \(product.displayPrice) every year"
        case "month_10":
            return "Only \(product.displayPrice) every month"
        case "week_5":
            return "Only \(product.displayPrice) every week"
        default:
            return "Only \(product.displayPrice)"
        }
    }

    @ViewBuilder
    private var pricingCardsRow: some View {
        HStack(alignment: .top, spacing: 10) {
            // Weekly - Left (with "Popular" badge)
            if let weekly = subscriptionManager.products.first(where: { $0.id == "week_5" }) {
                CompactPricingCard(
                    product: weekly,
                    label: "Weekly",
                    billedPrice: billedPriceString(for: weekly),
                    isSelected: selectedProductID == weekly.id,
                    isHighlighted: false,
                    badgeText: "Popular",
                    accentViolet: accentViolet,
                    sunriseGlow: sunriseGlow,
                    textHeading: textHeading,
                    textMuted: textMuted,
                    badgeColor: badgePurple
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedProductID = weekly.id
                    }
                    triggerHaptic(.light)
                }
            }

            // Yearly - Center (with "Best value" badge)
            if let yearly = subscriptionManager.products.first(where: { $0.id == "yearly_50" }) {
                CompactPricingCard(
                    product: yearly,
                    label: "Yearly",
                    billedPrice: billedPriceString(for: yearly),
                    isSelected: selectedProductID == yearly.id,
                    isHighlighted: true,
                    badgeText: "Best value",
                    accentViolet: accentViolet,
                    sunriseGlow: sunriseGlow,
                    textHeading: textHeading,
                    textMuted: textMuted,
                    badgeColor: badgeGreen
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedProductID = yearly.id
                    }
                    triggerHaptic(.light)
                }
            }

            // Monthly - Right
            if let monthly = subscriptionManager.products.first(where: { $0.id == "month_10" }) {
                CompactPricingCard(
                    product: monthly,
                    label: "Monthly",
                    billedPrice: billedPriceString(for: monthly),
                    isSelected: selectedProductID == monthly.id,
                    isHighlighted: false,
                    accentViolet: accentViolet,
                    sunriseGlow: sunriseGlow,
                    textHeading: textHeading,
                    textMuted: textMuted
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedProductID = monthly.id
                    }
                    triggerHaptic(.light)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10) // Space for badge overflow
    }

    private func purchaseSelectedProduct() async {
        guard let productID = selectedProductID,
              let product = subscriptionManager.products.first(where: { $0.id == productID }) else {
            return
        }

        isPurchasing = true
        triggerHaptic(.medium)

        do {
            let success = try await subscriptionManager.purchase(product)
            isPurchasing = false

            if success {
                triggerHaptic(.success)
                AnalyticsManager.shared.trackSubscriptionStarted(plan: productID)
                AnalyticsManager.shared.flush()
                onSubscribe()
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

// MARK: - Paywall Feature Row (What You Get section)
private struct PaywallFeatureRow: View {
    let text: String

    private let accentViolet = Color(hex: "7B5E99")
    private let textBody = Color(hex: "5A4A66")

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(accentViolet)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(textBody)

            Spacer()
        }
    }
}

// MARK: - Testimonial Card (for social proof section)
private struct TestimonialCard: View {
    let quote: String
    let name: String
    let starColor: Color
    let textHeading: Color
    let textBody: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 5 stars
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(starColor)
                }
            }

            // Quote
            Text(quote)
                .font(.system(size: 15))
                .foregroundColor(textBody)
                .lineSpacing(3)

            Spacer()

            // Name
            Text(name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(textHeading)
        }
        .padding(20)
        .frame(width: 280, height: 180, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Comparison Row (for comparison table)
private struct ComparisonRow: View {
    let feature: String
    let hasWithout: Bool
    let hasWith: Bool
    let accentViolet: Color
    let textBody: Color
    let textMuted: Color
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(feature)
                    .font(.system(size: 14))
                    .foregroundColor(textBody)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // WITHOUT column
                Group {
                    if hasWithout {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(textMuted.opacity(0.5))
                    } else {
                        Image(systemName: "minus")
                            .foregroundColor(textMuted.opacity(0.3))
                    }
                }
                .font(.system(size: 16))
                .frame(width: 70)

                // WITH RETURN column
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(accentViolet)
                    .frame(width: 80)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if !isLast {
                Rectangle()
                    .fill(Color(hex: "F0EBF4"))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - FAQ Item (expandable accordion - Unchained style)
private struct FAQItem: View {
    let question: String
    let answer: String
    let index: Int
    @Binding var expandedIndex: Int?
    let textHeading: Color
    let textBody: Color
    let textMuted: Color
    var isLast: Bool = false

    private var isExpanded: Bool {
        expandedIndex == index
    }

    var body: some View {
        VStack(spacing: 0) {
            // Question button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isExpanded {
                        expandedIndex = nil
                    } else {
                        expandedIndex = index
                    }
                }
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                HStack(alignment: .top) {
                    Text(question)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(textHeading)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textMuted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.top, 4)
                }
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())

            // Answer (expandable)
            if isExpanded {
                Text(answer)
                    .font(.system(size: 15))
                    .foregroundColor(textBody)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

        }
    }
}

// MARK: - Compact Pricing Card (App Store 3.1.2 Compliant - Billed Amount Only)
private struct CompactPricingCard: View {
    let product: Product
    let label: String
    let billedPrice: String  // The actual billed amount - e.g., "$4.99 / week"
    let isSelected: Bool
    let isHighlighted: Bool
    var badgeText: String? = nil
    let accentViolet: Color
    let sunriseGlow: Color
    let textHeading: Color
    let textMuted: Color
    var badgeColor: Color = Color(hex: "10B981")
    var onTap: () -> Void

    // Uniform height for all cards - text alignment matters
    private let cardHeight: CGFloat = 90

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                // Card content - identical layout for all cards
                VStack(spacing: 10) {
                    // Label
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? textHeading : textMuted)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    // Billed amount - THE prominent price (App Store 3.1.2 compliant)
                    Text(billedPrice)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(textHeading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight)
                .background(
                    ZStack {
                        // Base card
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)

                        // Border - clean single stroke like Unchained
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? accentViolet : Color(hex: "E8E0EC"),
                                lineWidth: isSelected ? 2.5 : 1
                            )
                    }
                )
                .shadow(
                    color: isSelected ? accentViolet.opacity(0.15) : Color.black.opacity(0.04),
                    radius: isSelected ? 8 : 4,
                    x: 0,
                    y: isSelected ? 3 : 2
                )

                // Badge - absolute positioned, overlapping top edge like Unchained
                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(badgeColor)
                        )
                        .offset(y: -8) // Overlap card top edge like Unchained
                }
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Paywall Screenshot Carousel (iPhone Mockup Style - like Tutorial)
struct PaywallScreenshotCarousel: View {
    let accentViolet: Color
    let sunriseGlow: Color

    @State private var currentIndex: Int = 0
    @State private var autoAdvanceTimer: Timer?

    // Screenshots to show
    private let screenshots = [
        "tutorial_home",
        "tutorial_streak",
        "tutorial_daily",
        "tutorial_tools"
    ]

    var body: some View {
        VStack(spacing: 12) {
            // iPhone mockup carousel
            TabView(selection: $currentIndex) {
                ForEach(0..<screenshots.count, id: \.self) { index in
                    PaywallPhoneMockup(
                        screenshotName: screenshots[index],
                        accentViolet: accentViolet,
                        sunriseGlow: sunriseGlow
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 262) // Compact height for paywall (252 + 10 for shadow)

            // Pagination dots
            HStack(spacing: 8) {
                ForEach(0..<screenshots.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? accentViolet : accentViolet.opacity(0.25))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentIndex ? 1.0 : 0.85)
                        .animation(.spring(response: 0.3), value: currentIndex)
                }
            }
        }
        .onAppear {
            startAutoAdvance()
        }
        .onDisappear {
            autoAdvanceTimer?.invalidate()
            autoAdvanceTimer = nil
        }
    }

    private func startAutoAdvance() {
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % screenshots.count
            }
        }
    }
}

// MARK: - Paywall Phone Mockup (Same style as Tutorial but shorter + warm glow)
private struct PaywallPhoneMockup: View {
    let screenshotName: String
    let accentViolet: Color
    let sunriseGlow: Color

    // iPhone dimensions - compact for paywall
    private let phoneWidth: CGFloat = 180
    private let phoneHeight: CGFloat = 320
    private let bezelWidth: CGFloat = 5
    private let cornerRadius: CGFloat = 36
    private let screenCornerRadius: CGFloat = 31
    private let dynamicIslandWidth: CGFloat = 70
    private let dynamicIslandHeight: CGFloat = 22

    // Container clips phone at bottom (shorter = more cropped)
    private let containerHeight: CGFloat = 252

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Warm glow behind phone (matches paywall colors)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                sunriseGlow.opacity(0.5),
                                accentViolet.opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(y: 40)

                // The iPhone device
                ZStack {
                    // Phone body (black frame)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.black)
                        .frame(width: phoneWidth, height: phoneHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.25),
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.8
                                )
                        )
                        .shadow(color: accentViolet.opacity(0.3), radius: 20, x: 0, y: 12)

                    // Screen area
                    RoundedRectangle(cornerRadius: screenCornerRadius)
                        .fill(Color(hex: "0A1628"))
                        .frame(
                            width: phoneWidth - (bezelWidth * 2),
                            height: phoneHeight - (bezelWidth * 2)
                        )

                    // Screenshot content
                    PaywallScreenshotContent(name: screenshotName)
                        .frame(
                            width: phoneWidth - (bezelWidth * 2),
                            height: phoneHeight - (bezelWidth * 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: screenCornerRadius))

                    // Dynamic Island
                    Capsule()
                        .fill(Color.black)
                        .frame(width: dynamicIslandWidth, height: dynamicIslandHeight)
                        .offset(y: -(phoneHeight / 2) + bezelWidth + 16)
                }
                // Subtle 3D tilt
                .rotation3DEffect(
                    .degrees(3),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.8
                )
                .offset(y: 25) // Push down so bottom gets cropped
            }
        }
        .frame(height: containerHeight) // Container clips overflow
        .clipped()
    }
}

// MARK: - Paywall Screenshot Content
private struct PaywallScreenshotContent: View {
    let name: String

    var body: some View {
        GeometryReader { geo in
            if let _ = UIImage(named: name) {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            } else {
                // Placeholder
                Color(hex: "0A1628")
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "iphone")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.3))
                            Text(name)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    )
            }
        }
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

#Preview("Without Dismiss") {
    PaywallScreen(
        onSubscribe: {},
        onRestorePurchases: {}
    )
}

#Preview("With Delayed Dismiss") {
    PaywallScreen(
        onSubscribe: {},
        onRestorePurchases: {},
        onDismiss: { print("Dismissed") }
    )
}
