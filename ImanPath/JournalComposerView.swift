//
//  JournalComposerView.swift
//  ImanPath
//
//  Journal Composer - Writing new entries
//

import SwiftUI
import SwiftData

struct JournalComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Edit mode
    var editingEntry: JournalEntry? = nil

    // Entry data
    @State private var content: String = ""
    @State private var selectedMood: Int? = nil
    @State private var showMoodPicker: Bool = false

    // UI State
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingDiscardAlert: Bool = false

    var prefilledDate: Date? = nil
    var prefilledPrompt: String? = nil

    private var isEditing: Bool { editingEntry != nil }

    private let primaryGreen = Color(hex: "74B886")
    private let tealAccent = Color(hex: "5B9A9A")

    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: prefilledDate ?? Date())
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0A0E14")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ComposerHeader(
                    isEditing: isEditing,
                    canSave: canSave,
                    onClose: {
                        if content.isEmpty || (isEditing && content == editingEntry?.content) {
                            dismiss()
                        } else {
                            showingDiscardAlert = true
                        }
                    },
                    onSave: saveEntry
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Bismillah
                        Text("Bismillah")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .italic()
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.top, 8)

                        // Date
                        Text(dateString)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))

                        // Prompt suggestion (if provided or random)
                        PromptSuggestionRow(prompt: prefilledPrompt)
                            .padding(.horizontal, 20)

                        // Main text area
                        TextEditor(text: $content)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 250)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "141A22"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isTextFieldFocused ? tealAccent.opacity(0.3) : Color.white.opacity(0.06),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .padding(.horizontal, 20)

                        // Placeholder text
                        if content.isEmpty {
                            Text(placeholderText)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white.opacity(0.25))
                                .allowsHitTesting(false)
                                .padding(.horizontal, 36)
                                .padding(.top, -234)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Mood selector
                        MoodSelectorRow(selectedMood: $selectedMood, isExpanded: $showMoodPicker)
                            .padding(.horizontal, 20)

                        // Character count
                        HStack {
                            Spacer()
                            Text("\(content.count) characters")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .alert("Discard Entry?", isPresented: $showingDiscardAlert) {
            Button("Keep Writing", role: .cancel) { }
            Button("Discard", role: .destructive) { dismiss() }
        } message: {
            Text("Your entry will be lost if you go back now.")
        }
        .onAppear {
            // Prefill for editing
            if let entry = editingEntry {
                content = entry.content
                selectedMood = entry.mood
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    private var placeholderText: String {
        "What's on your heart today? Write freely..."
    }

    private func saveEntry() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataManager = DataManager(modelContext: modelContext)

        if let existingEntry = editingEntry {
            // Update existing entry
            dataManager.updateJournalEntry(existingEntry, content: trimmedContent, mood: selectedMood)
        } else {
            // Create new entry
            _ = dataManager.createJournalEntry(content: trimmedContent, mood: selectedMood)
        }
        dismiss()
    }
}

// MARK: - Composer Header
struct ComposerHeader: View {
    var isEditing: Bool = false
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

            Text(isEditing ? "Edit Entry" : "New Entry")
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

// MARK: - Prompt Suggestion
struct PromptSuggestionRow: View {
    let prompt: String?

    private let prompts = [
        "What's one thing you're grateful for right now?",
        "How did you handle a difficult moment today?",
        "What progress have you noticed in yourself?",
        "What would you tell yourself a month ago?",
        "What triggers did you notice today?"
    ]

    @State private var currentPrompt: String = ""
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "E8B86D"))

                    Text("Need inspiration?")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            if isExpanded {
                Text(prompt ?? currentPrompt)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "E8B86D").opacity(0.8))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "E8B86D").opacity(0.08))
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            currentPrompt = prompt ?? prompts.randomElement() ?? prompts[0]
        }
    }
}

// MARK: - Mood Selector
struct MoodSelectorRow: View {
    @Binding var selectedMood: Int?
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))

                    Text(selectedMood != nil ? "Mood: \(selectedMood!)/10" : "Add mood (optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "141A22"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
            }

            if isExpanded {
                HStack(spacing: 8) {
                    ForEach(1...10, id: \.self) { mood in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedMood = selectedMood == mood ? nil : mood
                            }
                        }) {
                            Text("\(mood)")
                                .font(.system(size: 14, weight: selectedMood == mood ? .bold : .medium))
                                .foregroundColor(selectedMood == mood ? .white : .white.opacity(0.5))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(selectedMood == mood ? moodColor(mood) : Color(hex: "1A2230"))
                                )
                        }
                    }
                }
                .padding(.horizontal, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))

                // Mood labels
                HStack {
                    Text("Struggling")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Text("Thriving")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.horizontal, 8)
            }
        }
    }

    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1...3: return Color(hex: "D68B8B")
        case 4...5: return Color(hex: "E8B86D")
        case 6...7: return Color(hex: "5B9A9A")
        case 8...10: return Color(hex: "74B886")
        default: return Color(hex: "5B9A9A")
        }
    }
}

#Preview {
    JournalComposerView()
}
