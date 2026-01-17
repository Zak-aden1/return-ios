# ImanPath Milestone System

## Overview

Milestones celebrate streak achievements with Islamic-themed names and meanings. They appear in the Journey Calendar, Weekly Calendar, Progress Page, and trigger celebration modals.

---

## Single Source of Truth

All milestone data lives in `MilestoneCatalog.swift`:

```swift
// ImanPath/Models/MilestoneCatalog.swift
enum MilestoneCatalog {
    static let definitions: [MilestoneDefinition]  // Full milestone data
    static var days: [Int]                          // Just the day numbers
    static func definition(for day: Int)            // Get by day
    static func next(after day: Int)                // Get next milestone
}
```

**Never hardcode milestone lists elsewhere.** Always reference `MilestoneCatalog`.

---

## Milestone Days

| Day | Islamic Name | English Title | Meaning |
|-----|--------------|---------------|---------|
| 1 | Tawbah | First Step | Repentance |
| 3 | Tajdeed | Reborn | Renewal |
| 7 | Sabr | First Week | Patience |
| 14 | Istiqamah | Two Weeks | Steadfastness |
| 30 | Mujahadah | One Month | Striving |
| 50 | Thiqah | Fifty Days | Confidence |
| 60 | Taqwa | Two Months | God-consciousness |
| 75 | Tawakkul | Seventy-Five Days | Reliance on Allah |
| 90 | Ihsan | Three Months | Excellence |
| 120 | Quwwah | Four Months | Strength |
| 150 | Shukr | Five Months | Gratitude |
| 270 | Noor | Nine Months | Light |
| 365 | Falah | One Year | Success |

---

## Day Indexing (Day 0 Semantics)

**Critical:** The app uses "Day 0 = start day" semantics.

| Days Elapsed | Streak Day | Milestone? |
|--------------|------------|------------|
| 0 | Day 0 | No |
| 1 | Day 1 | Yes (Tawbah) |
| 3 | Day 3 | Yes (Tajdeed) |
| 7 | Day 7 | Yes (Sabr) |

**How it works:**
- `calculateCurrentStreakDays()` returns days elapsed since streak start
- User starts journey → `currentStreak = 0` → Day 0 (no milestone)
- After 24 hours → `currentStreak = 1` → Day 1 (Tawbah milestone)
- After 3 days → `currentStreak = 3` → Day 3 (Tajdeed milestone)

**Key rule:** `MilestoneCatalog.days.contains(currentStreak)` — no +1 adjustment needed.

---

## Milestone Display Logic

### Past/Today Milestones (Achieved)
- Calculated from `streakStartDate` and date position
- Shows gold star indicator + celebration icon
- Independent of check-in existence

### Future Milestones (Locked)
- Calculated from `currentStreak + daysUntil`
- Shows gold circle with lock icon
- **Requires `streakStartDate != nil`** (no commitment = no locks)

---

## Where Milestones Appear

| Location | Source | Notes |
|----------|--------|-------|
| Journey Calendar (`CalendarView`) | `MilestoneCatalog.definition(for:)` | Shows star + icon for achieved |
| Weekly Calendar (`WeekStripView`) | `MilestoneCatalog.days` | Shows star for achieved, lock for future |
| Progress Page (`MilestonesSection`) | `MilestoneCatalog.definitions` | Latest + upcoming cards |
| Home View celebration | `MilestoneCatalog.definitions` | Triggers modal on new milestone |
| Streak Coach | `MilestoneCatalog.next(after:)` | "X days until next milestone" |
| Commitment Journey | `MilestoneCatalog.commitmentDays` | Goal markers (30, 60, 90) |

---

## Subsets

```swift
MilestoneCatalog.majorDays       // [7, 30, 60, 90] - Key progress markers
MilestoneCatalog.commitmentDays  // [30, 60, 90] - Commitment goal options
```

---

## Adding a New Milestone

1. Add `MilestoneDefinition` to `MilestoneCatalog.definitions` array
2. Include: day, title, islamicName, meaning, verse (optional), icon, colors
3. Update `majorDays` or `commitmentDays` if applicable
4. That's it — all consumers auto-update

---

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| No commitment signed | No milestone indicators anywhere |
| Day 0 (start day) | No milestone (Day 1 is first) |
| Relapse mid-streak | Streak resets, milestones recalculate |
| Day without check-in | Milestone still shows if it's a milestone day |

---

## Technical Notes

- Milestones are **streak-based**, not check-in-based
- DayDetailsCard shows milestone banner even without check-in data
- Future milestone calculation requires `streakStartDate` guard to prevent showing locks with no commitment
