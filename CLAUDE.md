# ImanPath - Project Context for Claude

## Overview

**ImanPath** is an iOS app helping Muslims quit pornography addiction through Islamic guidance and science-backed recovery methods.

- **Platform:** iOS (Swift/SwiftUI, iOS 17+)
- **Model:** Subscription (monthly/yearly) with 3-day free trial
- **Tagline:** "Quit Porn with Iman"

## Project Structure

```
ImanPath/
├── App/
│   ├── ImanPathApp.swift          # App entry point
│   └── ContentView.swift          # Root view controller
├── Models/
│   ├── User.swift                 # User profile + settings
│   ├── Streak.swift               # Streak tracking
│   ├── CheckIn.swift              # Daily check-ins
│   ├── JournalEntry.swift         # Journal entries
│   ├── ChatMessage.swift          # AI Coach messages
│   ├── ChatConversation.swift     # AI Coach conversations
│   ├── LessonProgress.swift       # Lesson completion tracking
│   └── MilestoneCatalog.swift     # Milestone definitions (single source of truth)
├── Onboarding/
│   ├── OnboardingFlowView.swift   # Main onboarding coordinator (31 steps)
│   └── Screens/                   # Individual onboarding screens
│       ├── WelcomeScreen.swift
│       ├── WhyHereScreen.swift
│       ├── QuizQuestionScreen.swift
│       ├── NameInputScreen.swift
│       ├── CalculatingScreen.swift
│       ├── DependenceAnalysisScreen.swift
│       ├── SymptomsScreen.swift
│       ├── EducationCarouselView.swift
│       ├── SolutionsCarouselView.swift
│       ├── GoalsIntroScreen.swift
│       ├── GoalsSelectionScreen.swift
│       ├── CommitmentIntroScreen.swift
│       ├── PledgeFlowScreen.swift
│       ├── CommitmentCardScreen.swift
│       ├── CommitmentCongratulationsScreen.swift
│       ├── RatingRequestScreen.swift
│       ├── TypewriterScreen.swift
│       ├── PrePaywallScreen.swift
│       └── PaywallScreen.swift
├── Views/
│   ├── Home/                      # Home screen + streak display
│   ├── CheckIn/                   # Daily check-in flow
│   ├── Panic/                     # Panic button flow
│   ├── Lessons/                   # 30-day lesson program
│   ├── Journal/                   # Journal entries
│   ├── Coach/                     # AI Coach chat
│   └── Settings/                  # User settings
├── Components/                    # Reusable UI components
├── Managers/
│   ├── DataManager.swift          # SwiftData operations
│   ├── PurchaseManager.swift      # StoreKit 2 subscriptions
│   ├── NotificationManager.swift  # Local notifications
│   └── AnalyticsManager.swift     # Mixpanel tracking
└── Resources/
    ├── Lessons/                   # Bundled lesson content (JSON)
    └── Assets.xcassets/           # Images and colors
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| UI Framework | SwiftUI |
| Data Persistence | SwiftData (local-first) |
| Subscriptions | StoreKit 2 |
| AI Coach | Claude Sonnet via Supabase Edge Function |
| Analytics | Mixpanel |
| Notifications | Local (UNUserNotificationCenter) |

## Onboarding Flow (31 Steps)

The onboarding is the primary conversion driver. Flow:

1. **Welcome** - Assalamu Alaikum intro
2. **Why Here** - Multi-select reasons (6 options)
3-15. **Quiz** - 13 emotional/behavioral questions (with conditional logic)
16. **Name Input** - Collect first name
17. **Calculating** - Animated analysis screen
18. **Dependence Analysis** - Personalized score display
19. **Symptoms** - Multi-select symptoms
20. **Education Carousel** - 4 pain + 1 hope slides
21. **Solutions Carousel** - 6 benefit slides
22. **Goals Intro** - "What does freedom look like?"
23. **Goals Selection** - Multi-select goals (8 options)
24. **Commitment Intro** - Personalized anticipation
25. **Pledge Flow** - 3 pledges with hold-to-commit
26. **Commitment Card** - Niyyah with 90-day goal date
27. **Congratulations** - MashaAllah celebration
28. **Rating Request** - StoreKit review prompt
29. **Typewriter** - Auto-typing personalized messages
30. **Pre-Paywall Benefits** - Long scrollable value sell
31. **Paywall** - Subscription options

## Design System

### Color Palettes

**Dark Theme (Main App):**
- Background: `#0A1628` (deep navy)
- Accent: `#C4956A` (warm amber)
- Text: White/off-white

**Fajr Dawn (Onboarding Pledge/Commitment):**
- bgTop: `#FDF8F5` (warm ivory)
- bgUpperMid: `#F7EDE8` (soft blush)
- bgLowerMid: `#EBE0E8` (dusty rose)
- bgBottom: `#DED0E0` (soft mauve)
- accentViolet: `#7B5E99`
- sunriseGlow: `#F6C177`
- textHeading: `#2D2438`
- textBody: `#5A4A66`

### Typography
- Display: System serif for headings
- Body: System sans-serif
- Arabic: System Arabic for Quranic text

## Key Components

### MountainShape
Reusable Shape for layered mountain backgrounds. Used in pledge, commitment, paywall screens.

### FlowLayout
Custom Layout for wrapping chips/tags in a grid. Used in benefit chips, goal selection.

### OnboardingBottomButton
Standard CTA button for onboarding screens.

### OnboardingTopBar
Progress bar + back button for onboarding.

## Important Patterns

### Milestone System
All milestones defined in `MilestoneCatalog.swift`. Days: 1, 3, 7, 14, 30, 50, 60, 75, 90, 120, 150, 270, 365. Each has Islamic name (e.g., "Sabr" for 7 days).

### Day 0 Semantics
Streak starts at Day 0. After 24 hours → Day 1. Milestones trigger on actual day numbers.

### Haptic Feedback
Use `UIImpactFeedbackGenerator` for button taps. CoreHaptics for sustained effects (typewriter, hold-to-commit).

## Documentation

- `docs/PRD.md` - Product requirements
- `docs/USER_FLOW.md` - Detailed user flows with ASCII diagrams
- `docs/DATA.md` - Data architecture and SwiftData models
- `docs/MILESTONES.md` - Milestone system documentation
- `docs/NOTIFICATIONS.md` - Notification strategy
- `docs/LESSONS-content.md` - 30-day lesson content

## Common Tasks

### Adding a new onboarding screen
1. Create screen in `Onboarding/Screens/`
2. Add case in `OnboardingFlowView.swift` switch
3. Update `totalSteps` if needed
4. Update docs (USER_FLOW.md, PRD.md)

### Adding a milestone
1. Add to `MilestoneCatalog.definitions` array
2. All consumers auto-update

### Naming conflicts
Private structs in screen files should be prefixed (e.g., `PrePaywallBenefitRow`) to avoid conflicts with similarly named components in other files.
