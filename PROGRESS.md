# ImanPath - Development Progress

An Islamic app helping users overcome porn addiction through faith-based recovery, accountability, and mindfulness tools.

## Design System

### Color Palette
| Name | Hex | Usage |
|------|-----|-------|
| Primary Green | `#74B886` | Success, streaks, positive actions |
| Gold Accent | `#E8B86D` | Achievements, milestones, "Why" |
| Teal Accent | `#5B9A9A` | Buttons, breathing, grounding |
| Coral Red | `#E85A4F` | Panic, relapse, warnings |
| Soft Blue | `#60A5FA` | Duas, calm actions |
| Background Dark | `#0A1628` | Primary background |
| Card Dark | `#131C2D` | Card backgrounds |
| Border | `#334155` | Subtle borders |

### Typography
- **Headings**: System serif (`.design(.serif)`)
- **Body**: System default
- **Numbers**: Rounded design (`.design(.rounded)`)

### Theme
- Dark theme throughout
- Space-inspired background with stars
- Gradient overlays for depth
- Gold shimmer effects for achievements

---

## Completed Screens & Features

### 1. Home Screen (`HomeView.swift`)
Main dashboard showing user's journey progress.

**Components:**
- `SpaceBackground.swift` - Animated starry background
- `HeaderView.swift` - App logo, notification bell, streak badge
- `StreakSection.swift` - Large day counter with live timer
- `QuickActionsSection.swift` - Quick access buttons (Progress, Breathe, Journal)
- `CommitmentJourneyView.swift` - Visual progress bar to goal
- `DailyCheckInCard.swift` - Prompts daily check-in, shows score badge when complete
- `JournalHomeCard.swift` - Quick journal access
- `DailyVerseCard.swift` - Rotating Quranic verses
- `ChecklistSection.swift` - Onboarding tasks
- `ToolkitSection.swift` - Horizontal scroll of tools
- `YourProgressSection.swift` - Stats summary
- `BottomActionBar.swift` - Panic button + floating actions

### 2. Progress Page (`ProgressPageView.swift`)
Detailed progress analytics and milestones.

**Components:**
- `JourneyRingView.swift` - Circular progress visualization
- `CalendarPreviewCard.swift` - Week strip with activity dots
- `MilestonesSection.swift` - Achievement previews
- `MoodAnalysisSection.swift` - Radar chart of mood data
- `RadarChartView.swift` - Pentagon mood visualization
- `SectionDivider.swift` - Styled dividers

**Navigation:**
- Links to full Calendar view
- Links to full Milestones page

### 3. Calendar View (`CalendarView.swift`)
Full monthly calendar with streak visualization.

**Features:**
- Month navigation (prev/next)
- Streak bands connecting consecutive days
- Star markers on milestone days
- Activity indicators (check-ins, journal entries)
- Legend explaining markers
- Tap day for details (future enhancement)

### 4. Milestones Page (`MilestonesPageView.swift`)
Complete milestone journey with 13 achievements.

**Milestones (Islamic-themed):**
| Day | Name | Islamic Term | Icon |
|-----|------|--------------|------|
| 1 | First Step | Tawbah | Leaf |
| 3 | Reborn | Tajdeed | Sunrise |
| 7 | First Week | Sabr | Shield |
| 14 | Two Weeks | Istiqamah | Arrow Up |
| 30 | One Month | Mujahadah | Flame |
| 50 | Fifty Days | Thiqah | Hand |
| 60 | Two Months | Taqwa | Eye |
| 75 | Seventy-Five | Tawakkul | Sparkle Hands |
| 90 | Three Months | Ihsan | Star |
| 120 | Four Months | Quwwah | Bolt |
| 150 | Five Months | Shukr | Heart |
| 270 | Nine Months | Noor | Sun |
| 365 | One Year | Falah | Crown |

**Features:**
- Hero card showing latest achievement with progress to next
- Milestone cards with badge icons, descriptions, Quranic verses
- Floating dark modal on tap with full details
- Unlock status indicators
- Colored badges per milestone

### 5. Milestone Celebration (`MilestoneCelebrationView.swift`)
Animated celebration overlay when user unlocks a new milestone.

**Two-Phase Flow:**
1. **Unlock Animation** (semi-transparent overlay)
   - Lock icon with milestone colors
   - Shackle opens with spring animation
   - Sparkles burst around lock
   - Confetti particles
   - "Milestone Unlocked!" text
   - Auto-transitions to details after ~1.5s

