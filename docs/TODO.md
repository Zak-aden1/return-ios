# App Store Submission Checklist

## Critical - Will Block Submission

| Item | Status | Notes |
|------|--------|-------|
| App Icon (1024x1024) | [x] | Added - placeholder "RETURN" text design |
| Privacy Manifest | [x] | Created PrivacyInfo.xcprivacy for UserDefaults usage |
| Privacy Policy URL | [x] | https://returntoiman.com/privacy |
| Terms of Service URL | [x] | https://returntoiman.com/terms |
| Free Trial UI vs Reality | [x] | Removed "free trial" text from PaywallScreen |

## App Store Connect Metadata

| Item | Status | Notes |
|------|--------|-------|
| App Description | [x] | Drafted - ready to paste into ASC |
| Subtitle | [x] | "Quit Porn with Iman" |
| Promotional Text | [x] | Drafted (170 chars) |
| Keywords | [x] | Drafted (100 chars) |
| Screenshots | [x] | Created with device mockups |
| Age Rating | [x] | Completed - 16+ (varies by country) |
| Support URL | [x] | https://returntoiman.com/support |
| Copyright | [x] | "2026 Return" |
| Category | [x] | Health & Fitness |

## Before Submission

| Item | Status | Notes |
|------|--------|-------|
| Archive & Upload Build | [x] | Uploaded to App Store Connect |
| Verify Subscriptions | [ ] | Blocked - waiting on ASC business/tax agreements |
| Review App in TestFlight | [~] | Partial - can't test past paywall until subscriptions enabled |
| Submit for Review | [ ] | Ready once subscriptions verified |

## Already Complete

- [x] Bundle ID registered
- [x] App created in App Store Connect
- [x] StoreKit 2 integration
- [x] Subscription products (week_5, month_10, yearly_50, trail_yearly_40, yearly_40)
- [x] Hard paywall flow
- [x] Subscription expiry handling
- [x] Launch screen (auto-generated)
- [x] Camera usage description
- [x] Secrets.xcconfig in .gitignore
- [x] AI Coach streaming responses
- [x] First-tap lag fix
- [x] Website deployed (returntoiman.com)
- [x] Win-back paywall (transaction abandon + shortcut action)
- [x] Home screen quick actions
- [x] Education carousel (4 pain + 1 hope structure)
- [x] Commitment card hold-to-commit

---

## What's Left

1. **Complete ASC business/tax setup** - Blocking subscription testing
2. **Test full purchase flow** - Once subscriptions enabled
3. **Submit for Review** - Final submission

## File References

| File | Purpose |
|------|---------|
| `ImanPath/Assets.xcassets/AppIcon.appiconset/` | App icon |
| `ImanPath/PrivacyInfo.xcprivacy` | Privacy manifest |
| `ImanPath/Onboarding/Screens/PaywallScreen.swift` | Main subscription paywall |
| `ImanPath/Views/Paywall/WinBackPaywallView.swift` | Win-back paywall (2 sources) |
| `Products.storekit` | Local StoreKit testing |
| `docs/SUBSCRIPTIONS.md` | Subscription documentation |
