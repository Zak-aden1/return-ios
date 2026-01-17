//
//  JournalEntryDetailView.swift
//  ImanPath
//
//  Journal Entry Detail - Reading a past entry
//

import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let entry: JournalEntry

    @State private var showingDeleteAlert: Bool = false
    @State private var showingEditSheet: Bool = false

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: entry.date)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: entry.date)
    }

    private let tealAccent = Color(hex: "5B9A9A")

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

            // Subtle accent glow
            RadialGradient(
                colors: [tealAccent.opacity(0.06), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                DetailHeader(
                    onDismiss: { dismiss() },
                    onEdit: { showingEditSheet = true },
                    onDelete: { showingDeleteAlert = true }
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dateString)
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white)

                            Text(timeString)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 24)

                        // Mood (if present)
                        if let mood = entry.mood {
                            MoodDisplay(mood: mood)
                                .padding(.horizontal, 24)
                        }

                        // Divider
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1)
                            .padding(.horizontal, 24)

                        // Content
                        Text(entry.content)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(8)
                            .padding(.horizontal, 24)

                        // Inspirational footer
                        VStack(spacing: 8) {
                            Text("\"And whoever is mindful of Allah, He will make a way out for them.\"")
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .italic()
                                .foregroundColor(.white.opacity(0.3))
                                .multilineTextAlignment(.center)

                            Text("— Quran 65:2")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 32)

                        Spacer(minLength: 60)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .alert("Delete Entry?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                let dataManager = DataManager(modelContext: modelContext)
                dataManager.deleteJournalEntry(entry)
                dismiss()
            }
        } message: {
            Text("This entry will be permanently deleted. This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditSheet) {
            JournalComposerView(editingEntry: entry)
        }
    }
}

// MARK: - Detail Header
struct DetailHeader: View {
    let onDismiss: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showingMenu: Bool = false

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text("Entry")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Mood Display
struct MoodDisplay: View {
    let mood: Int

    private var moodLabel: String {
        switch mood {
        case 1...2: return "Really struggling"
        case 3...4: return "Difficult day"
        case 5...6: return "Getting by"
        case 7...8: return "Feeling good"
        case 9...10: return "Thriving"
        default: return "Mood recorded"
        }
    }

    private var moodColor: Color {
        switch mood {
        case 1...3: return Color(hex: "D68B8B")
        case 4...5: return Color(hex: "E8B86D")
        case 6...7: return Color(hex: "5B9A9A")
        case 8...10: return Color(hex: "74B886")
        default: return Color(hex: "5B9A9A")
        }
    }

    private var moodIcon: String {
        switch mood {
        case 1...3: return "cloud.rain.fill"
        case 4...5: return "cloud.fill"
        case 6...7: return "sun.haze.fill"
        case 8...10: return "sun.max.fill"
        default: return "circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(moodColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: moodIcon)
                    .font(.system(size: 20))
                    .foregroundColor(moodColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Mood: \(mood)/10")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(moodLabel)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Visual mood bar
            MoodBar(mood: mood, color: moodColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "141A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(moodColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Mood Bar
struct MoodBar: View {
    let mood: Int
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...10, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i <= mood ? color : Color.white.opacity(0.1))
                    .frame(width: 4, height: i <= mood ? 20 : 12)
            }
        }
    }
}

#Preview {
    JournalEntryDetailView(
        entry: JournalEntry(
            date: Date(),
            content: "Today I realized that my triggers often come when I'm bored or lonely. I need to find better ways to occupy my time. Maybe I should start reading more Quran in those moments.\n\nThe afternoon was particularly challenging, but I managed to stay strong by going for a walk and calling a friend.",
            mood: 7
        )
    )
}
