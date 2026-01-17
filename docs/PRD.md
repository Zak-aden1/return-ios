# ImanPath: Quit Porn with Iman
## Product Requirements Document v2

---

## Overview

**Product:** ImanPath - Islamic app helping Muslims quit pornography addiction

**Tagline:** Quit Porn with Iman

**Platform:** iOS (Swift/Xcode)

**Model:** Subscription (monthly/yearly), all features behind paywall, free trial

**Competitor Reference:**
- Unchaind: Quit Porn with Faith (~$30K MRR, Christian)
- Quittr: Quit Porn Now (~$350K MRR, secular, 25% CVR)

**Key Differentiator:** First and only app-based solution for Muslims. Zero competition.

---

## Target User

- Muslim male, 18-35
- Struggling with porn, wants to quit
- Practicing or trying to be more practicing
- Feels shame, can't talk to family/community (79% say this)
- Likely tried and failed before
- Wants Islamic framing, not secular self-help

---

## Onboarding Flow (Critical for Conversion)

The onboarding flow is the #1 conversion driver. Quittr achieves 25% CVR with a 40-step flow. We have 31 steps with high emotional + spiritual engagement, including a multi-step pledge system and comprehensive pre-paywall benefits screen.

### Step 1: Welcome
- "Assalamu Alaikum"
- "You're not alone in this struggle."
- "ImanPath is here to help you break free — with faith, not shame."
- CTA: "Begin"

### Step 2: Why Are You Here?
- "What brought you here today?"
- Options (multi-select):
  - I want to quit porn
  - I want to strengthen my iman
  - I want to protect my relationships
  - I want to feel clean again
  - I'm preparing for marriage
  - Other

### Steps 3-15: Emotional Quiz (13 questions)

| # | Question | Options |
|---|----------|---------|
| 3 | "How old are you?" | Under 18 / 18-24 / 25-34 / 35-44 / 45+ |
| 4 | "What is your gender?" | Male / Female |
| 5 | "How long have you struggled with this?" | < 1 year / 1-3 years / 3-5 years / 5-10 years / 10+ years |
| 6 | "How often do you watch porn?" | Daily / Few times a week / Weekly / Few times a month / Rarely |
| 7 | "Has the content you watch become more extreme over time?" | Yes / No / Not sure |
| 8 | "What is your relationship status?" | Single / In a relationship / Engaged / Married |
| 9 | "Has this affected your relationship or marriage?" (conditional: only if married/engaged) | Yes, significantly / Somewhat / No / My partner doesn't know |
| 10 | "How connected do you currently feel to Allah?" | Very connected / Somewhat connected / Disconnected / Very disconnected |
| 11 | "Has watching porn made you feel distant from Allah?" | Yes, very much / Yes, somewhat / Not sure / No |
| 12 | "Do you feel guilt or shame after watching?" | Always / Sometimes / Rarely / Never |
| 13 | "Do you repent after relapsing?" | Always / Sometimes / Rarely / I've stopped trying |
| 14 | "Have you tried to quit before?" | Yes, many times / Yes, a few times / This is my first time |
| 15 | "What happens when you try to quit?" | I relapse within days / I last a few weeks / I can go months but always come back |

### Step 16: Name Input
- "Finally, a little more about you"
- First name text field
- CTA: "Complete Quiz"

### Step 17: Calculating Screen
- "Analyzing your responses..."
- Progress bar animation
- Auto-advances after ~3 seconds

### Step 18: Dependence Analysis Screen
- Display personalized dependence score (calculated from quiz)
- Visual: circular progress or score out of 100
- Categories: "High dependence" / "Moderate dependence" / "Early stage"
- Key insights from quiz responses
- Copy: "You're not alone — recovery is possible."

### Step 19: Symptoms Selection
- "Excessive porn use can have negative impacts psychologically."
- Multi-select symptoms (optional):
  - Mental: Difficulty concentrating, Poor memory/brain fog, Feeling unmotivated, General anxiety, Lack of ambition
  - Spiritual: Feeling distant from Allah, Guilt or shame during prayer, Avoiding the Quran, Worship feels empty
- CTA: "Reboot my brain"

