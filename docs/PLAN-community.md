# Community Feature - Implementation Plan

## Overview

A community feed where users can share encouragement, ask for dua requests, and support each other on their recovery journey. Built on Supabase with Apple/Google authentication.

---

## User Experience

### Post Card Design
```
┌─────────────────────────────────────────┐
│ Ahmad • Day 14 • 2h ago             ··· │
│ 🏷️ Victories                            │
│                                         │
│ "Finally made it to two weeks.          │
│  Fajr prayer is keeping me grounded."   │
│                                         │
│ ❤️ 12    💬 4                            │
└─────────────────────────────────────────┘
```

### Feed Structure
- Main feed showing all posts (newest first)
- Filter chips at top for tags
- Pull to refresh
- Floating compose button

### Compose Post
- Text input
- Optional tag selector (sheet with tag chips)
- Post button

---

## Features

### Authentication
- Sign in with Apple (required for App Store)
- Sign in with Google
- Supabase Auth handles both
- Auth required to access community

### User Profile
- Name (editable in Settings)
- Streak day (pulled from local SwiftData)
- No separate profile page for community (keep it simple)

### Posts
- Text content (max 500 chars?)
- Optional tag (one per post)
- Timestamp
- Author name + streak day
- Like count
- Comment count

### Tags (Optional per post)
| Tag | Description |
|-----|-------------|
| Struggles | When you're going through it |
| Victories | Milestones and wins |
| Dua Requests | Ask for prayers |
| Tips & Advice | What's working for you |
| Night Struggles | Late night is common trigger |
| Accountability | Check-ins and support |
| Quran & Reflection | Verses that help |
| General | Everything else |

### Interactions
- ❤️ Like posts
- 💬 Comment on posts
- View comments in post detail

### User Moderation (Self-service)
- Delete own posts
- Delete own comments
- Block users (mutual invisibility)

### Safety
- Report button on posts and comments
- Auto-hide after 3 reports (until admin review)
- Word filter on submit (block explicit terms)

### Admin Controls
- View reported content
- Delete any post/comment
- Ban user globally

---

## Technical Architecture

### Supabase Tables

```sql
-- User profiles (synced from auth)
profiles (
  id UUID PRIMARY KEY REFERENCES auth.users,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  is_banned BOOLEAN DEFAULT FALSE
)

-- Posts
posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  tag TEXT,  -- nullable, one of the predefined tags
  streak_day INT,  -- snapshot at time of posting
  created_at TIMESTAMPTZ DEFAULT NOW(),
  is_hidden BOOLEAN DEFAULT FALSE,  -- hidden by reports
  report_count INT DEFAULT 0
)

-- Comments
comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  is_hidden BOOLEAN DEFAULT FALSE,
  report_count INT DEFAULT 0
)

-- Likes (one per user per post)
likes (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (post_id, user_id)
)

-- Blocks (user-to-user)
blocks (
  blocker_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (blocker_id, blocked_id)
)

-- Reports
reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL,  -- 'post' or 'comment'
  content_id UUID NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed BOOLEAN DEFAULT FALSE
)
```

### Row Level Security (RLS)

```sql
-- Profiles: Users can read all non-banned, update own
-- Posts: Users can read non-hidden from non-blocked users
-- Comments: Same as posts
-- Likes: Users can insert/delete own
-- Blocks: Users can manage own blocks
-- Reports: Users can insert, only admins can read
```

### Supabase Functions

Could use Edge Functions or database functions for:
- Auto-hide on report threshold
- Increment/decrement counters
- Word filter validation

---

## iOS Implementation

### New Files

```
ImanPath/
├── Services/
│   └── SupabaseService.swift       # Supabase client singleton
├── Models/
│   ├── CommunityPost.swift         # Post model
│   └── CommunityComment.swift      # Comment model
├── Views/
│   ├── Auth/
│   │   └── SignInView.swift        # Apple + Google sign in
│   └── Community/
│       ├── CommunityView.swift     # Main feed
│       ├── ComposePostView.swift   # New post sheet
│       ├── PostDetailView.swift    # Post + comments
│       └── TagPickerView.swift     # Tag selection sheet
├── Components/Community/
│   ├── PostCard.swift              # Post card component
│   ├── CommentRow.swift            # Comment row
│   └── TagChip.swift               # Tag filter chip
```

### Modified Files

| File | Changes |
|------|---------|
| `SettingsView.swift` | Add name editing field |
| `User.swift` | Add `supabaseUserId` field for linking |
| `HomeView.swift` | Add community navigation (if adding to home) |

### Dependencies

