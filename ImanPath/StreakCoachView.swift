//
//  StreakCoachView.swift
//  ImanPath
//
//  Main chat interface for Streak Coach AI companion
//

import SwiftUI
import SwiftData

struct StreakCoachView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var conversation: ChatConversation?
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var citationMap = CitationMap()
    @State private var errorMessage: String?

    // For scrolling to bottom
    @State private var scrollProxy: ScrollViewProxy?

    // Citation navigation
    @State private var selectedJournal: JournalEntry?
    @State private var showJournalDetail = false
    @State private var showMyWhy = false

    private let anthropicService = AnthropicService()
    private let rateLimiter = CoachRateLimiter()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Message counter (always visible)
                    messageCounterBar

                    // Messages
                    messagesView

                    // Action chips (after last AI message)
                    if let lastMessage = sortedMessages.last,
                       lastMessage.sender == .assistant {
                        ActionChips(
                            suggestedAction: lastMessage.suggestedAction,
                            onBreathing: { navigateToBreathing() },
                            onJournal: { navigateToJournal() },
                            onCheckIn: { navigateToCheckIn() },
                            onPanic: { navigateToPanic() },
                            onDua: { navigateToDua() }
                        )
                        .padding(.vertical, 12)
                    }

                    // Input bar
                    CoachInputBar(
                        text: $messageText,
                        isLoading: isLoading,
                        isDisabled: rateLimiter.isAtLimit(),
                        onSend: sendMessage
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "74B886"))
                        Text("Coach")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: startNewConversation) {
                        Image(systemName: "plus.message")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "74B886"))
                    }
                }
            }
            .toolbarBackground(Color(hex: "0A1628"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            loadConversation()
        }
        .sheet(isPresented: $showJournalDetail) {
            if let journal = selectedJournal {
                NavigationStack {
                    JournalEntryDetailView(entry: journal)
                }
            }
        }
        .sheet(isPresented: $showMyWhy) {
            NavigationStack {
                MyWhyView()
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if sortedMessages.isEmpty {
                        CoachWelcome(
                            currentStreak: currentStreak,
                            messagesRemaining: rateLimiter.remainingMessages(),
                            onSuggestionTap: { suggestion in
                                messageText = suggestion
                                sendMessage()
                            }
                        )
                    } else {
                        ForEach(sortedMessages) { message in
                            CoachBubble(
                                message: message,
                                citationMap: citationMap,
                                onCitationTap: { citationId in
                                    handleCitationTap(citationId)
                                },
                                onRetry: message.isError ? {
                                    retryAfterError(errorMessage: message)
                                } : nil
                            )
                            .id(message.id)
                        }

                        if isLoading {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: sortedMessages.count) { _, _ in
                scrollToBottom()
            }
        }
    }

    private var messageCounterBar: some View {
        let usage = rateLimiter.getUsage()
        let isAtLimit = rateLimiter.isAtLimit()

        return HStack(spacing: 8) {
            Image(systemName: "message.fill")
                .font(.system(size: 12))
                .foregroundColor(isAtLimit ? Color(hex: "F59E0B") : Color(hex: "5EEAD4"))

            Text(isAtLimit ? "Limit reached. Resets at midnight." : "\(usage.messagesCount)/30 messages today")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isAtLimit ? Color(hex: "F59E0B") : Color(hex: "5EEAD4"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A2737").opacity(0.8))
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Computed Properties

    private var sortedMessages: [ChatMessage] {
        conversation?.sortedMessages ?? []
    }

    private var currentStreak: Int {
        let dataManager = DataManager(modelContext: modelContext)
        return dataManager.getHomeStats().currentStreak
    }

    // MARK: - Actions

    private func loadConversation() {
        let dataManager = DataManager(modelContext: modelContext)
        conversation = dataManager.getOrCreateCurrentConversation()

        // Build citation map for existing messages
        let dataPacker = StreakCoachDataPacker(modelContext: modelContext)
        let (_, map) = dataPacker.buildDataPack()
        citationMap = map
    }

    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard !rateLimiter.isAtLimit() else {
            return
        }

        // Track analytics
        AnalyticsManager.shared.trackAICoachUsed()

        let dataManager = DataManager(modelContext: modelContext)

        // Add user message
        guard let conv = conversation else { return }
        let _ = dataManager.addMessageToConversation(conv, sender: .user, content: trimmedText)

        messageText = ""
        isLoading = true
        errorMessage = nil
        scrollToBottom()

        // Build data pack
        let dataPacker = StreakCoachDataPacker(modelContext: modelContext)
        let (dataPack, map) = dataPacker.buildDataPack()
        citationMap = map

        // Send to API with streaming
        Task {
            do {
                var fullResponse = ""
                var assistantMessage: ChatMessage?

                try await anthropicService.sendMessageStreaming(
                    userMessage: trimmedText,
                    conversationHistory: Array(sortedMessages.dropLast()),  // Exclude the message we just added
                    dataPack: dataPack
                ) { chunk in
                    // Called on each text chunk received
                    fullResponse += chunk

                    Task { @MainActor in
                        if let message = assistantMessage {
                            // Update existing message with new content
                            dataManager.updateMessageContent(message, content: fullResponse)
                        } else {
                            // First chunk - create the message and hide typing indicator
                            assistantMessage = dataManager.addMessageToConversation(
                                conv,
                                sender: .assistant,
                                content: fullResponse
                            )
                            isLoading = false
                            scrollToBottom()
                        }
                    }
                }

                // Streaming complete - record the message
                await MainActor.run {
                    rateLimiter.recordMessage()
                    scrollToBottom()
                }
            } catch {
                // Show typing for a moment before revealing error (feels more natural)
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription

                    // Add error message to chat
                    let errorMsg = dataManager.addMessageToConversation(
                        conv,
                        sender: .assistant,
                        content: "I'm having trouble connecting right now. Please try again in a moment."
                    )
                    dataManager.markMessageAsError(errorMsg, errorMessage: error.localizedDescription)
                }
            }
        }
    }

    private func startNewConversation() {
        let dataManager = DataManager(modelContext: modelContext)
        if let conv = conversation {
            dataManager.clearConversation(conv)
        } else {
            conversation = dataManager.createNewConversation()
        }
    }

    private func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) {
                if isLoading {
                    scrollProxy?.scrollTo("typing", anchor: .bottom)
                } else if let lastMessage = sortedMessages.last {
                    scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }

    private func retryAfterError(errorMessage: ChatMessage) {
        let dataManager = DataManager(modelContext: modelContext)

        // Find the last user message before this error
        let messages = sortedMessages
        guard let errorIndex = messages.firstIndex(where: { $0.id == errorMessage.id }),
              errorIndex > 0 else { return }

        // Get the user message that triggered this error
        let userMessage = messages[errorIndex - 1]
        guard userMessage.sender == .user else { return }

        // Delete the error message
        dataManager.deleteMessage(errorMessage)

        // Resend the user's message
        let userText = userMessage.content
        isLoading = true
        scrollToBottom()

        // Build data pack
        let dataPacker = StreakCoachDataPacker(modelContext: modelContext)
        let (dataPack, map) = dataPacker.buildDataPack()
        citationMap = map

        guard let conv = conversation else { return }

        Task {
            do {
                var fullResponse = ""
                var assistantMessage: ChatMessage?

                try await anthropicService.sendMessageStreaming(
                    userMessage: userText,
                    conversationHistory: Array(sortedMessages.dropLast()),
                    dataPack: dataPack
                ) { chunk in
                    fullResponse += chunk

                    Task { @MainActor in
                        if let message = assistantMessage {
                            dataManager.updateMessageContent(message, content: fullResponse)
                        } else {
                            assistantMessage = dataManager.addMessageToConversation(
                                conv,
                                sender: .assistant,
                                content: fullResponse
                            )
                            isLoading = false
                            scrollToBottom()
                        }
                    }
                }

                await MainActor.run {
                    rateLimiter.recordMessage()
                    scrollToBottom()
                }
            } catch {
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                await MainActor.run {
                    isLoading = false

                    let errorMsg = dataManager.addMessageToConversation(
                        conv,
                        sender: .assistant,
                        content: "Still having trouble connecting. Please try again."
                    )
                    dataManager.markMessageAsError(errorMsg, errorMessage: error.localizedDescription)
                }
            }
        }
    }

    private func handleCitationTap(_ citationId: String) {
        if citationId.hasPrefix("journal:") {
            if let journal = citationMap.journals[citationId] {
                selectedJournal = journal
                showJournalDetail = true
            }
        } else if citationId.hasPrefix("checkin:") {
            // TODO: Create CheckInDetailView and navigate to it
            // For now, check-in citations are not tappable
            #if DEBUG
            if let checkIn = citationMap.checkIns[citationId] {
                print("Check-in detail view not yet implemented: \(checkIn.date)")
            }
            #endif
        } else if citationId.hasPrefix("why:") {
            if citationMap.whyEntries[citationId] != nil {
                showMyWhy = true
            }
        }
    }

    // MARK: - Navigation

    @State private var showBreathing = false
    @State private var showJournal = false
    @State private var showCheckIn = false
    @State private var showPanic = false
    @State private var showDua = false

    private func navigateToBreathing() {
        dismiss()
        // Post notification for HomeView to show breathing
        NotificationCenter.default.post(name: .showBreathing, object: nil)
    }

    private func navigateToJournal() {
        dismiss()
        NotificationCenter.default.post(name: .showJournal, object: nil)
    }

    private func navigateToCheckIn() {
        dismiss()
        NotificationCenter.default.post(name: .showCheckIn, object: nil)
    }

    private func navigateToPanic() {
        dismiss()
        NotificationCenter.default.post(name: .showPanic, object: nil)
    }

    private func navigateToDua() {
        dismiss()
        NotificationCenter.default.post(name: .showDua, object: nil)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showBreathing = Notification.Name("showBreathing")
    static let showJournal = Notification.Name("showJournal")
    static let showCheckIn = Notification.Name("showCheckIn")
    static let showPanic = Notification.Name("showPanic")
    static let showDua = Notification.Name("showDua")
}

#Preview {
    StreakCoachView()
        .modelContainer(for: [
            User.self,
            Streak.self,
            CheckIn.self,
            JournalEntry.self,
            WhyEntry.self,
            ChatMessage.self,
            ChatConversation.self
        ], inMemory: true)
}
