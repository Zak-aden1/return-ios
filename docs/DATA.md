# ImanPath: Data Architecture (Local-First + Supabase)

---

## Architecture Overview

v1 is local-first with Supabase for AI Coach and Community features.

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS APP                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│   │  SwiftData  │  │ StoreKit 2  │  │  Mixpanel   │             │
│   │  (Storage)  │  │ + Superwall │  │ (Analytics) │             │
│   └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                  │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│   │   Local     │  │  Bundled    │  │  Supabase   │             │
│   │   Notifs    │  │  Content    │  │  Client     │             │
│   └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SUPABASE                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                   Edge Functions                         │   │
│   │  ┌─────────────┐  ┌─────────────┐                       │   │
│   │  │   /coach    │  │ /community  │  (future)             │   │
│   │  │  (Claude)   │  │   (CRUD)    │                       │   │
│   │  └─────────────┘  └─────────────┘                       │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│   │  Postgres   │  │    Auth     │  │  Secrets    │             │
│   │    (DB)     │  │ (Apple/Google)│ │ (API Keys) │             │
│   └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ANTHROPIC API                                 │
│                  (Claude Sonnet 4)                               │
└─────────────────────────────────────────────────────────────────┘
```

**Privacy model:**
- Core data (streaks, check-ins, journals) stays on device
- AI Coach sends context to Supabase Edge Function → Anthropic (not stored)
- Community data (future) will be stored in Supabase Postgres

---

## Tech Stack

| Layer | Choice | Purpose |
|-------|--------|---------|
| **Local DB** | SwiftData | All user data (iOS 17+) |
| **Backend** | Supabase | Edge Functions, Auth, Postgres |
| **AI** | Claude Sonnet 4 | AI Coach via Supabase Edge Function |
| **Subscriptions** | StoreKit 2 | Native Apple IAP handling |
| **Paywall UI** | Superwall | Paywall design, A/B testing, remote config |
| **Analytics** | Mixpanel | Event tracking |
| **Notifications** | UNUserNotificationCenter | Local scheduled notifications |
| **Content** | Bundled JSON | Lessons, verses, prompts |

### Supabase Configuration

```
Project URL: https://vhrrlsadqppjnoxtkccn.supabase.co
Edge Functions:
  - /coach - AI Coach proxy (stores ANTHROPIC_API_KEY in secrets)
  - /community - Community API (future)
```

---

## SwiftData Models

### User

```swift
@Model
final class User {
    // Commitment
    var commitmentDate: Date?
    var commitmentSignedAt: Date?
    
    // Onboarding
    var onboardingCompleted: Bool = false
    var quizResults: QuizResults?
    var recoveryScore: Int?
    
    // Settings
    var notificationsEnabled: Bool = true
    var checkinReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0))!
    
    // Stats (denormalized for fast access)
    var currentStreakDays: Int = 0
    var currentStreakStartDate: Date?
    var longestStreak: Int = 0
    var totalCleanDays: Int = 0
    var lastCheckinDate: Date?
    var currentLesson: Int = 1
    
    // Timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init() {}
}
```

### QuizResults (Embedded)

```swift
struct QuizResults: Codable {
    var struggleDuration: String?      // "< 1 year", "1-3 years", etc.
    var frequency: String?             // "Daily", "Few times a week", etc.
    var escalation: String?            // "Yes", "No", "Not sure"
    var prayerImpact: String?          // "Yes, significantly", "Somewhat", "Not really"
    var relationshipImpact: String?    // "Yes", "No", "Not married yet"
    var guiltLevel: String?            // "Always", "Sometimes", "Rarely"
    var quitAttempts: String?          // "Yes, many times", "Yes, a few times", "First time"
    var relapsePattern: String?        // "Within days", "Few weeks", "Months but return"
}
```

### Streak

```swift
@Model
final class Streak {
    var startedAt: Date
    var endedAt: Date?              // nil if current streak
    var days: Int
    var endReason: String?          // "relapse", "manual_reset", nil if ongoing
    
    var createdAt: Date = Date()
    
    var isActive: Bool {
        endedAt == nil
    }
    
    init(startedAt: Date = Date()) {
        self.startedAt = startedAt
        self.days = 0
    }
}
```

### CheckIn

```swift
@Model
final class CheckIn {
    var date: Date
    var stayedClean: Bool
    var urgeLevel: Int?             // 1-5
    var imanLevel: Int?             // 1-5
    var energyLevel: Int?           // 1-5
    var triggers: [String]          // ["stress", "boredom", "loneliness", etc.]
    
