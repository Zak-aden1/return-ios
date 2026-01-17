# Coach Privacy - Data Sharing Concern

## The Issue
When users message the Coach, we send their personal data (journals, check-ins, why entries) to Anthropic's API. This data leaves their device.

## Current Flow
1. User's data stored locally in SwiftData
2. On Coach message, we build a "data pack" with:
   - Last 7 check-ins (ratings + reflections)
   - Last 5 journal entries (full content)
   - All "why" entries
   - Streak info
3. Data pack sent to Anthropic API
4. Response returned

## Competitor Comparison
- **Quittr**: Only sends streak data (not journals/whys)
- **Unchained**: Sends nothing - completely stateless

## Options to Consider

### Option 1: Keep as-is, be transparent
- Add clear disclosure in app
- "Your data is sent to our AI provider to personalize responses. It is not stored or used for training."
- Update privacy policy

### Option 2: Opt-in per data type
- Settings toggles:
  - "Share journals with Coach"
  - "Share check-ins with Coach"
  - "Share My Why with Coach"
- Users control what gets sent

### Option 3: Send summaries instead of raw content
Instead of actual journal text, send:
```
User has 5 journals. Recent themes: loneliness, nighttime struggles.
Mood trend: improving over last week.
Common triggers: late night, boredom.
```
- Gets personalization without sending raw personal content
- AI knows *about* patterns without reading actual words
- Would need to build a summarization layer

### Option 4: Streak-only mode (like Quittr)
- Only send streak stats
- No personal content
- Less personalized but more private

### Option 5: On-device AI (future)
- Use Apple's on-device models when capable enough
- Data never leaves device
- Currently limited capability

## Decision Needed
- Which option aligns with our values?
- What do users actually want?
- Is the personalization worth the privacy trade-off?

## Additional Notes / Recommendations
- Current UI copy says "data stays on device" while Coach sends data to Anthropic; this is misleading and should be corrected when we address this issue.
- Regardless of option, add explicit consent + a settings toggle to disable Coach and clear chat history.
- Consider a simple decision rubric for each option:
  - Privacy risk (low/med/high)
  - Personalization quality (low/med/high)
  - Engineering cost (low/med/high)
  - Trust impact (low/med/high)
- Option 3 (summaries) seems like the best middle ground if we want personalization without raw content.

## Notes
- Anthropic API data is not used for training by default
- But data IS processed on their servers
- Competitors chose privacy over personalization - was that intentional or just easier to build?