Add to project:
- `supabase-swift` - Supabase iOS SDK
- Includes Auth, Database, Realtime

### Auth Flow

```
App Launch
    │
    ▼
Community Tab Tapped
    │
    ▼
Is Signed In? ──No──► Show SignInView
    │                      │
    Yes                    ▼
    │              Sign in with Apple/Google
    │                      │
    ▼                      ▼
Show CommunityView ◄────────┘
```

### Data Flow

```
Local SwiftData          Supabase
┌─────────────┐         ┌─────────────┐
│   User      │         │  profiles   │
│   - name    │ ──────► │  - name     │
│   - streak  │         │             │
└─────────────┘         └─────────────┘

On post:
1. Read streak from local SwiftData
2. Send post to Supabase with streak_day snapshot
3. Supabase stores post with user_id from auth
```

---

## Moderation Details

### Word Filter

Simple blocklist approach:
```swift
let blockedWords = ["explicit", "terms", "here", ...]

func containsBlockedWord(_ text: String) -> Bool {
    let lowercased = text.lowercased()
    return blockedWords.contains { lowercased.contains($0) }
}
```

Check on:
- Post submit
- Comment submit

Return error: "Your message couldn't be posted. Please revise and try again."

### Report Flow

```
User taps ··· on post/comment
    │
    ▼
"Report" option
    │
    ▼
Optional reason input
    │
    ▼
Submit report to Supabase
    │
    ▼
Increment report_count on content
    │
    ▼
If report_count >= 3:
    Set is_hidden = true
    │
    ▼
Content hidden from feed until admin review
```

### Block Flow

```
User taps ··· on post
    │
    ▼
"Block User" option
    │
    ▼
Confirmation alert
    │
    ▼
Insert into blocks table
    │
    ▼
Posts/comments from blocked user hidden
Blocked user can't see your posts either
```

### Admin View

Simple SwiftUI view (or web dashboard) to:
- List reported content
- Preview content + report count
- Actions: Dismiss reports / Delete content / Ban user

---

## Implementation Order

### Phase 1: Auth Foundation
1. Add `supabase-swift` package
2. Create `SupabaseService.swift` singleton
3. Create Supabase tables + RLS policies
4. Build `SignInView.swift` (Apple + Google)
5. Link Supabase user to local User model

### Phase 2: Basic Feed
6. Create `CommunityPost.swift` model
7. Build `CommunityView.swift` (feed)
8. Build `PostCard.swift` component
9. Build `ComposePostView.swift`
10. Wire up posting + fetching

### Phase 3: Interactions
11. Add like functionality
12. Build `PostDetailView.swift`
13. Add comments
14. Build `CommentRow.swift`

### Phase 4: Tags & Filtering
15. Build `TagPickerView.swift`
16. Add tag to compose flow
17. Add tag filter chips to feed

### Phase 5: Moderation
18. Add delete own posts/comments
19. Add block user functionality
20. Add report flow
21. Add word filter
22. Build admin view (basic)

### Phase 6: Polish
23. Add name editing to Settings
24. Real-time updates (Supabase Realtime)
25. Pull to refresh
26. Empty states
27. Loading states
28. Error handling

---

## Effort Estimate

| Phase | Tasks | Time |
|-------|-------|------|
| Phase 1: Auth | 5 tasks | 3-4 hours |
| Phase 2: Feed | 5 tasks | 3-4 hours |
| Phase 3: Interactions | 4 tasks | 2-3 hours |
| Phase 4: Tags | 3 tasks | 1-2 hours |
| Phase 5: Moderation | 5 tasks | 3-4 hours |
| Phase 6: Polish | 5 tasks | 2-3 hours |
| **Total** | **27 tasks** | **~3-4 days** |

---

## Open Questions

1. **Where does Community live in the app?**
   - New tab in tab bar?
   - Card on home screen?
   - Separate section?

2. **Character limit for posts?**
   - Suggested: 500 characters

3. **Character limit for comments?**
   - Suggested: 250 characters

4. **Should streak day update on existing posts?**
   - Suggested: No, snapshot at time of posting

5. **Notifications?**
   - Likes on your post?
   - Comments on your post?
   - Replies to your comment?
   - (Can add later)

6. **Delete account flow?**
   - Need to handle Supabase user deletion
   - Cascade delete posts/comments

---

## Future Enhancements

- Push notifications for likes/comments
- Trending posts
- Search posts
- User profiles (view someone's posts)
- Accountability partners (private 1:1)
- Direct messages
- Post images
- Pin important posts (admin)

---

*Ready for review. Let me know if you want changes before we start building.*