2. **Details Page** (solid dark background)
   - Personalized "Congratulations {name}!" greeting
   - Badge with animated glow rings
   - "X DAYS FREE" pill with milestone gradient
   - Islamic name in gold serif font
   - English title and meaning
   - "Alhamdulillah!" dismiss button

**Features:**
- Triggered automatically when reaching new milestone day
- Persists celebration state via `@AppStorage` (won't show same milestone twice)
- Haptic feedback throughout (success, heavy impact, light)
- Spring and ease animations
- Confetti particle system with burst + continuous modes

**Data Model:**
```swift
struct CelebrationMilestone {
    let day: Int
    let title: String
    let islamicName: String
    let meaning: String
    let verse: String?
    let verseReference: String?
    let badgeIcon: String
    let badgeColors: [Color]
}
```

### 6. Panic Button (`PanicView.swift`)
Crisis intervention screen with front camera.

**Features:**
- Full-screen camera preview (front-facing mirror)
- Typewriter effect cycling motivational messages
- "Remember Your Why" section with user's saved reasons
- Haptic feedback on typing
- Two action paths: "I Relapsed" / "I'm Tempted"

**Components:**
- `CameraPreviewView` - Live camera feed
- `CameraManager` - AVFoundation camera handling
- `RememberYourWhySection` - Displays why cards
- `PanicWhyCard` - Compact why card display

### 7. Tempted Flow (`TemptedFlowView.swift`)
Multi-step intervention when user feels tempted.

**Steps:**
1. Acknowledgment - "It's okay to feel this way"
2. Coping Tools - Breathing, Duas, Grounding options
3. Encouragement - Motivational message + Quranic verse
4. Resolution - Success confirmation

**Features:**
- Progress indicator
- Animated transitions
- Links to coping tools (Breathing, Duas, Grounding)
- Completion callback

### 8. Relapsed Flow (`RelapsedFlowView.swift`)
Compassionate flow for when user relapses.

**Steps:**
1. Acknowledgment - Non-judgmental support
2. Reflection - Optional journaling prompt
3. Renewal - Hadith about repentance
4. New Beginning - Reset and continue

**Features:**
- Streak reset handling
- Optional reflection entry
- Islamic perspective on forgiveness
- Restart commitment

### 9. Check-In Flow (`CheckInFlowView.swift`)
Daily mood and status check-in with 5-step questionnaire.

**Ratings (1-10 scale):**
1. Mood - How are you feeling today?
2. Energy - Physical/mental energy level
3. Confidence - Confidence in staying clean
4. Faith - Connection to Allah
5. Self-Control - Ability to resist urges

**Additional Fields:**
- Progress reflection (optional text)
- Journey reflection (optional text)
- Gratitude (optional text)
- Stayed clean today (Yes/No)

**Features:**
- Animated circular rating selector
- Prefills if already checked in today (allows editing)
- Updates existing check-in instead of creating duplicates
- Only increments streak on first check-in of day
- Data persisted via SwiftData for mood analytics

### 10. Journal (`JournalView.swift`)
Personal reflection journal.

**Features:**
- Entry list with previews
- Category filtering (Reflection, Gratitude, Struggle, Victory, Dua)
- Search functionality
- Floating compose button

**Related Views:**
- `JournalComposerView.swift` - Write new entries or edit existing
- `JournalEntryDetailView.swift` - Read, edit, or delete entries

**Entry Management:**
- Create new entries with optional mood (1-10)
- Edit existing entries (prefills content and mood)
- Delete entries with confirmation alert
- All operations persist via SwiftData

**Entry Categories:**
- Reflection (purple)
- Gratitude (green)
- Struggle (coral)
- Victory (gold)
- Dua (blue)

### 11. My Why (`MyWhyView.swift`)
User's personal reasons for recovery.

**Features:**
- Multiple "Why" entries
- Categories: Faith, Family, Marriage, Self, Career, Health
- Add/Edit/Delete entries
- Displayed in Panic view for motivation

**Related Views:**
- `MyWhyEditorView.swift` - Add/edit why entries

**Categories:**
| Category | Icon | Color |
|----------|------|-------|
| Faith | hands.sparkles | Blue |
| Family | figure.2.and.child | Green |
| Marriage | heart.fill | Pink |
| Self | person.fill | Purple |
| Career | briefcase.fill | Orange |
| Health | heart.text.square | Teal |

### 12. Breathing Exercise (`BreathingExerciseView.swift`)
Guided 4-7-8 breathing technique.

**Features:**
- 5-cycle breathing exercise
- Animated expanding/contracting circle
- Phase indicators (Breathe In, Hold, Breathe Out)
- Cycle counter
- Rotating Quranic verses
- Completion celebration

### 13. Duas View (`DuasView.swift`)
Emergency prayers for strength.

**Features:**
- Intro screen explaining benefits of dua
- Swipeable prayer cards
- Arabic text + transliteration + translation
- Source references
- 8 curated duas for protection, strength, forgiveness, patience

**Dua Categories:**
- Protection
- Strength
- Forgiveness
- Patience

### 14. Grounding Exercise (`GroundingView.swift`)
5-4-3-2-1 sensory grounding technique.

**Steps:**
1. Intro - Explanation of technique
2. SEE - 5 things you can see (blue)
3. TOUCH - 4 things you can feel (green)
4. HEAR - 3 things you can hear (gold)
5. SMELL - 2 things you can smell (purple)
6. TASTE - 1 thing you can taste (coral)
7. Completion - Success with Quranic verse

**Features:**
- Step-by-step guided flow
- Animated pulsing circles
- Color-coded steps
- Tips for each sense
- Progress bar

### 15. Toolkit Section (`ToolkitSection.swift`)
Horizontal scrolling tool cards on home screen.

**Implemented Tools:**
- My Why (gold) - Links to MyWhyView
- Journal (green) - Links to JournalView
- Duas (blue) - Links to DuasView
- Breathing (green) - Links to BreathingExerciseView
- Grounding (teal) - Links to GroundingView

**Placeholder Tools:**
- Blocker (orange) - Not yet implemented
- Accountability (purple) - Not yet implemented

### 16. Streak Coach (`StreakCoachView.swift`)
AI-powered companion that provides personalized guidance based on user's data.

**Features:**
- Chat interface with AI coach
- Grounded in user's actual data (journals, check-ins, why entries)
- Citation chips linking back to original entries
- Suggested actions (breathing, journal, check-in, etc.)
- 100 messages/day rate limiting
- Error handling with retry button

**Components:**
- `CoachBubble.swift` - Message bubble with citation chips
- `CoachInputBar.swift` - Text input with send button
- `CoachWelcome.swift` - Empty state with suggestions
- `ActionChips.swift` - Quick action buttons after AI response
- `TypingIndicator.swift` - Loading animation

**Services:**
- `AnthropicService.swift` - API client via Supabase Edge Function
- `StreakCoachDataPacker.swift` - Builds context with citation IDs
- `CoachRateLimiter.swift` - Local rate limiting (100/day)

**Data Models:**
- `ChatMessage.swift` - Message with citations array
- `ChatConversation.swift` - Conversation container

**Backend:**
- Supabase Edge Function (`supabase/functions/coach/index.ts`)
- API key stored securely in Supabase secrets
- System prompt with streak-aware tone adjustment

### 17. Profile Page (`ProfileView.swift`)
User profile with journey stats and milestone badges.

**Features:**
- Avatar with user's initials
- Journey start date
- Horizontally scrolling milestone badges (locked/unlocked)
- Stats card: current streak, longest streak, total clean days
- My Why link card
- Journey info card (check-ins, journal entries, commitment date)
- Settings gear icon in toolbar

### 18. Settings Page (`SettingsView.swift`)
App settings and preferences.

**Sections:**
- Notifications toggle
- AI Coach toggle
- Clear Chat History (with confirmation)
- Export My Data (placeholder)
- Delete All Data (with confirmation)
- About: Version, Privacy Policy, Terms, Feedback

### 19. Paywall Screen (`PaywallScreen.swift`)
Subscription paywall shown before accessing the app.

**Design:**
- Light pink/cream gradient background (Fajr Dawn palette)
- Mountain silhouettes at bottom
- Sunrise glow effect

**Components:**
- Return logo at top
- Headline: "Start Your Journey to Freedom"
- Subtitle with social proof
- iPhone mockup carousel showing app screenshots (4 screens)
- 3 pricing cards: Weekly, Yearly (highlighted with "Save 80%"), Monthly
- Per-day pricing psychology ($0.14/day vs $49.99/year)
- CTA button: "Start Free Trial"
- Trust signals: "Cancel anytime. No commitment."
- Footer: Restore Purchases • Terms of Use • Privacy Policy

**Technical:**
- StoreKit 2 integration via `SubscriptionManager`
- Auto-advancing screenshot carousel (3.5s interval)
- Timer properly invalidated on view disappear (prevents crashes)
- Staggered fade-in animations on load

**Pricing Tiers:**
| Plan | Daily | Total | Badge |
|------|-------|-------|-------|
| Weekly | $0.71/day | $4.99/week | - |
| Yearly | $0.14/day | $49.99/year | Save 80% |
| Monthly | $0.33/day | $9.99/month | - |

### 20. Tutorial Screen (`TutorialView.swift`)
Post-onboarding tutorial carousel introducing app features.

**Design:**
- Dark space background with star field
- Realistic iPhone mockup with screenshots
- Circular glow behind phone
- 5-step carousel with pagination dots

**Steps:**
1. Welcome - "Here's how your journey begins"
2. Progress - "Watch your streak grow"
3. Daily Practice - "5 minutes a day"
4. Support - "Your AI Coach and tools"
5. Commitment - "Honor your Niyyah"

**Components:**
- `PhoneFrameView` - Realistic iPhone with bezels, dynamic island
- `iPhoneDevice` - Phone frame with 3D tilt effect
- `ScreenshotContent` - Loads actual screenshots or placeholders
- `StarFieldView` - Animated star background

---

## Data Models

### WhyEntry
```swift
struct WhyEntry: Identifiable {
    let id: UUID
    let category: WhyCategory
    let content: String
    let createdAt: Date
}
```

### JournalEntry
```swift
struct JournalEntry: Identifiable {
    let id: UUID
    let title: String
    let content: String
    let category: JournalCategory
    let date: Date
}
```

### MilestoneData
```swift
struct MilestoneData: Identifiable {
    let id: UUID
    let day: Int
    let title: String
    let islamicName: String
    let meaning: String
    let verse: String?
    let verseReference: String?
    let badgeIcon: String
    let badgeColors: [Color]
    var isCompleted: Bool
}
```

### Dua
```swift
struct Dua: Identifiable {
    let id: UUID
    let arabic: String
    let transliteration: String
    let translation: String
    let source: String
    let category: DuaCategory
}
```

### ChatMessage
```swift
@Model
final class ChatMessage {
    var id: UUID
    var sender: MessageSender  // .user or .assistant
    var content: String
    var timestamp: Date
    var conversation: ChatConversation?
    var citationsData: String  // JSON-encoded [String]
    var suggestedAction: String?
    var isError: Bool
    var errorMessage: String?
}
```

### ChatConversation
```swift
@Model
final class ChatConversation {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade)
    var messages: [ChatMessage]
}
```

---

## Navigation Flow

```
HomeView
├── MilestoneCelebrationView (overlay, auto-triggered on new milestone)
│   ├── Phase 1: UnlockAnimationView (semi-transparent)
│   └── Phase 2: MilestoneDetailsView (solid background)
├── ProgressPageView
│   ├── CalendarView
│   └── MilestonesPageView (with detail modal)
├── PanicView (full screen)
│   ├── TemptedFlowView
│   │   ├── BreathingExerciseView
│   │   ├── DuasView
│   │   └── GroundingView
│   └── RelapsedFlowView
├── CheckInFlowView (full screen)
├── StreakCoachView (full screen)
│   ├── JournalEntryDetailView (sheet, via citation tap)
│   └── MyWhyView (sheet, via citation tap)
├── ProfileView (full screen, via header avatar)
│   └── SettingsView (sheet)
├── JournalView
│   ├── JournalComposerView
│   └── JournalEntryDetailView
├── MyWhyView
│   └── MyWhyEditorView
└── Toolkit
    ├── BreathingExerciseView (full screen)
    ├── DuasView (full screen)
    └── GroundingView (full screen)
```

---

## TODO / Not Yet Implemented

### High Priority
1. ~~**Data Persistence**~~ ✅ COMPLETE - See "SwiftData Integration" section below

2. **Onboarding Flow** - First-time user experience:
   - Welcome screens
   - Collect user's name (for personalized greetings like "Congratulations Zak!")
   - Set commitment date
   - Add first "Why"
   - App feature tour

3. ~~**Settings Page**~~ ✅ COMPLETE - See "Settings Page" section above

4. ~~**AI Coach**~~ ✅ COMPLETE - See "Streak Coach" section above

### Medium Priority
5. **Community Feature** - Social support (in progress):
   - Auth (Apple + Google Sign In via Supabase)
   - Post feed with tags
   - Likes and comments
   - User blocking and reporting
   - Admin moderation tools

6. **Blocker Settings** - Content blocking:
   - Website blocklist management
   - Screen Time API integration
   - Block schedules

7. **Notifications** - Push notifications:
   - Daily check-in reminders
   - Milestone celebrations
   - Custom reminder times

### Low Priority
8. **Tempted Flow Enhancement** - Add Grounding/Duas buttons
9. **Widget** - Home screen streak widget
10. **Apple Watch** - Companion app
11. **Analytics Dashboard** - Trends and insights

---

## File Structure

```
ImanPath/
├── ImanPathApp.swift
├── ContentView.swift
├── AppTheme.swift
├── HomeView.swift
├── ProgressPageView.swift
├── CalendarView.swift
├── MilestonesPageView.swift
├── MilestoneCelebrationView.swift
├── PanicView.swift
├── TemptedFlowView.swift
├── RelapsedFlowView.swift
├── CheckInFlowView.swift
├── JournalView.swift
├── JournalComposerView.swift
├── JournalEntryDetailView.swift
├── MyWhyView.swift
├── MyWhyEditorView.swift
├── BreathingExerciseView.swift
├── DuasView.swift
├── GroundingView.swift
├── DhikrCounterView.swift
├── RenewPromiseView.swift
├── StreakCoachView.swift
├── ProfileView.swift
├── SettingsView.swift
├── Models/
│   ├── User.swift
│   ├── Streak.swift
│   ├── CheckIn.swift
│   ├── JournalEntry.swift
│   ├── WhyEntry.swift
│   ├── ChatMessage.swift
│   └── ChatConversation.swift
├── Managers/
│   └── DataManager.swift
├── Services/
│   ├── AnthropicService.swift
│   ├── StreakCoachDataPacker.swift
│   └── CoachRateLimiter.swift
├── Components/
│   ├── Home/
│   │   ├── SpaceBackground.swift
│   │   ├── HeaderView.swift
│   │   ├── StreakSection.swift
│   │   ├── QuickActionsSection.swift
│   │   ├── CommitmentJourneyView.swift
│   │   ├── DailyCheckInCard.swift
│   │   ├── DailyVerseCard.swift
│   │   ├── ChecklistSection.swift
│   │   ├── ToolkitSection.swift
│   │   ├── YourProgressSection.swift
│   │   └── BottomActionBar.swift
│   ├── Progress/
│   │   ├── SectionDivider.swift
│   │   ├── JourneyRingView.swift
│   │   ├── CalendarPreviewCard.swift
│   │   ├── MilestonesSection.swift
│   │   ├── MoodAnalysisSection.swift
│   │   └── RadarChartView.swift
│   └── Chat/
│       ├── CoachBubble.swift
│       ├── CoachInputBar.swift
│       ├── CoachWelcome.swift
│       ├── ActionChips.swift
│       └── TypingIndicator.swift
├── Extensions/
│   └── Color+Hex.swift
└── supabase/
    └── functions/
        └── coach/
            └── index.ts
```

---

## SwiftData Integration ✅

Full data persistence implemented using SwiftData.

### Data Models (`Models/`)

| Model | File | Purpose |
|-------|------|---------|
| `User` | `User.swift` | User profile, commitment, streak cache, milestone tracking |
| `Streak` | `Streak.swift` | Individual streak records with start/end dates |
| `CheckIn` | `CheckIn.swift` | Daily check-ins with 5 mood ratings + reflections |
| `JournalEntry` | `JournalEntry.swift` | Journal entries with content, mood, date |
| `WhyEntry` | `WhyEntry.swift` | User's "Why" motivations with categories |

### DataManager (`Managers/DataManager.swift`)

Centralized manager for all SwiftData operations:

**User Operations:**
- `getOrCreateUser()` - Get or create singleton user
- `updateUserName()` - Update display name
- `signCommitment()` - Sign commitment and start first streak
- `completeOnboarding()` - Mark onboarding complete

**Streak Operations:**
- `getCurrentStreak()` - Get active streak
- `ensureStreakIfCommitted()` - Ensure streak exists if committed
- `startNewStreak()` - Create new streak
- `resetStreak(reason:)` - End current streak and start new one
- `calculateCurrentStreakDays()` - Calculate days from streak start

**Check-In Operations:**
- `getTodaysCheckin()` - Get today's check-in if exists
- `hasCheckedInToday()` - Boolean check
- `submitCheckin(...)` - Create or update today's check-in
- `getCheckinHistory(limit:)` - Get recent check-ins
- `getCheckinsThisWeek()` - Count for stats

**Journal Operations:**
- `createJournalEntry()` - Create new entry
- `getJournalEntries(limit:)` - Get recent entries
- `updateJournalEntry()` - Edit existing entry
- `deleteJournalEntry()` - Remove entry
- `searchJournalEntries(query:)` - Search by content

**Why Operations:**
- `createWhyEntry()` - Add new why
- `getWhyEntries()` - Get all whys
- `updateWhyEntry()` - Edit why
- `deleteWhyEntry()` - Remove why

**Milestone Operations:**
- `celebrateMilestone(day:)` - Mark milestone as celebrated
- `hasNewMilestone(milestones:)` - Check for uncelebrated milestones

**Stats:**
- `getHomeStats()` - Aggregated stats for home view

### Day Counting Logic

- **Day 0** = Commitment day (signing commitment)
- **Day 1** = After 24 hours (first milestone)
- Milestones: `[1, 7, 14, 21, 30, 40, 60, 90, 120, 150, 270, 365]`

### Views Wired with Real Data

| View | Data Source | Features |
|------|-------------|----------|
| `HomeView` | `DataManager.getHomeStats()` | Live timer from streak start, today's check-in score |
| `ProgressPageView` | `@Query` for check-ins | Real mood averages in radar chart |
| `CalendarView` | `@Query` for check-ins/entries | Streak bands, activity markers |
| `CalendarPreviewCard` | Props from parent | Milestone lock icons on future days |
| `DailyCheckInCard` | Props from HomeView | Score badge, completion state |
| `CheckInFlowView` | `DataManager` | Prefills existing check-in for editing |
| `JournalView` | `@Query` for entries | Real entry list |
| `JournalComposerView` | `DataManager` | Create new or edit existing entries |
| `JournalEntryDetailView` | `DataManager` | Delete entries, edit via composer |
| `MyWhyView` | `@Query` for whys | Real why entries |
| `PanicView` | `@Query` for whys | Shows user's whys during crisis |

### Check-In Flow

1. User opens check-in → if exists today, prefills all fields
2. User submits → creates new or updates existing (no duplicates)
3. Streak only incremented on first check-in of day
4. Relapse in check-in triggers streak reset

---

## Website (returntoiman.com)

Separate static website for legal pages and landing page.

**Location:** `/Users/zak/Code/real-projects/return-website/`

**Hosted on:** Vercel (auto-deployed)

**Domain:** `returntoiman.com` (DNS via Namecheap)

### Pages

| Page | URL | Purpose |
|------|-----|---------|
| Landing | `returntoiman.com` | Coming soon page with logo, app screenshot |
| Privacy Policy | `returntoiman.com/privacy` | Required for App Store |
| Terms of Service | `returntoiman.com/terms` | Required for App Store |

### Design

- Dark theme matching app (`#0A1628` background)
- Cormorant Garamond + Source Serif 4 typography
- Animated twinkling stars
- iPhone mockup with home screen screenshot
- Subtle Islamic geometric pattern overlay
- Staggered fade-up animations on load

### Files

```
return-website/
├── assets/
│   ├── ReturnLogo.png        # App logo
│   └── home-screenshot.png   # Full iPhone screenshot
├── index.html                # Landing page
├── privacy.html              # Privacy policy
├── terms.html                # Terms of service
└── vercel.json               # URL routing (/privacy → privacy.html)
```

### App Integration

Links in app point to website:
- `PaywallScreen.swift` - Footer links
- `SettingsView.swift` - Settings menu links

---

## Technical Notes

### Camera Implementation
- Uses AVFoundation for front camera preview
- Handles permission requests gracefully
- Falls back to placeholder when denied
- Runs camera on background thread

### Animations
- Spring animations for modals
- Typewriter effect with haptic feedback
- Pulsing circles for breathing/grounding
- Shimmer effects on achievement cards
- Confetti particle system (burst + continuous modes)
- Lock unlock animation with shackle rotation
- Glow ring pulsing for milestone badges

### Design Patterns
- `@State` for local view state
- `@Binding` for parent-child communication
- `@Environment(\.dismiss)` for navigation
- `@Environment(\.modelContext)` for SwiftData access
- `@Query` for reactive data fetching
- `DataManager` for centralized data operations
- Callback closures for flow completion

---

*Last updated: January 18, 2026*