    var createdAt: Date = Date()
    
    init(date: Date, stayedClean: Bool) {
        self.date = date
        self.stayedClean = stayedClean
        self.triggers = []
    }
}
```

### JournalEntry

```swift
@Model
final class JournalEntry {
    var content: String
    var mood: String?               // "sad", "neutral", "okay", "good", "strong"
    var prompt: String?             // The prompt used, if any
    var entryType: String           // "quick", "prompted", "relapse_reflection"
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(content: String, entryType: String = "quick") {
        self.content = content
        self.entryType = entryType
    }
}
```

### LessonProgress ✅ IMPLEMENTED

```swift
@Model
final class LessonProgress {
    var lessonDay: Int                    // Day number (1-30)
    var completedAt: Date                 // When completed
    var reflectionResponse: String?       // User's reflection text (optional)

    init(lessonDay: Int, completedAt: Date = Date(), reflectionResponse: String? = nil) {
        self.lessonDay = lessonDay
        self.completedAt = completedAt
        self.reflectionResponse = reflectionResponse
    }
}
```

**Note**: Lessons are unlocked based on user's streak day (Day 1 available if streak >= 1, etc.) but must be completed sequentially within the available range.

### ChatMessage ✅ IMPLEMENTED

```swift
@Model
final class ChatMessage {
    var id: UUID = UUID()
    var sender: MessageSender       // .user, .assistant
    var content: String
    var timestamp: Date = Date()
    var conversation: ChatConversation?
    var citationsData: String = "[]"  // JSON-encoded [String]
    var suggestedAction: String?
    var isError: Bool = false
    var errorMessage: String?

    // Computed property for citations array
    var citations: [String] { get/set via JSON encode/decode }
}

enum MessageSender: String, Codable {
    case user
    case assistant
}
```

### ChatConversation ✅ IMPLEMENTED

```swift
@Model
final class ChatConversation {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.conversation)
    var messages: [ChatMessage] = []

    var sortedMessages: [ChatMessage] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }
}
```

---

## SwiftData Container Setup

```swift
import SwiftData

