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

    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProductID: String?
    @State private var showContent: Bool = false
    @State private var isPurchasing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

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

                    Spacer().frame(height: 24)

                    // Pricing cards - Horizontal row with yearly highlighted
                    pricingSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                    Spacer().frame(height: 24)

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
                    .disabled(isPurchasing || selectedProductID == nil)
                    .opacity(selectedProductID == nil ? 0.6 : 1)
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)

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
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)

                    Spacer().frame(height: 20)

                    // Bottom links - single line like Unchained
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
                            if let url = URL(string: "https://zakaden.com/return/terms") {
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
                            if let url = URL(string: "https://zakaden.com/return/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Privacy Policy")
                                .font(.system(size: 12))
                                .foregroundColor(textMuted)
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.6), value: showContent)

                    Spacer().frame(height: 120)
                }
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            // Select yearly by default
            if selectedProductID == nil, let yearlyProduct = subscriptionManager.product(for: .yearly) {
                selectedProductID = yearlyProduct.id
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

    @ViewBuilder
    private var pricingCardsRow: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Weekly - Left
            if let weekly = subscriptionManager.products.first(where: { $0.id == "week_5" }) {
                CompactPricingCard(
                    product: weekly,
                    label: "Weekly",
                    dailyPrice: "$0.71 / day",
                    totalPrice: "$4.99 per week",
                    isSelected: selectedProductID == weekly.id,
                    isHighlighted: false,
                    accentViolet: accentViolet,
                    sunriseGlow: sunriseGlow,
                    textHeading: textHeading,
                    textMuted: textMuted
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedProductID = weekly.id
                    }
                    triggerHaptic(.light)
                }
            }

            // Yearly - Center (Highlighted)
            if let yearly = subscriptionManager.products.first(where: { $0.id == "yearly_50" }) {
                CompactPricingCard(
                    product: yearly,
                    label: "Yearly",
                    dailyPrice: "$0.14 / day",
                    totalPrice: "$49.99 per year",
                    isSelected: selectedProductID == yearly.id,
                    isHighlighted: true,
                    badgeText: "Save 80%",
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
                    dailyPrice: "$0.33 / day",
                    totalPrice: "$9.99 per month",
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

// MARK: - Compact Pricing Card (Horizontal Layout)
private struct CompactPricingCard: View {
    let product: Product
    let label: String
    let dailyPrice: String
    let totalPrice: String
    let isSelected: Bool
    let isHighlighted: Bool
    var badgeText: String? = nil
    let accentViolet: Color
    let sunriseGlow: Color
    let textHeading: Color
    let textMuted: Color
    var badgeColor: Color = Color(hex: "10B981")
    var onTap: () -> Void

    private var cardHeight: CGFloat {
        isHighlighted ? 120 : 115
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Badge (only for highlighted)
                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.3)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(badgeColor)
                        )
                } else if isHighlighted {
                    // Spacer to maintain alignment
                    Color.clear.frame(height: 20)
                }

                // Label
                Text(label)
                    .font(.system(size: isHighlighted ? 14 : 12, weight: .semibold))
                    .foregroundColor(isSelected ? textHeading : textMuted)

                // Daily price (main price)
                Text(dailyPrice)
                    .font(.system(size: isHighlighted ? 18 : 15, weight: .bold, design: .rounded))
                    .foregroundColor(textHeading)

                // Total price
                Text(totalPrice)
                    .font(.system(size: 10))
                    .foregroundColor(textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
            .background(
                ZStack {
                    // Base card
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)

                    // Selected/Highlighted border
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSelected ? accentViolet : (isHighlighted ? sunriseGlow.opacity(0.5) : Color.clear),
                            lineWidth: isSelected ? 2.5 : 1.5
                        )
                }
            )
            .shadow(
                color: isHighlighted ? sunriseGlow.opacity(isSelected ? 0.35 : 0.2) : Color.black.opacity(0.04),
                radius: isHighlighted ? 12 : 6,
                x: 0,
                y: isHighlighted ? 6 : 3
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
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

#Preview {
    PaywallScreen(
        onSubscribe: {},
        onRestorePurchases: {}
    )
}
