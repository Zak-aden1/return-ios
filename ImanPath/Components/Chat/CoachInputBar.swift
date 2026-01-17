//
//  CoachInputBar.swift
//  ImanPath
//
//  Text input bar for Streak Coach chat
//

import SwiftUI

struct CoachInputBar: View {
    @Binding var text: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var onSend: () -> Void

    @FocusState private var isFocused: Bool

    private let accentColor = Color(hex: "74B886")

    var body: some View {
        HStack(spacing: 12) {
            // Text field with custom placeholder
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Message your coach...")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "94A3B8"))
                }
                TextField("", text: $text, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .lineLimit(1...5)
                    .focused($isFocused)
                    .disabled(isDisabled || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "1A2737"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isFocused ? accentColor.opacity(0.5) : Color(hex: "334155"), lineWidth: 1)
            )

            // Send button
            Button(action: {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading {
                    onSend()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(canSend ? accentColor : Color(hex: "334155"))
                        .frame(width: 40, height: 40)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(canSend ? Color(hex: "0A1628") : Color(hex: "64748B"))
                    }
                }
            }
            .disabled(!canSend || isLoading)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(hex: "0A1628")
                .shadow(color: .black.opacity(0.3), radius: 8, y: -2)
        )
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isDisabled
    }
}

#Preview {
    VStack {
        Spacer()

        CoachInputBar(text: .constant(""), onSend: {})

        CoachInputBar(text: .constant("Hello"), onSend: {})

        CoachInputBar(text: .constant(""), isLoading: true, onSend: {})
    }
    .background(Color.appBackground)
}