@main
struct ImanPathApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            User.self,
            Streak.self,
            CheckIn.self,
            JournalEntry.self,
            WhyEntry.self,
            ChatMessage.self,
            ChatConversation.self,
            LessonProgress.self
        ])
        
        let config = ModelConfiguration(
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
```

---

## Data Manager

Central manager for all data operations:

```swift
import SwiftData
import Foundation

@Observable
class DataManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            AnalyticsManager.shared.trackError("db_save_failed", context: error.localizedDescription)
            #if DEBUG
            print("❌ Save failed: \(error)")
            #endif
        }
    }

    // MARK: - User
    
    func getOrCreateUser() -> User {
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            return user
        }
        let user = User()
        modelContext.insert(user)
        save()
        return user
    }
    
    // MARK: - Streaks
    
    func getCurrentStreak() -> Streak? {
        var descriptor = FetchDescriptor<Streak>(
            predicate: #Predicate { $0.endedAt == nil }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }
    
    func startNewStreak() -> Streak {
        let streak = Streak(startedAt: Date())
        modelContext.insert(streak)
        
        let user = getOrCreateUser()
        user.currentStreakDays = 0
        user.currentStreakStartDate = Date()
        
        save()
        return streak
    }
    
    func resetStreak(reason: String) {
        guard let currentStreak = getCurrentStreak() else { return }
        
        // End current streak
        currentStreak.endedAt = Date()
        currentStreak.endReason = reason
        
        // Update user stats
        let user = getOrCreateUser()
        if currentStreak.days > user.longestStreak {
            user.longestStreak = currentStreak.days
        }
        user.currentStreakDays = 0
        user.currentStreakStartDate = nil
        
        // Start new streak
        _ = startNewStreak()
        
        save()
    }
    
    func incrementStreak() {
        guard let streak = getCurrentStreak() else { return }
        streak.days += 1
        
        let user = getOrCreateUser()
        user.currentStreakDays = streak.days
        user.totalCleanDays += 1
        
        if streak.days > user.longestStreak {
            user.longestStreak = streak.days
        }
        
        save()
    }
    
    // MARK: - Check-ins
    
    func getTodaysCheckin() -> CheckIn? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func hasCheckedInToday() -> Bool {
        getTodaysCheckin() != nil
    }
    
    func submitCheckin(
        stayedClean: Bool,
        urgeLevel: Int?,
        imanLevel: Int?,
        energyLevel: Int?,
        triggers: [String]
    ) -> CheckIn {
        let checkin = CheckIn(date: Date(), stayedClean: stayedClean)
        checkin.urgeLevel = urgeLevel
        checkin.imanLevel = imanLevel
        checkin.energyLevel = energyLevel
        checkin.triggers = triggers
        
        modelContext.insert(checkin)
        
        let user = getOrCreateUser()
        user.lastCheckinDate = Date()
        
        if stayedClean {
            incrementStreak()
        } else {
            resetStreak(reason: "relapse")
        }
        
        save()
        return checkin
    }
    
    func getCheckinHistory(limit: Int = 30) -> [CheckIn] {
        var descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Journal
    
    func createJournalEntry(
        content: String,
        mood: String? = nil,
        prompt: String? = nil,
        entryType: String = "quick"
    ) -> JournalEntry {
        let entry = JournalEntry(content: content, entryType: entryType)
        entry.mood = mood
        entry.prompt = prompt
        modelContext.insert(entry)
        save()
        return entry
    }
    
    func getJournalEntries(limit: Int = 50) -> [JournalEntry] {
        var descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        save()
    }
    
    // MARK: - Lessons
    
    func getAvailableLesson() -> Int {
        let user = getOrCreateUser()
        guard let commitmentDate = user.commitmentSignedAt else { return 1 }
        
        let daysSinceCommitment = Calendar.current.dateComponents(
            [.day],
            from: commitmentDate,
            to: Date()
        ).day ?? 0
        
        return min(daysSinceCommitment + 1, 30)
    }
    
    func completeLesson(_ lessonNumber: Int) {
        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate { $0.lessonNumber == lessonNumber }
        )
        
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.completedAt = Date()
        } else {
            let progress = LessonProgress(lessonNumber: lessonNumber)
            progress.completedAt = Date()
            modelContext.insert(progress)
        }
        
        let user = getOrCreateUser()
        if lessonNumber >= user.currentLesson {
            user.currentLesson = lessonNumber + 1
        }
        
        save()
    }
    
    func isLessonCompleted(_ lessonNumber: Int) -> Bool {
        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate { $0.lessonNumber == lessonNumber }
        )
        guard let progress = try? modelContext.fetch(descriptor).first else {
            return false
        }
        return progress.isCompleted
    }
    
    // MARK: - Commitment
    
    func signCommitment(date: Date) {
        let user = getOrCreateUser()
        user.commitmentDate = date
        user.commitmentSignedAt = Date()
        save()
        
        // Start first streak
        _ = startNewStreak()
    }
    
    // MARK: - Onboarding
    
    func saveQuizResults(_ results: QuizResults, score: Int) {
        let user = getOrCreateUser()
        user.quizResults = results
        user.recoveryScore = score
        save()
    }
    
    func completeOnboarding() {
        let user = getOrCreateUser()
        user.onboardingCompleted = true
        save()
    }
}
```

---

## StoreKit 2 + Superwall Integration

### StoreKit 2 Setup

```swift
import StoreKit

@Observable
class PurchaseManager {
    static let shared = PurchaseManager()
    
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    
    var isSubscribed: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    private let productIDs = ["imanpath_monthly", "imanpath_yearly"]
    
    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
        
        // Listen for transaction updates
        listenForTransactions()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore: \(error)")
        }
    }
    
    // MARK: - Check Subscription Status
    
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        
        await MainActor.run {
            self.purchasedProductIDs = purchased
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }
    
    // MARK: - Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw PurchaseError.failedVerification
        }
    }
}

enum PurchaseError: Error {
    case failedVerification
}
```

### Superwall Setup

```swift
import SuperwallKit

class SuperwallManager {
    static let shared = SuperwallManager()
    
    private init() {}
    
    func configure() {
        Superwall.configure(apiKey: "your_superwall_api_key")
        
        // Set user attributes for targeting
        Superwall.shared.setUserAttributes([
            "streak_days": 0,
            "is_subscribed": false
        ])
    }
    
    // MARK: - Show Paywall
    
