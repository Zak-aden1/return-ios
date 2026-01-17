# ImanPath Notifications System

## Overview

ImanPath uses local push notifications to keep users engaged and support their recovery journey. All notifications are handled by `NotificationManager.swift` - a singleton service that manages scheduling, permissions, and settings persistence.

---

## Notification Types

### 1. Daily Check-in Reminder

**Purpose:** Encourage daily reflection habit

| Property | Value |
|----------|-------|
| Identifier | `daily-checkin-reminder` |
| Trigger | Repeating daily at user-set time |
| Default Time | 9:00 PM |
| Configurable | Yes (time picker in Settings) |

**Sample Messages:**
- "How was your day? Take a moment to reflect."
- "A quick check-in keeps you on track. How are you feeling?"
- "End your day with intention. Complete your check-in."

---

### 2. Lesson Notifications

**Purpose:** Drive lesson engagement with smart, context-aware reminders

#### Day 1 Not Completed (New Users)
| Property | Value |
|----------|-------|
| Identifier | `first-lesson-reminder` |
| Trigger | Repeating daily at 8:00 AM |
| Stops When | User completes Day 1 |

**Sample Messages:**
- "Your first lesson is waiting. Begin your journey today."
- "Day 1 is ready. Take the first step toward freedom."

#### Day 2+ (Completion Chain)
| Property | Value |
|----------|-------|
| Identifier | `daily-lesson-reminder` |
| Trigger | One-time, 24 hours after completing previous lesson |
| Stops When | All 30 lessons completed |

**Sample Messages:**
- "Day X Lesson Ready"
- "Continue building your strength. Day X is ready."

#### After Relapse (Recovery)
| Property | Value |
|----------|-------|
| Identifier | `relapse-recovery-reminder` |
| Trigger | One-time, next morning at lesson time |
| Purpose | Compassionate re-engagement |

**Sample Messages:**
- "Every setback is a setup for a comeback. Your journey continues."
- "Allah's mercy is greater than any fall. Rise again."
- "The one who repents is beloved to Allah. Keep going."

---

### 3. Milestone Alerts

**Purpose:** Celebrate streak achievements

| Property | Value |
|----------|-------|
| Identifier | `milestone-{days}` |
| Trigger | Immediate (1 second delay for UX) |
| Configurable | On/Off toggle in Settings |

**Message Format:**
- Title: "Milestone Reached: {Islamic Name}"
- Body: "{X} days! {Meaning}. Keep going, Allah is with you."

**Example:**
- "Milestone Reached: Sabr"
- "7 days! Patience - Steadfastness through difficulty. Keep going, Allah is with you."

---

## Notification Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     USER JOURNEY                            │
└─────────────────────────────────────────────────────────────┘

New User (Day 1 not done)
    │
    ▼
┌─────────────────────┐
│ Repeating morning   │ ◄── "Start Your Journey"
│ reminder (8 AM)     │
└─────────────────────┘
    │
    │ Completes Day 1
    ▼
┌─────────────────────┐
│ Cancel repeating    │
│ Schedule Day 2      │ ◄── 24h from now
│ notification        │
└─────────────────────┘
    │
    │ Completes Day 2
    ▼
┌─────────────────────┐
│ Schedule Day 3      │ ◄── 24h chain continues
│ notification        │
└─────────────────────┘
    │
    │ ... continues to Day 30
    ▼
┌─────────────────────┐
│ All lessons done    │
│ No more lesson      │
│ notifications       │
└─────────────────────┘


         ┌─────────────────────┐
         │      RELAPSE        │
         └─────────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │ Cancel all lesson   │
         │ notifications       │
         └─────────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │ Schedule recovery   │ ◄── Tomorrow morning
         │ reminder (one-time) │     "A New Beginning"
         └─────────────────────┘
```

---

## Settings UI

Located in `SettingsView.swift` under "NOTIFICATIONS" section:

| Setting | Type | Description |
|---------|------|-------------|
| Check-in Reminder | Toggle + Time Picker | Daily reminder at custom time |
| Lesson Reminder | Toggle | Enables/disables all lesson notifications |
| Milestone Alerts | Toggle | Celebration notifications on/off |

---

## Technical Implementation

### NotificationManager.swift

```swift
// Singleton access
NotificationManager.shared

// Key methods
.requestAuthorization(completion:)     // Request permission
.scheduleCheckInReminder()             // Daily check-in
.scheduleFirstLessonReminder()         // Day 1 repeating
.scheduleNextLessonReminder(day:)      // 24h chain
.sendMilestoneNotification(days:...)   // Immediate milestone
.handleRelapse()                       // Cancel + recovery
```

### Integration Points

| Location | Action |
|----------|--------|
| `SettingsView.swift` | Toggle handlers, permission request |
| `LessonsView.swift` | `scheduleNextLessonReminder()` on completion |
| `DataManager.swift` | `handleRelapse()` in `resetStreak()` |
| `HomeView.swift` | `sendMilestoneNotification()` on milestone |

### Settings Persistence

All notification settings stored in `UserDefaults`:
- `notification_checkin_enabled`
- `notification_checkin_time`
- `notification_lesson_enabled`
- `notification_lesson_time`
- `notification_milestone_enabled`

---

## Edge Cases Handled

| Scenario | Behavior |
|----------|----------|
| User never completes Day 1 | Repeating morning reminders continue |
| User completes all 30 lessons | No more lesson notifications |
| User relapses mid-journey | Cancel pending, send recovery reminder |
| User disables notifications | All scheduled notifications canceled |
| Permission denied | Alert prompts to open Settings app |

---

## Notification Categories

Used for potential future action buttons:
- `CHECKIN` - Check-in reminders
- `LESSON` - Lesson notifications
- `MILESTONE` - Milestone celebrations
- `RECOVERY` - Post-relapse encouragement

---

## Future Enhancements (Not Implemented)

- **Morning Motivation:** Daily Quran verse at start of day
- **Weekly Summary:** End-of-week progress recap
- **Custom notification sounds:** Islamic-themed audio
