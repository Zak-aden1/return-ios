//
//  DuasView.swift
//  ImanPath
//
//  Emergency Duas - Prayers for strength and protection
//

import SwiftUI

// MARK: - Dua Model
struct Dua: Identifiable {
    let id = UUID()
    let arabic: String
    let transliteration: String
    let translation: String
    let source: String
    let category: DuaCategory
}

enum DuaCategory: String {
    case protection = "Protection"
    case strength = "Strength"
    case forgiveness = "Forgiveness"
    case patience = "Patience"
}

// MARK: - Main View
struct DuasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showIntro: Bool = true

    var body: some View {
        ZStack {
            if showIntro {
                DuasIntroView(onContinue: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showIntro = false
                    }
                }, onDismiss: {
                    dismiss()
                })
                .transition(.opacity)
            } else {
                DuasCardsView(onDismiss: {
                    dismiss()
                })
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Intro Screen
struct DuasIntroView: View {
    var onContinue: () -> Void
    var onDismiss: () -> Void

    private let tealAccent = Color(hex: "5B9A9A")
    private let warmGold = Color(hex: "E8B86D")
    private let softBlue = Color(hex: "60A5FA")

    private let benefits: [(title: String, description: String, color: Color)] = [
        ("Spiritual Protection", "Daily duas create a shield of protection around you throughout the day.", Color(hex: "60A5FA")),
        ("Heart Purification", "Regular supplication cleanses the heart and brings you closer to Allah.", Color(hex: "A78BDA")),
        ("Barakah & Blessings", "Allah's mercy and blessings increase through consistent remembrance.", Color(hex: "74B886")),
        ("Inner Peace", "Duas bring tranquility and remove anxiety from the soul.", Color(hex: "5B9A9A"))
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0F1419"),
                    Color(hex: "0A0E14"),
                    Color(hex: "080B0F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle glow
            RadialGradient(
                colors: [softBlue.opacity(0.08), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Title
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(warmGold)

                                Text("Benefits of Daily Duas")
                                    .font(.system(size: 26, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                            }

                            Text("Supplication is the essence of worship")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 16)

                        // Benefits list
                        VStack(spacing: 16) {
                            ForEach(benefits, id: \.title) { benefit in
                                BenefitRow(
                                    title: benefit.title,
                                    description: benefit.description,
                                    color: benefit.color
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Hadith quote
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(softBlue)
                                    .frame(width: 3)
                                    .cornerRadius(2)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("The Prophet ﷺ said:")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(softBlue)

                                    Text("\"Nothing repels the divine decree except supplication, and nothing increases lifespan except righteousness.\"")
                                        .font(.system(size: 15, weight: .regular, design: .serif))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(4)

                                    Text("— At-Tirmidhi")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(softBlue.opacity(0.8))
                                }
                                .padding(.leading, 16)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(softBlue.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(softBlue.opacity(0.15), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 8)
                }

                // Continue button
                Button(action: onContinue) {
                    HStack(spacing: 10) {
                        Text("View Duas")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
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
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Benefit Row
struct BenefitRow: View {
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(title + ":")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                +
                Text(" " + description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .lineSpacing(3)
        }
    }
}

// MARK: - Duas Cards View (Swipeable)
struct DuasCardsView: View {
    var onDismiss: () -> Void

    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0

    private let softBlue = Color(hex: "60A5FA")

    private let duas: [Dua] = [
        Dua(
            arabic: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
            transliteration: "A'udhu billahi minash-shaytanir-rajim",
            translation: "I seek refuge in Allah from the accursed Satan.",
            source: "Quran",
            category: .protection
        ),
        Dua(
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ سَمْعِي وَمِنْ شَرِّ بَصَرِي وَمِنْ شَرِّ لِسَانِي وَمِنْ شَرِّ قَلْبِي",
            transliteration: "Allahumma inni a'udhu bika min sharri sam'i, wa min sharri basari, wa min sharri lisani, wa min sharri qalbi",
            translation: "O Allah, I seek refuge in You from the evil of my hearing, my sight, my tongue, and my heart.",
            source: "Abu Dawud",
            category: .protection
        ),
        Dua(
            arabic: "اللَّهُمَّ حَبِّبْ إِلَيْنَا الْإِيمَانَ وَزَيِّنْهُ فِي قُلُوبِنَا وَكَرِّهْ إِلَيْنَا الْكُفْرَ وَالْفُسُوقَ وَالْعِصْيَانَ",
            transliteration: "Allahumma habbib ilayna al-imana wa zayyinhu fi qulubina, wa karrih ilayna al-kufra wal-fusuqa wal-'isyan",
            translation: "O Allah, make faith beloved to us and beautify it in our hearts, and make disbelief, wickedness, and disobedience hateful to us.",
            source: "Ahmad",
            category: .strength
        ),
        Dua(
            arabic: "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً",
            transliteration: "Rabbana la tuzigh qulubana ba'da idh hadaytana wa hab lana min ladunka rahmah",
            translation: "Our Lord, do not let our hearts deviate after You have guided us, and grant us mercy from Yourself.",
            source: "Quran 3:8",
            category: .strength
        ),
        Dua(
            arabic: "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ",
            transliteration: "Rabbi-j'alni muqimas-salati wa min dhurriyyati, Rabbana wa taqabbal du'a",
            translation: "My Lord, make me an establisher of prayer, and from my descendants. Our Lord, accept my supplication.",
            source: "Quran 14:40",
            category: .strength
        ),
        Dua(
            arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى",
            transliteration: "Allahumma inni as'aluka al-huda wat-tuqa wal-'afafa wal-ghina",
            translation: "O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.",
            source: "Muslim",
            category: .patience
        ),
        Dua(
            arabic: "رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا",
            transliteration: "Rabbana-ghfir lana dhunubana wa israfana fi amrina wa thabbit aqdamana",
            translation: "Our Lord, forgive us our sins and our excesses in our affairs, and make firm our feet.",
            source: "Quran 3:147",
            category: .forgiveness
        ),
        Dua(
            arabic: "يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
            transliteration: "Ya Muqallibal-qulub, thabbit qalbi 'ala dinik",
            translation: "O Turner of hearts, make my heart firm upon Your religion.",
            source: "Tirmidhi",
            category: .strength
        )
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0F1419"),
                    Color(hex: "0A0E14"),
                    Color(hex: "080B0F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow
            RadialGradient(
                colors: [softBlue.opacity(0.1), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }

                    Spacer()

                    Text("Emergency Duas")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // Placeholder for balance
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Progress indicator
                HStack(spacing: 6) {
                    ForEach(0..<duas.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentIndex ? softBlue : Color.white.opacity(0.2))
                            .frame(width: index == currentIndex ? 24 : 8, height: 4)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.top, 20)

                // Card counter
                Text("Dua \(currentIndex + 1) of \(duas.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 12)

                Spacer()

                // Swipeable card
                ZStack {
                    ForEach(duas.indices.reversed(), id: \.self) { index in
                        if abs(index - currentIndex) <= 1 {
                            DuaCard(dua: duas[index])
                                .offset(x: CGFloat(index - currentIndex) * 20 + (index == currentIndex ? dragOffset : 0))
                                .scaleEffect(index == currentIndex ? 1 : 0.95)
                                .opacity(index == currentIndex ? 1 : 0.5)
                                .zIndex(index == currentIndex ? 1 : 0)
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width < -threshold && currentIndex < duas.count - 1 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentIndex += 1
                                }
                            } else if value.translation.width > threshold && currentIndex > 0 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentIndex -= 1
                                }
                            }
                        }
                )
                .padding(.horizontal, 20)

                Spacer()

                // Navigation buttons
                HStack(spacing: 20) {
                    Button(action: {
                        if currentIndex > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex -= 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(currentIndex > 0 ? .white : .white.opacity(0.3))
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(currentIndex > 0 ? 0.1 : 0.05))
                            )
                    }
                    .disabled(currentIndex == 0)

                    Button(action: {
                        if currentIndex < duas.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex += 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(currentIndex < duas.count - 1 ? .white : .white.opacity(0.3))
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(currentIndex < duas.count - 1 ? 0.1 : 0.05))
                            )
                    }
                    .disabled(currentIndex == duas.count - 1)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Dua Card
struct DuaCard: View {
    let dua: Dua

    private let softBlue = Color(hex: "60A5FA")

    var body: some View {
        VStack(spacing: 24) {
            // Category badge
            Text(dua.category.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(softBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(softBlue.opacity(0.15))
                )

            // Arabic
            Text(dua.arabic)
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(12)
                .padding(.horizontal, 8)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 60, height: 1)

            // Transliteration
            Text(dua.transliteration)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)

            // Translation
            Text(dua.translation)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 8)

            // Source
            Text("— \(dua.source)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(softBlue.opacity(0.8))
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "141A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(softBlue.opacity(0.15), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
    }
}

#Preview {
    DuasView()
}