    func showPaywall(
        event: String = "onboarding_complete",
        onSuccess: @escaping () -> Void = {},
        onDismiss: @escaping () -> Void = {}
    ) {
        Superwall.shared.register(event: event) { paywallInfo in
            // Paywall presented
        } onSkip: { skipReason in
            // User already subscribed or paywall skipped
            onDismiss()
        } onDismiss: { paywallInfo, dismissState in
            switch dismissState {
            case .purchased:
                onSuccess()
            case .restored:
                onSuccess()
            case .declined:
                onDismiss()
            }
        }
    }
    
    // MARK: - Update Attributes
    
    func updateStreakDays(_ days: Int) {
        Superwall.shared.setUserAttributes(["streak_days": days])
    }
    
    func updateSubscriptionStatus(_ isSubscribed: Bool) {
        Superwall.shared.setUserAttributes(["is_subscribed": isSubscribed])
    }
}
```

### App Integration

```swift
import SwiftUI
import SuperwallKit

@main
struct ImanPathApp: App {
    
    init() {
        SuperwallManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [User.self, Streak.self, CheckIn.self, JournalEntry.self, LessonProgress.self])
    }
}
```

### Paywall Triggers

```swift
// After onboarding commitment signed
SuperwallManager.shared.showPaywall(event: "commitment_signed") {
    // User subscribed - proceed to home
    navigateToHome()
} onDismiss: {
    // User declined - show limited version or re-prompt later
}

// When accessing premium feature
SuperwallManager.shared.showPaywall(event: "lesson_locked") {
    // Unlock lesson
}

// After relapse (soft upsell)
SuperwallManager.shared.showPaywall(event: "post_relapse") {
    // Subscribed
}
```

### Products in App Store Connect

| Product ID | Type | Price |
|------------|------|-------|
| `imanpath_monthly` | Auto-Renewable Subscription | $9.99/month |
| `imanpath_yearly` | Auto-Renewable Subscription | $59.99/year |

### Superwall Dashboard Setup

1. Create paywalls in Superwall dashboard (drag & drop builder)
2. Map events to paywalls:
   - `commitment_signed` → Main onboarding paywall
   - `lesson_locked` → Feature gate paywall
   - `post_relapse` → Soft upsell paywall
3. A/B test pricing, copy, design without app updates
```

---

## Local Notifications

### Notification Manager

```swift
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }
    
    // MARK: - Daily Check-in Reminder
    
    func scheduleDailyCheckinReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
        content.body = "Time for your daily check-in. How was today?"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_checkin",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelDailyCheckinReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["daily_checkin"])
    }
    
    // MARK: - Streak Milestones
    
    func scheduleStreakMilestone(days: Int, date: Date) {
        let milestones = [1, 3, 7, 14, 30, 50, 60, 75, 90, 120, 150, 270, 365]
        guard milestones.contains(days) else { return }
        
        // Custom copy for major milestones; other days use fallback text.
        let messages: [Int: String] = [
            7: "🎉 7 days! You've completed your first week.",
            14: "💪 Two weeks strong! Your brain is healing.",
            30: "🌟 One month! You've proven you can do this.",
            60: "🚀 Two months! You're not the same person anymore.",
            90: "👑 90 days — full reboot. You are free."
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Milestone Reached!"
        content.body = messages[days] ?? "Keep going!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: date.timeIntervalSinceNow,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "milestone_\(days)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleUpcomingMilestones(currentStreak: Int, streakStartDate: Date) {
        let milestones = [1, 3, 7, 14, 30, 50, 60, 75, 90, 120, 150, 270, 365]
        
        for milestone in milestones where milestone > currentStreak {
            let daysUntil = milestone - currentStreak
            if let milestoneDate = Calendar.current.date(
                byAdding: .day,
                value: daysUntil,
                to: Date()
            ) {
                scheduleStreakMilestone(days: milestone, date: milestoneDate)
            }
        }
    }
    
    func cancelAllMilestoneNotifications() {
        let identifiers = [1, 3, 7, 14, 30, 50, 60, 75, 90, 120, 150, 270, 365].map { "milestone_\($0)" }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
```

---

## Bundled Content

### Lesson Content Structure

```
Resources/
├── Lessons/
│   ├── lessons.json
│   └── verses.json
```

### lessons.json