### Step 20: Education Carousel (4 Pain + 1 Hope)
- Swipeable carousel with 5 slides:
  - Slide 1 (Red): "Porn rewires your brain" — dopamine, addiction cycle
  - Slide 2 (Red): "Porn destroys relationships" — replaces real intimacy
  - Slide 3 (Red): "Porn dims your iman" — salah harder, du'a distant (Qur'an 70:29-30)
  - Slide 4 (Red): "Allah sees, yet offers mercy" — His mercy is greater (Qur'an 20:7)
  - Slide 5 (Green): "There is a way out" — recovery is possible, brain can reset
- Pagination dots, Next/Continue button

### Step 21: Solutions Carousel (6 Benefit Slides)
- Swipeable carousel with 6 slides (Lottie animations):
  - Slide 1 (Amber): "Welcome to ImanPath" — science-backed + Islamic guidance
  - Slide 2 (Gold): "Finally Break the Cycle" — end temptation, guilt, shame
  - Slide 3 (Blue): "Rewire Your Brain" — rebuild dopamine receptors
  - Slide 4 (Green): "Strengthen Your Iman" — daily du'as, spiritual practices
  - Slide 5 (Teal): "Stay Motivated" — track progress, build momentum
  - Slide 6 (Purple): "Reclaim Your Life" — sharper mind, stronger focus
- Pagination dots (elongated current), "Let's Begin" on final slide

### Step 22: Goals Intro
- "What does freedom look like to you?"
- Brief intro with inspirational framing
- Mountain sunrise visual (Fajr Dawn palette)
- CTA: "Choose My Goals"

### Step 23: Goals Selection
- Multi-select goal cards (8 options)
- Options: Strengthen Iman, Protect Family, Mental Clarity, Self-Respect, Better Focus, Break the Cycle, Emotional Health, Physical Energy
- Min: 1 selection, Max: 4
- Cards have icons and brief descriptions

### Step 24: Commitment Intro
- Personalized with user's name
- "You've taken a courageous first step"
- Builds anticipation for the pledge
- CTA: "I'm Ready"

### Step 25: Pledge Flow (3 Pledges)
- 3 sequential pledges with hold-to-commit interaction:
  1. "I acknowledge this habit has harmed me"
  2. "I commit to seeking Allah's help in overcoming this struggle"
  3. "I will take this journey one day at a time, trusting in Allah's mercy"
- Each requires 2-second hold to complete
- Progress indicator and haptic feedback
- Visual celebration after each pledge

### Step 26: Commitment Card (Niyyah)
- Full screen, premium feel
- Fajr Dawn palette (light, hopeful theme)
- Header: "Make Your Niyyah"
- Body: "I commit to quitting pornography for the sake of Allah."
- Below: "Porn-free by [DATE: 90 days from today]"
- User taps "I Commit" - behavioral lock-in moment

### Step 27: Commitment Congratulations
- 🕌 MashaAllah! celebration
- "You've taken a powerful first step"
- Hadith: "Whoever intends to do a good deed but does not do it, Allah records it as a complete good deed."
- Floating mosque animation with glow
- CTA: "Continue Your Journey"

### Step 28: Rating Request
- "We're a small team, so a rating goes a long way ❤️"
- 2 testimonial cards with 5-star ratings
- [Rate the App] button → triggers StoreKit review
- "Maybe later" skip link
- Auto-advances after rating

### Step 29: Typewriter Screen
- Auto-typing personalized messages (0.04s per character)
- Messages:
  1. "Welcome to ImanPath,"
  2. "Your path to freedom."
  3. "Based on your answers, we've built a plan just for you."
  4. "It's designed to help you quit porn and reconnect with Allah."
  5. "Now, it's time to invest in yourself."
- Haptic feedback per character
- Auto-advances to pre-paywall

### Step 30: Pre-Paywall Benefits
- Long scrollable value sell
- Personalized header: "[Name], we've made you a custom plan"
- Goal date card: "You will quit porn by [DATE]"
- Colorful benefit chips (wrapped grid)
- 5 sections with emojis + benefits:
  - 🕌 Your Path to Freedom
  - 📖 Break Free From the Cycle
  - 🧗 It's Time to Draw the Line
  - ☀️ Time to Live the Life You Envision
  - 🏆 The Ideal Future Version of You
- 5 testimonials distributed throughout
- Sticky CTA: "Begin Your Journey →"
- "No commitment, cancel anytime" reassurance

### Step 31: Paywall
- "Start Your Journey to Freedom"
- Features checklist with checkmarks
- Pricing cards (radio selection):
  - Yearly: $49.99/year (SAVE 58%) - default selected
  - Monthly: $9.99/month
- 🎁 "Start with a 3-day free trial"
- [Start Free Trial →] CTA button
- "Cancel anytime. No commitment." reassurance
- Restore Purchases | Terms | Privacy links

### Step 32: Home Screen
- Onboarding complete
- Show streak (Day 0), commitment card summary, first lesson unlocked

---

## MVP Features (v1)

### 1. Streak Counter

**Purpose:** Core motivation loop. Visual proof of progress.

**Requirements:**
- Large, prominent display on home screen
- Shows: current streak (days), longest streak, total clean days
- Resets on relapse (user self-reports)
- Celebratory UI at milestones (1, 3, 7, 14, 30, 50, 60, 75, 90, 120, 150, 270, 365 days)
- Islamic milestone messaging (e.g., "30 days — a full month of victory")
- Show commitment date: "Porn-free by [DATE]"

**UI:**
- Centered on home screen
- Large number, clean typography
- Commitment card visible (mini version or expandable)
- Subtle glow or animation on milestones
- "Reset" button (with confirmation + optional journal prompt)

---

### 2. Daily Check-ins

**Purpose:** Build habit, track patterns, catch warning signs early.

**Requirements:**
- Once daily prompt (configurable time, default evening)
- Push notification reminder
- Quick flow (under 60 seconds)

**Check-in Questions:**
1. "Did you stay clean today?" (Yes/No)
2. "How strong were your urges?" (1-5 scale)
3. "How is your iman today?" (1-5 scale)
4. "What's your energy level?" (1-5 scale)
5. "Any triggers today?" (Optional multi-select: stress, boredom, loneliness, late night, social media, other)

**After Check-in:**
- If clean: Encouragement + Quran verse
- If relapsed: Compassionate message + Tawbah guidance + reset streak (mercy framing: "Every return to Allah is a victory")

**Data:**
- Store locally + sync if account created
- Display trends over time (week/month view)

---

### 3. Panic Button

**Purpose:** Immediate intervention during urge/temptation moment.

**Requirements:**
- Always accessible (floating button or bottom nav)
- Single tap launches emergency flow
- No friction - speed is everything

**Panic Flow (Sequential Screens):**

**Screen 1: Breathe**
- "Pause. Breathe. Remember Allah."
- Breathing animation (4 in, 4 hold, 4 out)
- 15-20 seconds

**Screen 2: Dhikr**
- "Recite with your heart"
- A'udhu billahi min ash-shaytan ir-rajim
- Tap counter for repetitions (default: 3x)
- Audio option (recitation)

**Screen 3: Quran Verse**
- Random verse from curated list (~20-30 verses on desire, patience, tawbah, Allah's mercy)
- Arabic + translation
- Swipe for another verse

**Screen 4: Reminder**
- "You are stronger than this."
- "This urge will pass in 10-15 minutes."
- "Allah sees your struggle and loves your effort."

**Screen 5: Action Prompt**
- "What will you do now?"
- Options: "Make wudu" / "Pray 2 rakat" / "Go for a walk" / "Call someone" / "Journal"
- Tapping one = logs the action + closes panic mode

**Exit:**
- "You chose strength. Keep going."
- Return to home screen

---

### 4. Journal

**Purpose:** Process emotions, identify patterns, track spiritual growth.

**Requirements:**
- Quick entry (no friction)
- Optional prompts
- Private and secure
- Searchable

**Entry Types:**

**Quick Entry:**
- Freeform text
- Auto-timestamps
- Optional mood tag (emoji or word)

**Prompted Entry (Rotating Prompts):**
- "What triggered you today?"
- "What are you grateful for?"
- "How did you feel after your last relapse?"
- "What's one thing you're proud of this week?"
- "Write a letter to your future self."
- "What does freedom from this addiction look like?"

**Journal View:**
- Reverse chronological list
- Filter by date range
- Search

---

### 5. 30 Lessons in 30 Days

**Purpose:** Education + daily engagement hook + progress structure.

**Requirements:**
- One lesson unlocks per day
- Lesson = short content (~3-5 min read or audio)
- Each ends with action item or reflection question
- Progress tracker (visual: 30 dots or calendar)

**Lesson Structure:**

| Day | Topic |
|-----|-------|
| 1 | Why you're here (no shame, this is jihad an-imanpath) |
| 2 | The brain science of addiction |
| 3 | Why willpower alone fails |
| 4 | Understanding your triggers |
| 5 | The role of shaytan vs. the imanpath |
| 6 | Lowering the gaze (ghadd al-basar) |
| 7 | Week 1 reflection |
| 8 | Building new habits |
| 9 | The power of environment |
| 10 | Wudu as a reset |
| 11 | Prayer as protection |
| 12 | Fasting and desire |
| 13 | Dhikr for moments of weakness |
| 14 | Week 2 reflection |
| 15 | Shame vs. guilt (Islamic perspective) |
| 16 | Tawbah - how repentance works |
| 17 | Allah's mercy (Quran + hadith) |
| 18 | Relapses are not failure |
| 19 | The trap of isolation |
| 20 | Finding accountability |
| 21 | Week 3 reflection |
| 22 | Rewiring your brain |
| 23 | Healthy outlets for desire |
| 24 | Marriage and intimacy (Islamic view) |
| 25 | Protecting your eyes online |
| 26 | Phone and device boundaries |
| 27 | Social media and triggers |
| 28 | Week 4 reflection |
| 29 | Building a long-term plan |
| 30 | Your new identity in Allah |

**Lesson Format:**
- Title
- Body text (500-800 words) or audio (3-5 min)
- Quran/hadith references where relevant
- End with: reflection question or action item
- Mark complete button

**After Day 30:**
- Completion celebration
- Option to restart or access all lessons anytime
- Prompt to continue journey (future feature: advanced lessons)

---

### 6. AI Companion (MAYBE — v1 or v1.5)

**Purpose:** 24/7 support when user needs guidance, encouragement, or someone to talk to.

**Requirements:**
- Chat interface
- Islamic-aware responses (mercy-focused, not preachy)
- Can be generic LLM with system prompt if custom is too complex
- Limited messages per day (e.g., 10-20) to control costs

**Use Cases:**
- "I'm feeling tempted right now"
- "I just relapsed, I feel terrible"
- "How do I talk to my spouse about this?"
- "Give me a dua for strength"

**Tone:**
- Compassionate
- Never judgmental
- Points back to Allah's mercy
- Suggests practical actions (wudu, prayer, journal)

**Implementation Options:**
1. OpenAI API with Islamic system prompt (easiest)
2. Fine-tuned model (overkill for v1)
3. Skip for v1, add in v1.5 based on user demand

**Decision:** MAYBE for v1. If included, keep simple. If not, add to v1.5 roadmap.

---

## Screens Overview

| Screen | Purpose |
|--------|---------|
| Onboarding (31 steps) | Quiz, symptoms, education, solutions, goals, pledges, commitment, rating, typewriter, pre-paywall, paywall |
| Home | Streak, commitment card, check-in status, panic button, daily verse |
| Check-in Flow | Daily questions |
| Panic Flow | Emergency dhikr/Quran intervention |
| Journal | List view, new entry |
| Lessons | 30-day progress, current lesson |
| AI Chat (maybe) | 24/7 companion |
| Settings | Account, notifications, subscription, commitment date |

---

## Monetization

**Model:** Subscription

| Plan | Price | Notes |
|------|-------|-------|
| Monthly | $9.99 | Standard |
| Yearly | $59.99 | ~$5/month, push this |

**Free Trial:** 3 days

**Paywall Strategy:**
1. One-time offer (post-commitment): 80% off yearly, countdown timer
2. Standard paywall (if skipped): same pricing, no urgency
3. Price anchoring: show yearly first as "best value"

**Paywall Content:**
- "Start your journey to freedom"
- Feature list with checkmarks
- Social proof: "Join 1,000+ Muslims on this journey"
- Testimonials (2-3)
- Price anchoring (yearly vs monthly)
- "Cancel anytime"

---

## Design Direction

**Aesthetic:** Modern wellness app (Calm/Headspace vibe) with subtle Islamic influence

**Colors:**
- Background: Deep navy or dark teal (#0A1628 or #0D3B3E)
- Accent: Soft gold (#D4AF37) or warm amber
- Text: White, off-white
- Secondary: Muted greens, soft grays

**Typography:**
- Clean sans-serif for UI
- Optional: Arabic-style display font for headings (subtle)

**Islamic Elements:**
- Geometric patterns (subtle, background or dividers)
- NO crescent moons, mosque silhouettes, or clichés
- Occasional Arabic calligraphy for Quran verses

**Imagery:**
- Abstract
- Light rays, dawns, mountains (hope, strength)
- No people/faces

**Tone:**
- Calm, hopeful
- Masculine but not aggressive
- Spiritual but not preachy
- Encouraging, never shaming

**Commitment Card Design:**
- Premium feel
- Subtle border or glow
- User's commitment date prominently displayed
- Can be viewed anytime from home screen or settings

---

## Technical Notes

**Platform:** iOS (Swift/SwiftUI)

**Data Storage:**
- Local first (CoreData or SwiftData)
- Optional account creation for backup/sync (later)

**Backend (MVP):**
- Local-first (SwiftData) — no backend needed for v1
- StoreKit 2 + Superwall for subscriptions & paywalls
- OpenAI API for AI chat (if included)

**Push Notifications:**
- Daily check-in reminder
- Streak milestone celebrations
- Lesson unlock notifications

**Analytics:**
- Track: onboarding completion rate, quiz completion, paywall conversion, feature usage, retention
- Mixpanel, Amplitude, or PostHog

**Key Metrics to Instrument:**
- Quiz start → Quiz complete (drop-off per question)
- Quiz complete → Commitment signed
- Commitment signed → Paywall viewed
- Paywall viewed → Trial started
- Trial started → Paid conversion

**Privacy:**
- No data sold
- Discreet app icon option (future)
- Billing shows neutral company name

---

## App Store Listing

**Name:** ImanPath: Quit Porn with Iman

**Subtitle:** Islamic Guide to Break Free

**Keywords:** quit porn, islamic, muslim, nofap, addiction, iman, recovery, faith, dhikr, quran, habit, streak, clean, tawbah, haram

**Description:**

```
Struggling to quit porn? You're not alone.

ImanPath is the first app designed specifically for Muslims who want to break free from pornography and build a life of purity, purpose, and iman.

This is your jihad an-imanpath. And we're here to help you win.

FEATURES:

✓ Streak Tracking — See your progress and celebrate milestones
✓ Daily Check-ins — Build awareness and catch triggers early
✓ Panic Button — Instant dhikr and Quran when urges hit
✓ 30-Day Islamic Program — Learn the faith-based approach to beating addiction
✓ Journal — Process your thoughts and track your journey
✓ Commitment Card — Set your goal and stay accountable

Built by Muslims, for Muslims. No shame. No judgment. Just tools that work.

Join thousands of Muslims who are finding freedom.

Start your free trial today.
```

**Screenshots:**
1. Home screen with streak counter + commitment card
2. Onboarding quiz (emotional question)
3. Commitment card ("Porn-free by [date]")
4. Panic button flow (dhikr screen)
5. Quran verse display
6. Lessons progress

---

## Success Metrics

| Metric | Target (Month 3) |
|--------|------------------|
| Downloads | 5,000+ |
| Onboarding completion | 70%+ |
| Commitment card signed | 60% of onboarding completers |
| Trial starts | 40% of downloads |
| Trial → Paid | 25-30% |
| MRR | $5,000+ |
| Day 7 retention | 40% |
| Day 30 retention | 25% |

---

## Future Features (Post-MVP)

**v1.5:**
- AI companion (if not in v1)
- Content blocker (Screen Time integration)
- Discreet app icon

**v2:**
- In-app anonymous community
- Accountability partner matching
- Advanced lesson tracks (marriage prep, advanced recovery)
- Apple Watch app
- Widget for home screen (streak + commitment)
- Ramadan mode (special content)

**v3:**
- Android app
- Localization (Arabic, Urdu, Bahasa, Turkish)
- Christian fork (separate app, shared codebase)

---

## Open Questions

1. ~~Free trial length: 3 days or 7 days?~~ → **3 days**
2. AI companion in v1 or v1.5? → **MAYBE v1, otherwise v1.5**
3. Require account creation upfront or allow anonymous usage? → **Optional, prompt later**
4. Audio content for lessons (adds production time)? → **Text first, audio later**

---

## Next Steps

1. Finalize Figma designs for onboarding flow (quiz → commitment → paywall)
2. Design home screen with commitment card
3. Set up Xcode project + Firebase/RevenueCat
4. Build: Onboarding (20 steps) → Paywall → Home
5. Build: Streak + Check-in
6. Build: Panic Button
7. Build: Journal
8. Build: Lessons (content can be added progressively)
9. (Maybe) Build: AI Chat
10. TestFlight → soft launch
11. App Store submit
12. Launch → r/MuslimNoFap, Islamic TikTok, paid ads

---

## Competitive Positioning Summary

| Factor | Quittr | Unchaind | ImanPath |
|--------|--------|----------|------|
| Market | Secular | Christian | **Islamic** |
| Competition | High | Medium | **None** |
| Onboarding | 40 steps, 25% CVR | ~15 steps | 31 steps (target 20%+ CVR) |
| Commitment device | Signature | Date card | **Niyyah + Date card** |
| Panic button | Camera + motivation | ❌ | **Dhikr + Quran** |
| AI chat | ✅ | ✅ | Maybe |
| Community | ✅ In-app | ❌ | Telegram (v1), In-app (v2) |
| Pricing | $12.99/mo, $45/yr | ~$10/mo | $9.99/mo, $59.99/yr |

---

*Ship fast. Learn fast. Win the lane.*
