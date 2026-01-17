//
//  JournalView.swift
//  ImanPath
//
//  Journal - Private reflections and thoughts
//

import SwiftUI
import SwiftData

// JournalEntry model is now in Models/JournalEntry.swift

// MARK: - Journal View
struct JournalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var journalEntries: [JournalEntry]

    @State private var searchText: String = ""
    @State private var showingComposer: Bool = false
    @State private var selectedEntry: JournalEntry? = nil

    private let primaryGreen = Color(hex: "74B886")
    private let tealAccent = Color(hex: "5B9A9A")

    private var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return journalEntries
        }
        return journalEntries.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    private var entriesThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return journalEntries.filter { $0.date >= weekAgo }.count
    }

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
                colors: [tealAccent.opacity(0.05), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                JournalHeader(onDismiss: { dismiss() })

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Stats Row
                        JournalStatsRow(
                            totalEntries: journalEntries.count,
                            entriesThisWeek: entriesThisWeek
                        )
                        .padding(.horizontal, 20)

                        // Search Bar
                        JournalSearchBar(searchText: $searchText)
                            .padding(.horizontal, 20)

                        // Writing Prompt
                        WritingPromptCard(onTap: {
                            showingComposer = true
                        })
                        .padding(.horizontal, 20)

                        // Entries List
                        if filteredEntries.isEmpty {
                            EmptyJournalState(hasFilter: !searchText.isEmpty)
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEntries) { entry in
                                    JournalEntryCard(entry: entry)
                                        .onTapGesture {
                                            selectedEntry = entry
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 8)
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingComposer = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [primaryGreen, primaryGreen.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: primaryGreen.opacity(0.4), radius: 12, y: 4)
                            )
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingComposer) {
            JournalComposerView()
        }
        .fullScreenCover(item: $selectedEntry) { entry in
            JournalEntryDetailView(entry: entry)
        }
    }
}

// MARK: - Journal Header
struct JournalHeader: View {
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Text("Your Journal")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.white)

            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Stats Row
struct JournalStatsRow: View {
    let totalEntries: Int
    let entriesThisWeek: Int

    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        HStack(spacing: 16) {
            StatBubble(value: "\(totalEntries)", label: "Total Entries", color: tealAccent)
            StatBubble(value: "\(entriesThisWeek)", label: "This Week", color: Color(hex: "74B886"))
        }
    }
}

struct StatBubble: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "141A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Search Bar
struct JournalSearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.4))

            TextField("Search entries...", text: $searchText)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .accentColor(Color(hex: "5B9A9A"))

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "1A2230"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Writing Prompt Card
struct WritingPromptCard: View {
    var onTap: () -> Void

    private let prompts = [
        "What are you grateful for today?",
        "How did you handle challenges today?",
        "Write a letter to your future self.",
        "What triggers did you notice?",
        "What would you tell someone starting this journey?"
    ]

    @State private var currentPrompt: String = ""

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E8B86D").opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "E8B86D"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Writing Prompt")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))

                    Text(currentPrompt)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "1A2230"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "E8B86D").opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            currentPrompt = prompts.randomElement() ?? prompts[0]
        }
    }
}

// MARK: - Journal Entry Card
struct JournalEntryCard: View {
    let entry: JournalEntry

    private var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(entry.date) {
            formatter.dateFormat = "'Today,' h:mm a"
        } else if Calendar.current.isDateInYesterday(entry.date) {
            formatter.dateFormat = "'Yesterday,' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header - just date and optional mood
            HStack {
                Text(dateString)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                // Mood indicator
                if let mood = entry.mood {
                    HStack(spacing: 5) {
                        Image(systemName: moodIcon(for: mood))
                            .font(.system(size: 11))
                        Text("\(mood)/10")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(moodColor(for: mood).opacity(0.8))
                }
            }

            // Content preview
            Text(entry.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "141A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func moodIcon(for mood: Int) -> String {
        switch mood {
        case 1...3: return "cloud.rain.fill"
        case 4...5: return "cloud.fill"
        case 6...7: return "sun.haze.fill"
        case 8...10: return "sun.max.fill"
        default: return "circle.fill"
        }
    }

    private func moodColor(for mood: Int) -> Color {
        switch mood {
        case 1...3: return Color(hex: "D68B8B")
        case 4...5: return Color(hex: "E8B86D")
        case 6...7: return Color(hex: "5B9A9A")
        case 8...10: return Color(hex: "74B886")
        default: return Color(hex: "5B9A9A")
        }
    }
}

// MARK: - Empty State
struct EmptyJournalState: View {
    let hasFilter: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: hasFilter ? "doc.text.magnifyingglass" : "book.closed.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))

            Text(hasFilter ? "No entries found" : "Start Your Journal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))

            Text(hasFilter ? "Try adjusting your filters or search" : "Tap the + button to write your first entry")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Journal Home Card (for HomeView)
struct JournalHomeCard: View {
    var totalEntries: Int = 0
    var onTap: () -> Void = {}

    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(tealAccent.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Circle()
                        .stroke(tealAccent.opacity(0.3), lineWidth: 1)
                        .frame(width: 48, height: 48)

                    Image(systemName: "book.fill")
                        .font(.system(size: 20))
                        .foregroundColor(tealAccent)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Journal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(totalEntries > 0 ? "\(totalEntries) entries written" : "Start writing your thoughts")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "8A9BAE"))
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "64748B"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "0F172A").opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "334155").opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    JournalView()
}