```json
{
  "lessons": [
    {
      "day": 1,
      "title": "Why You're Here",
      "subtitle": "No shame — this is jihad an-imanpath",
      "content": "Bismillah. If you're reading this, you've already taken the hardest step...",
      "quranReference": {
        "arabic": "وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا",
        "translation": "And those who strive for Us - We will surely guide them to Our ways.",
        "surah": "Al-Ankabut",
        "ayah": "29:69"
      },
      "actionItem": "Write down one reason why you want to quit. Keep it somewhere you'll see it.",
      "reflectionQuestion": "What would your life look like without this struggle?"
    },
    {
      "day": 2,
      "title": "The Brain Science of Addiction",
      "subtitle": "Understanding what's happening in your mind",
      "content": "Pornography hijacks the same neural pathways as drugs..."
    }
  ]
}
```

### verses.json (For Panic Button)

```json
{
  "verses": [
    {
      "arabic": "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
      "translation": "Indeed, Allah is with the patient.",
      "surah": "Al-Baqarah",
      "ayah": "2:153"
    },
    {
      "arabic": "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا",
      "translation": "And whoever fears Allah - He will make for him a way out.",
      "surah": "At-Talaq",
      "ayah": "65:2"
    }
  ]
}
```

### Content Loader

```swift
struct Lesson: Codable, Identifiable {
    var id: Int { day }
    let day: Int
    let title: String
    let subtitle: String
    let content: String
    let quranReference: QuranReference?
    let actionItem: String?
    let reflectionQuestion: String?
}

struct QuranReference: Codable {
    let arabic: String
    let translation: String
    let surah: String
    let ayah: String
}

struct Verse: Codable, Identifiable {
    var id: String { "\(surah):\(ayah)" }
    let arabic: String
    let translation: String
    let surah: String
    let ayah: String
}

class ContentManager {
    static let shared = ContentManager()
    
    private(set) var lessons: [Lesson] = []
    private(set) var verses: [Verse] = []
    
    private init() {
        loadLessons()
        loadVerses()
    }
    
    private func loadLessons() {
        guard let url = Bundle.main.url(forResource: "lessons", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        
        let decoder = JSONDecoder()
        if let container = try? decoder.decode([String: [Lesson]].self, from: data) {
            lessons = container["lessons"] ?? []
        }
    }
    
    private func loadVerses() {
        guard let url = Bundle.main.url(forResource: "verses", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        
        let decoder = JSONDecoder()
        if let container = try? decoder.decode([String: [Verse]].self, from: data) {
            verses = container["verses"] ?? []
        }
    }
    
    func getLesson(_ day: Int) -> Lesson? {
        lessons.first { $0.day == day }
    }
    
    func getRandomVerse() -> Verse? {
        verses.randomElement()
    }
}
```

---

## Analytics (Mixpanel)

### Setup

