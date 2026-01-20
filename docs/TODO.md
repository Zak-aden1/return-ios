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
| Screenshots | [ ] | Need 6.7" iPhone screenshots |
| Age Rating | [x] | Completed - 16+ (varies by country) |
| Support URL | [x] | https://returntoiman.com/support |
| Copyright | [ ] | Enter "2025 Return" in ASC |
| Category | [x] | Health & Fitness |

## Before Submission

| Item | Status | Notes |
|------|--------|-------|
| Archive & Upload Build | [ ] | Xcode → Product → Archive → Distribute |
| Verify Subscriptions | [ ] | Test purchase flow in sandbox |
| Review App in TestFlight | [ ] | Final check before submission |

## Already Complete

- [x] Bundle ID registered
- [x] App created in App Store Connect
- [x] StoreKit 2 integration
- [x] Subscription products (week_5, month_10, yearly_50)
- [x] Hard paywall flow
- [x] Subscription expiry handling
- [x] Launch screen (auto-generated)
- [x] Camera usage description
- [x] Secrets.xcconfig in .gitignore
- [x] AI Coach streaming responses
- [x] First-tap lag fix
- [x] Website deployed (returntoiman.com)

---

## What's Left

1. **Screenshots** - Create App Store screenshots with captions
2. **Copyright** - Enter "2025 Return" in App Store Connect
3. **Archive & Upload** - Build and upload to App Store Connect
4. **Test in TestFlight** - Verify everything works
5. **Submit for Review** - Final submission

## File References

| File | Purpose |
|------|---------|
| `ImanPath/Assets.xcassets/AppIcon.appiconset/` | App icon |
| `ImanPath/PrivacyInfo.xcprivacy` | Privacy manifest |
| `ImanPath/Onboarding/Screens/PaywallScreen.swift` | Subscription paywall |
| `Products.storekit` | Local StoreKit testing |
| `docs/SUBSCRIPTIONS.md` | Subscription documentation |
