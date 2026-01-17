//
//  MyWhyEditorView.swift
//  ImanPath
//
//  Add or edit a "Why" reason
//

import SwiftUI
import SwiftData

struct MyWhyEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var existingEntry: WhyEntry? = nil

    @State private var selectedCategory: WhyCategory = .faith
    @State private var content: String = ""
    @State private var showingDiscardAlert: Bool = false

    @FocusState private var isTextFocused: Bool

    private let primaryGreen = Color(hex: "74B886")

    private var isEditing: Bool {
        existingEntry != nil
    }

    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0A0E14")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                EditorHeader(
                    title: isEditing ? "Edit Reason" : "Add Reason",
                    canSave: canSave,
                    onClose: {
                        if content.isEmpty || content == existingEntry?.content {
                            dismiss()
                        } else {
                            showingDiscardAlert = true
                        }
                    },
                    onSave: saveEntry
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Prompt
                        VStack(spacing: 8) {
                            Text(isEditing ? "Update your reason" : "Why are you on this journey?")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white)

                            Text("This will help you stay strong during difficult moments.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 16)

                        // Category selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))

                            CategorySelector(selectedCategory: $selectedCategory)
                        }
                        .padding(.horizontal, 20)

                        // Text input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Reason")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $content)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .focused($isTextFocused)
                                    .frame(minHeight: 180)

                                if content.isEmpty {
                                    Text(placeholderText)
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.white.opacity(0.25))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "141A22"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isTextFocused ? selectedCategory.color.opacity(0.4) : Color.white.opacity(0.06),
                                                lineWidth: 1
                                            )
                                    )
                            )

                            // Character count
                            HStack {
                                Spacer()
                                Text("\(content.count) characters")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .padding(.horizontal, 20)

                        // Inspiration prompts
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Need inspiration?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))

                            VStack(spacing: 10) {
                                ForEach(inspirationPrompts, id: \.self) { prompt in
                                    InspirationPromptButton(prompt: prompt) {
                                        content = prompt
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard", role: .destructive) { dismiss() }
        } message: {
            Text("Your changes will be lost if you go back now.")
        }
        .onAppear {
            if let existing = existingEntry {
                selectedCategory = existing.categoryEnum
                content = existing.content
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFocused = true
            }
        }
    }

    private var placeholderText: String {
        switch selectedCategory {
        case .faith:
            return "I want to purify my heart and get closer to Allah..."
        case .self_:
            return "I deserve to be free from this struggle..."
        case .family:
            return "My family deserves the best version of me..."
        case .marriage:
            return "I want to be fully present for my spouse..."
        case .future:
            return "I'm building the foundation for my future..."
        case .health:
            return "I want to protect my mental and physical health..."
        case .custom:
            return "Write your reason here..."
        }
    }

    private var inspirationPrompts: [String] {
        switch selectedCategory {
        case .faith:
            return [
                "I want to face Allah with a pure heart on the Day of Judgment.",
                "Every time I resist, I get closer to Allah.",
                "I want my duas to be answered without this barrier."
            ]
        case .self_:
            return [
                "I'm tired of the shame and guilt cycle.",
                "I want to look in the mirror and feel proud.",
                "I deserve peace and clarity of mind."
            ]
        case .family:
            return [
                "My parents raised me better than this.",
                "I want to be a role model for my siblings.",
                "My family deserves my full presence."
            ]
        case .marriage:
            return [
                "My spouse deserves my complete devotion.",
                "I want intimacy to be sacred, not corrupted.",
                "I'm protecting the trust in my relationship."
            ]
        case .future:
            return [
                "My future children deserve a present father.",
                "I'm building the life I actually want.",
                "Every day clean is an investment in my future."
            ]
        case .health:
            return [
                "I want to rewire my brain for real connection.",
                "My mental health depends on breaking free.",
                "I'm protecting my ability to feel genuine emotions."
            ]
        case .custom:
            return [
                "This addiction has taken too much from me.",
                "I refuse to let this control my life anymore.",
                "I'm stronger than my urges."
            ]
        }
    }

    private func saveEntry() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing = existingEntry {
            // Update existing entry
            existing.category = selectedCategory.rawValue
            existing.content = trimmedContent
        } else {
            // Create new entry
            let entry = WhyEntry(category: selectedCategory.rawValue, content: trimmedContent)
            modelContext.insert(entry)
        }

        dismiss()
    }
}

// MARK: - Editor Header
struct EditorHeader: View {
    let title: String
    let canSave: Bool
    let onClose: () -> Void
    let onSave: () -> Void

    private let primaryGreen = Color(hex: "74B886")

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Button(action: onSave) {
                Text("Save")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(canSave ? primaryGreen : .white.opacity(0.3))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(canSave ? primaryGreen.opacity(0.2) : Color.white.opacity(0.05))
                    )
            }
            .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Category Selector
struct CategorySelector: View {
    @Binding var selectedCategory: WhyCategory

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(WhyCategory.allCases, id: \.self) { category in
                CategoryChip(
                    category: category,
                    isSelected: selectedCategory == category,
                    onTap: { selectedCategory = category }
                )
            }
        }
    }
}

struct CategoryChip: View {
    let category: WhyCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))

                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                }
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(category.color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Inspiration Prompt Button
struct InspirationPromptButton: View {
    let prompt: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "E8B86D"))

                Text(prompt)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1A2230"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MyWhyEditorView()
}