```swift
import Mixpanel

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {
        Mixpanel.initialize(token: "your_mixpanel_token", trackAutomaticEvents: false)
    }
    
    // MARK: - Onboarding
    
    func trackOnboardingStarted() {
        Mixpanel.mainInstance().track(event: "onboarding_started")
    }
    
    func trackQuizCompleted(recoveryScore: Int) {
        Mixpanel.mainInstance().track(
            event: "onboarding_quiz_completed",
            properties: ["recovery_score": recoveryScore]
        )
    }
    
    func trackCommitmentSigned(daysUntilTarget: Int) {
        Mixpanel.mainInstance().track(
            event: "onboarding_commitment_signed",
            properties: ["days_until_target": daysUntilTarget]
        )
    }
    
    func trackPaywallViewed(offerType: String) {
        Mixpanel.mainInstance().track(
            event: "onboarding_paywall_viewed",
            properties: ["offer_type": offerType]
        )
    }
    
    func trackTrialStarted(plan: String) {
        Mixpanel.mainInstance().track(
            event: "onboarding_trial_started",
            properties: ["plan": plan]
        )
    }
    
    func trackOnboardingCompleted() {
        Mixpanel.mainInstance().track(event: "onboarding_completed")
    }
    
    // MARK: - Core Actions
    
    func trackCheckinCompleted(stayedClean: Bool, urgeLevel: Int?, imanLevel: Int?) {
        var props: [String: MixpanelType] = ["stayed_clean": stayedClean]
        if let urge = urgeLevel { props["urge_level"] = urge }
        if let iman = imanLevel { props["iman_level"] = iman }
        
        Mixpanel.mainInstance().track(event: "checkin_completed", properties: props)
    }
    
    func trackStreakReset(previousStreak: Int) {
        Mixpanel.mainInstance().track(
            event: "streak_reset",
            properties: ["previous_streak": previousStreak]
        )
    }
    
    func trackStreakMilestone(days: Int) {
        Mixpanel.mainInstance().track(
            event: "streak_milestone",
            properties: ["days": days]
        )
    }
    
    func trackPanicButtonPressed() {
        Mixpanel.mainInstance().track(event: "panic_button_pressed")
    }

    func trackPanicButtonBranch(choice: String) {
        // choice: "relapsed" or "tempted"
        Mixpanel.mainInstance().track(
            event: "panic_button_branch",
            properties: ["choice": choice]
        )
    }

    func trackPanicButtonIntervention(intervention: String) {
        // intervention: "breathing", "dhikr", "community"
        Mixpanel.mainInstance().track(
            event: "panic_button_intervention",
            properties: ["intervention": intervention]
        )
    }

    func trackPanicButtonCompleted(branch: String, intervention: String?) {
        var props: [String: MixpanelType] = ["branch": branch]
        if let intervention = intervention {
            props["intervention"] = intervention
        }
        Mixpanel.mainInstance().track(
            event: "panic_button_completed",
            properties: props
        )
    }

    func trackLessonCompleted(lessonNumber: Int) {
        Mixpanel.mainInstance().track(
            event: "lesson_completed",
            properties: ["lesson_number": lessonNumber]
        )
    }
    
    func trackJournalEntryCreated(entryType: String) {
        Mixpanel.mainInstance().track(
            event: "journal_entry_created",
            properties: ["entry_type": entryType]
        )
    }
    
    func trackCommunityLinkTapped() {
        Mixpanel.mainInstance().track(event: "community_link_tapped")
    }

    // MARK: - Errors

    func trackError(_ event: String, context: String? = nil) {
        var props: [String: MixpanelType] = [:]
        if let context = context {
            props["context"] = context
        }
        Mixpanel.mainInstance().track(event: event, properties: props)
    }
}
```

---

## App Lifecycle

### First Launch Detection

```swift
class AppState: ObservableObject {
    @Published var isFirstLaunch: Bool
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isSubscribed: Bool = false
    
    init() {
        isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}
```

### Root View Logic

```swift
struct ContentView: View {
    @StateObject private var appState = AppState()
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if appState.isFirstLaunch || !hasCompletedOnboarding {
                OnboardingFlow()
            } else if !purchaseManager.isSubscribed {
                PaywallView()
            } else {
                MainTabView()
            }
        }
    }
    
    private var hasCompletedOnboarding: Bool {
        let descriptor = FetchDescriptor<User>()
        guard let user = try? modelContext.fetch(descriptor).first else {
            return false
        }
        return user.onboardingCompleted
    }
}
```

---

## Data Migration (Future)

When adding cloud sync in v2, migrate local data:

```swift
class MigrationManager {
    func migrateToCloud(user: User, supabaseClient: SupabaseClient) async throws {
        // Upload local user data to Supabase
        // Mark local data as synced
        // Handle conflicts (server wins for simplicity)
    }
}
```

---

## Folder Structure

```
ImanPath/
├── App/
│   ├── ImanPathApp.swift
│   └── ContentView.swift
├── Models/
│   ├── User.swift
│   ├── Streak.swift
│   ├── CheckIn.swift
│   ├── JournalEntry.swift
│   └── LessonProgress.swift
├── Managers/
│   ├── DataManager.swift
│   ├── PurchaseManager.swift
│   ├── NotificationManager.swift
│   ├── ContentManager.swift
│   └── AnalyticsManager.swift
├── Views/
│   ├── Onboarding/
│   ├── Home/
│   ├── CheckIn/
│   ├── Panic/
│   ├── Lessons/
│   ├── Journal/
│   └── Settings/
├── Components/
│   └── (Reusable UI components)
└── Resources/
    ├── Lessons/
    │   ├── lessons.json
    │   └── verses.json
    └── Assets.xcassets/
```

---

## Cost Estimate (v1)

| Service | Cost |
|---------|------|
| StoreKit 2 | Free (native) |
| Superwall | Free (up to $10K MTR) |
| Mixpanel | Free (up to 20M events) |
| Apple Developer | $99/year |
| **Total** | **$99/year** |

No server costs. Scale to 10K+ users at zero marginal cost.

---

*Local-first = ship fast, scale free, respect privacy.*
