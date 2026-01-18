//
//  PrePaywallScreen.swift
//  Return
//
//  Onboarding Step 30: Pre-paywall benefits screen
//  Long scrollable value sell before showing prices
//

import SwiftUI
import UIKit

struct PrePaywallScreen: View {
    let userName: String
    var onContinue: () -> Void

    @State private var showContent: Bool = false

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

    private let starColor = Color(hex: "F6C177")

    // Goal date (90 days from now)
    private var goalDate: Date {
        Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
    }

    private var formattedGoalDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: goalDate)
    }

    // Benefit chips data
    private let benefitChips: [(emoji: String, text: String, color: Color)] = [
        ("⚡", "More Energy", Color(hex: "F59E0B")),
        ("💪", "Better Focus", Color(hex: "3B82F6")),
        ("🧠", "Mental Clarity", Color(hex: "A855F7")),
        ("❤️", "Stronger Relationships", Color(hex: "EF4444")),
        ("📿", "Deeper Iman", Color(hex: "F97316")),
        ("😊", "Improved Confidence", Color(hex: "10B981")),
        ("✨", "Pure Thoughts", Color(hex: "EC4899")),
        ("🎯", "Clear Purpose", Color(hex: "6366F1"))
    ]

    // Testimonials
    private let testimonials: [(quote: String, index: Int)] = [
        ("After 3 weeks, I felt closer to Allah than I had in years. This app truly understands our struggle.", 0),
        ("The Islamic approach and daily guidance helped me break free from a cycle I thought I'd never escape.", 1),
        ("This app has completely transformed my journey. The personalized plan and Quranic reminders have been invaluable.", 2),
        ("The clarity and energy I've gained is incredible. Alhamdulillah, this app helped me rediscover my purpose.", 3),
        ("I've experienced real transformation in my iman and relationships. This app provides practical tools that actually work.", 4)
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

            // Mountains at very bottom (behind content)
            VStack {
                Spacer()
                PrePaywallMountainsView()
                    .frame(height: 200)
            }
            .ignoresSafeArea()

            // Main scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // SECTION 1: Personalized Header
                    personalizedHeaderSection
                        .padding(.top, 40)

                    // Divider
                    dividerLine
                        .padding(.vertical, 24)

                    // SECTION 2: Start a new chapter + benefit chips
                    newChapterSection

                    // Divider
                    dividerLine
                        .padding(.vertical, 24)

                    // SECTION 3: Your Path to Freedom
                    pathToFreedomSection

                    // SECTION 4: Break Free From the Cycle
                    breakFreeSection

                    // SECTION 5: It's time to draw the line
                    drawTheLineSection

                    // SECTION 6: Time to Live the Life You Envision
                    liveTheLifeSection

                    // SECTION 7: The Ideal Future Version of You
                    idealFutureSection

                    // Contact support link
                    Button(action: {}) {
                        Text("Contact Support")
                            .font(.system(size: 14))
                            .foregroundColor(textMuted)
                            .underline()
                    }
                    .padding(.top, 24)

                    // Bottom padding for sticky button
                    Spacer().frame(height: 160)
                }
                .padding(.horizontal, 24)
            }

            // Sticky bottom CTA
            VStack {
                Spacer()

                VStack(spacing: 8) {
                    Button(action: {
                        triggerHaptic(.medium)
                        onContinue()
                    }) {
                        HStack(spacing: 8) {
                            Text("Begin Your Journey")
                                .font(.system(size: 17, weight: .semibold))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
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

                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "10B981"))

                        Text("No commitment, cancel anytime.")
                            .font(.system(size: 13))
                            .foregroundColor(textMuted)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
                .frame(maxWidth: .infinity)
                .background(
                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [bgBottom.opacity(0), bgBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40)

                        bgBottom
                    }
                    .allowsHitTesting(false)
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }

    // MARK: - Section Views

    private var personalizedHeaderSection: some View {
        VStack(spacing: 16) {
            // Green checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "10B981"))

            // Personalized title
            HStack(spacing: 0) {
                Text("✨ ")
                    .font(.system(size: 28))
                Text("\(userName), we've made you a custom plan")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(textHeading)
                Text(" ✨")
                    .font(.system(size: 28))
            }
            .multilineTextAlignment(.center)

            // Quit date
            VStack(spacing: 8) {
                Text("You will quit porn by:")
                    .font(.system(size: 16))
                    .foregroundColor(textBody)

                Text(formattedGoalDate)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(accentViolet)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: accentViolet.opacity(0.15), radius: 12, x: 0, y: 4)
                    )
            }
        }
    }

    private var newChapterSection: some View {
        VStack(spacing: 16) {
            Text("Start a new chapter")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(textHeading)

            Text("Today marks the beginning of a new,\nbetter page in your life.")
                .font(.system(size: 16))
                .foregroundColor(textBody)
                .multilineTextAlignment(.center)

            // Benefit chips - wrapped grid
            FlowLayout(spacing: 10) {
                ForEach(benefitChips, id: \.text) { chip in
                    BenefitChip(emoji: chip.emoji, text: chip.text, color: chip.color)
                }
            }
            .padding(.top, 8)
        }
    }

    private var pathToFreedomSection: some View {
        VStack(spacing: 20) {
            // Mosque emoji as hero
            Text("🕌")
                .font(.system(size: 80))
                .shadow(color: sunriseGlow.opacity(0.3), radius: 20, x: 0, y: 10)

            Text("Your Path to Freedom")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(textHeading)

            // Benefits list
            VStack(alignment: .leading, spacing: 12) {
                PrePaywallBenefitRow(emoji: "🎯", text: "Personalized recovery plan just for you")
                PrePaywallBenefitRow(emoji: "🤲", text: "Daily Islamic guidance and support")
                PrePaywallBenefitRow(emoji: "💪", text: "Tools to overcome daily temptation")
                PrePaywallBenefitRow(emoji: "⚡", text: "Find renewed energy and purpose")
            }

            // Testimonial
            PrePaywallTestimonialCard(quote: testimonials[0].quote, starColor: starColor, textBody: textBody)
        }
        .padding(.vertical, 24)
    }

    private var breakFreeSection: some View {
        VStack(spacing: 20) {
            // Quran emoji
            Text("📖")
                .font(.system(size: 80))
                .shadow(color: sunriseGlow.opacity(0.3), radius: 20, x: 0, y: 10)

            Text("Break Free From the Cycle")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(textHeading)

            VStack(alignment: .leading, spacing: 12) {
                PrePaywallBenefitRow(emoji: "🔄", text: "End the cycle of guilt and shame")
                PrePaywallBenefitRow(emoji: "📖", text: "Get daily Quranic encouragement")
                PrePaywallBenefitRow(emoji: "🤝", text: "Accountability to stay on track")
                PrePaywallBenefitRow(emoji: "🎯", text: "Start on the path to freedom")
            }

            PrePaywallTestimonialCard(quote: testimonials[1].quote, starColor: starColor, textBody: textBody)
        }
        .padding(.vertical, 24)
    }

    private var drawTheLineSection: some View {
        VStack(spacing: 20) {
            // Card with climbing/striving imagery
            VStack(spacing: 16) {
                Text("🧗")
                    .font(.system(size: 60))

                Text("It's time to draw the line")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(textHeading)

                Text("Return teaches Islamic principles that make lasting, life-long freedom from pornography possible.")
                    .font(.system(size: 15))
                    .foregroundColor(textBody)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                VStack(alignment: .leading, spacing: 16) {
                    Text("How to reach your goal:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(textHeading)

                    PrePaywallHowToRow(icon: "person.fill.viewfinder", text: "Use Return's custom recovery plan")
                    PrePaywallHowToRow(icon: "exclamationmark.circle.fill", text: "Press the Panic Button when feeling tempted")
                    PrePaywallHowToRow(icon: "person.fill.checkmark", text: "Renew your niyyah daily")
                    PrePaywallHowToRow(icon: "chart.line.uptrend.xyaxis", text: "Track progress towards your goal")
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
            )
        }
        .padding(.vertical, 24)
    }

    private var liveTheLifeSection: some View {
        VStack(spacing: 20) {
            // Sun emoji
            Text("☀️")
                .font(.system(size: 80))
                .shadow(color: sunriseGlow.opacity(0.4), radius: 25, x: 0, y: 10)

            Text("Time to Live the Life\nYou Envision")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(textHeading)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                PrePaywallBenefitRow(emoji: "🧠", text: "Build mental clarity and focus")
                PrePaywallBenefitRow(emoji: "⚡", text: "Feel increased energy levels")
                PrePaywallBenefitRow(emoji: "💪", text: "Achieve greater self-control")
                PrePaywallBenefitRow(emoji: "😊", text: "Live with improved confidence")
            }

            PrePaywallTestimonialCard(quote: testimonials[3].quote, starColor: starColor, textBody: textBody)
        }
        .padding(.vertical, 24)
    }

    private var idealFutureSection: some View {
        VStack(spacing: 20) {
            // Trophy emoji
            Text("🏆")
                .font(.system(size: 80))
                .shadow(color: sunriseGlow.opacity(0.3), radius: 20, x: 0, y: 10)

            Text("The Ideal Future\nVersion of You")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(textHeading)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                PrePaywallBenefitRow(emoji: "🤲", text: "Start a stronger connection with Allah")
                PrePaywallBenefitRow(emoji: "❤️", text: "Rebuild authentic relationships")
                PrePaywallBenefitRow(emoji: "🕌", text: "Live aligned with your deen")
                PrePaywallBenefitRow(emoji: "🌟", text: "Begin living with integrity")
            }

            PrePaywallTestimonialCard(quote: testimonials[4].quote, starColor: starColor, textBody: textBody)
        }
        .padding(.vertical, 24)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, textMuted.opacity(0.3), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.horizontal, 40)
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Benefit Chip
private struct BenefitChip: View {
    let emoji: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(color)
        )
    }
}

// MARK: - Benefit Row
private struct PrePaywallBenefitRow: View {
    let emoji: String
    let text: String

    private let textBody = Color(hex: "5A4A66")

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 20))
                .frame(width: 28)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(textBody)
        }
    }
}

// MARK: - How To Row
private struct PrePaywallHowToRow: View {
    let icon: String
    let text: String

    private let accentViolet = Color(hex: "7B5E99")
    private let textBody = Color(hex: "5A4A66")

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(accentViolet)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(textBody)
        }
    }
}

// MARK: - Testimonial Card
private struct PrePaywallTestimonialCard: View {
    let quote: String
    let starColor: Color
    let textBody: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Avatar
                Circle()
                    .fill(Color(hex: "2D2438"))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )

                Text("Anonymous")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "2D2438"))

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
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Flow Layout (for benefit chips)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return CGSize(width: containerWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

// MARK: - Pre-Paywall Mountains View
struct PrePaywallMountainsView: View {
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
    PrePaywallScreen(
        userName: "Zak",
        onContinue: {}
    )
}
