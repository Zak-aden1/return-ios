//
//  RenewPromiseView.swift
//  ImanPath
//
//  Renew commitment screen after breathing exercise
//

import SwiftUI

struct RenewPromiseView: View {
    @Environment(\.dismiss) private var dismiss
    var onComplete: () -> Void

    @State private var typedText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    // Colors
    private let calmTeal = Color(hex: "5B9A9A")
    private let cardBg = Color(hex: "1A2737")

    private var isAmeenTyped: Bool {
        typedText.lowercased().trimmingCharacters(in: .whitespaces) == "ameen"
    }

    var body: some View {
        ZStack {
            // Background
            SpaceBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Spacer()

                        Button(action: {
                            onComplete()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.15)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Spacer().frame(height: 32)

                    // Title
                    Text("Renew Your Promise")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Spacer().frame(height: 32)

                    // Verse Card
                    VStack(spacing: 20) {
                        // Reference badge
                        Text("Quran 16:91")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "8A9BAE"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )

                        // Arabic text
                        Text("وَأَوْفُوا بِعَهْدِ اللَّهِ إِذَا عَاهَدتُّمْ وَلَا تَنقُضُوا الْأَيْمَانَ بَعْدَ تَوْكِيدِهَا")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)

                        // Transliteration
                        Text("Wa awfū bi'ahdillāhi idhā 'āhadttum walā tanquḍul-aymāna ba'da tawkīdihā")
                            .font(.system(size: 14, weight: .regular))
                            .italic()
                            .foregroundColor(calmTeal)
                            .multilineTextAlignment(.center)

                        // Translation
                        Text("And fulfill the covenant of Allah when you make a pledge, and do not break oaths after confirming them.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "8A9BAE"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(calmTeal.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)

                    // Reminder section
                    VStack(spacing: 16) {
                        // Icon
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 32))
                            .foregroundColor(calmTeal)

                        Text("You made a promise to Allah to stay clean. This is your moment to renew that commitment with sincerity.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        Text("Every time you resist, you grow stronger in faith.")
                            .font(.system(size: 14, weight: .regular))
                            .italic()
                            .foregroundColor(Color(hex: "8A9BAE"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)

                    Spacer().frame(height: 40)

                    // Type Ameen section
                    VStack(spacing: 12) {
                        Text("Type \"Ameen\" to renew your promise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "8A9BAE"))

                        TextField("", text: $typedText)
                            .placeholder(when: typedText.isEmpty) {
                                Text("Ameen...")
                                    .foregroundColor(Color(hex: "5A6A7A"))
                            }
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isAmeenTyped ? calmTeal : Color.white.opacity(0.15),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .focused($isTextFieldFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)

                    // Continue button
                    Button(action: {
                        onComplete()
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 18))
                            Text("I Will Stay Clean")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(isAmeenTyped ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(isAmeenTyped ? calmTeal : Color.white.opacity(0.1))
                                .shadow(color: isAmeenTyped ? calmTeal.opacity(0.4) : .clear, radius: 12, y: 4)
                        )
                    }
                    .disabled(!isAmeenTyped)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 48)
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    RenewPromiseView(onComplete: {})
}
