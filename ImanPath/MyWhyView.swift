//
//  MyWhyView.swift
//  ImanPath
//
//  My Why - Your reasons for this journey
//

import SwiftUI
import SwiftData

// MARK: - WhyCategory Enum (for UI display)
enum WhyCategory: String, CaseIterable {
    case faith = "For Allah"
    case self_ = "For Myself"
    case family = "For My Family"
    case marriage = "For My Marriage"
    case future = "For My Future"
    case health = "For My Health"
    case custom = "Other"

    var icon: String {
        switch self {
        case .faith: return "moon.stars.fill"
        case .self_: return "person.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .marriage: return "heart.fill"
        case .future: return "sun.horizon.fill"
        case .health: return "heart.text.square.fill"
        case .custom: return "sparkle"
        }
    }

    var color: Color {
        switch self {
        case .faith: return Color(hex: "A78BDA")
        case .self_: return Color(hex: "5B9A9A")
        case .family: return Color(hex: "E8B86D")
        case .marriage: return Color(hex: "E88B8B")
        case .future: return Color(hex: "74B886")
        case .health: return Color(hex: "6BA3D6")
        case .custom: return Color(hex: "94A3B8")
        }
    }
}

// WhyEntry model is now in Models/WhyEntry.swift
// Use WhyCategory(rawValue: entry.category) to get the enum for display

// Helper extension for SwiftData WhyEntry
extension WhyEntry {
    var categoryEnum: WhyCategory {
        WhyCategory(rawValue: category) ?? .custom
    }
}

// MARK: - My Why View
struct MyWhyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WhyEntry.createdDate, order: .reverse) private var whyEntries: [WhyEntry]

    @State private var showingEditor: Bool = false
    @State private var editingEntry: WhyEntry? = nil

    private let primaryGreen = Color(hex: "74B886")
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

            // Accent glow
            RadialGradient(
                colors: [primaryGreen.opacity(0.06), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                MyWhyHeader(onDismiss: { dismiss() })

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Inspirational header
                        VStack(spacing: 12) {
                            Text("Remember Your Why")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(.white)

                            Text("When the journey gets hard, these reasons will guide you back to your path.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)

                        // Stats
                        HStack(spacing: 16) {
                            WhyStatBubble(
                                value: "\(whyEntries.count)",
                                label: "Reasons",
                                icon: "heart.fill",
                                color: primaryGreen
                            )

                            WhyStatBubble(
                                value: "\(uniqueCategories)",
                                label: "Areas of Life",
                                icon: "sparkles",
                                color: tealAccent
                            )
                        }
                        .padding(.horizontal, 20)

                        // Why cards
                        if whyEntries.isEmpty {
                            EmptyWhyState(onAdd: { showingEditor = true })
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(whyEntries) { entry in
                                    WhyCard(
                                        entry: entry,
                                        onEdit: {
                                            editingEntry = entry
                                            showingEditor = true
                                        },
                                        onDelete: {
                                            withAnimation {
                                                modelContext.delete(entry)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Quranic reminder
                        VStack(spacing: 8) {
                            Text("\"And whoever fears Allah - He will make for him a way out.\"")
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .italic()
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)

                            Text("— Quran 65:2")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 24)

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
                    Button(action: {
                        editingEntry = nil
                        showingEditor = true
                    }) {
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
        .fullScreenCover(isPresented: $showingEditor) {
            MyWhyEditorView(existingEntry: editingEntry)
        }
    }

    private var uniqueCategories: Int {
        Set(whyEntries.map { $0.category }).count
    }
}

// MARK: - Header
struct MyWhyHeader: View {
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Text("My Why")
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

// MARK: - Stat Bubble
struct WhyStatBubble: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
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

// MARK: - Why Card
struct WhyCard: View {
    let entry: WhyEntry
    var onEdit: () -> Void
    var onDelete: () -> Void

    @State private var showingMenu: Bool = false

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: entry.createdDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                // Category badge
                HStack(spacing: 6) {
                    Image(systemName: entry.categoryEnum.icon)
                        .font(.system(size: 12))
                    Text(entry.category)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(entry.categoryEnum.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(entry.categoryEnum.color.opacity(0.15))
                )

                Spacer()

                // Menu
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 32, height: 32)
                }
            }

            // Content
            Text(entry.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(6)

            // Date
            Text("Added \(dateString)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "141A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(entry.categoryEnum.color.opacity(0.15), lineWidth: 1)
                )
        )
        // Accent line on left
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(entry.categoryEnum.color)
                    .frame(width: 4)
                    .padding(.vertical, 16)
                Spacer()
            }
            .padding(.leading, 8)
        )
    }
}

// MARK: - Empty State
struct EmptyWhyState: View {
    var onAdd: () -> Void

    private let tealAccent = Color(hex: "5B9A9A")

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(tealAccent.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 36))
                    .foregroundColor(tealAccent.opacity(0.6))
            }

            Text("No reasons yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            Text("Add your first reason for this journey.\nThis will help you stay strong during difficult moments.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add Your First Why")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(tealAccent)
                )
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Toolkit Card (for HomeView)
struct MyWhyToolkitCard: View {
    var whyCount: Int = 0
    var onTap: () -> Void = {}

    private let primaryGreen = Color(hex: "74B886")

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(primaryGreen.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 20))
                        .foregroundColor(primaryGreen)
                }

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text("My Why")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(whyCount > 0 ? "\(whyCount) reasons saved" : "Add your reasons")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "1A2230"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(primaryGreen.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MyWhyView()
}
