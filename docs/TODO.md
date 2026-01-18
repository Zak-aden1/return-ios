# App Store Submission Checklist

## Critical - Will Block Submission

| Item | Status | Notes |
|------|--------|-------|
| App Icon (1024x1024) | [x] | Added - placeholder "RETURN" text design |
| Privacy Manifest | [ ] | Create PrivacyInfo.xcprivacy - required for @AppStorage/UserDefaults usage |
| Privacy Policy URL | [x] | https://returntoiman.com/privacy |
| Terms of Service URL | [x] | https://returntoiman.com/terms |
| Free Trial UI vs Reality | [x] | Removed "free trial" text from PaywallScreen |

## Required Before Launch

| Item | Status | Notes |
|------|--------|-------|
| Tutorial Screens | [ ] | Need mockups/implementation |
| New Anthropic API Key | [ ] | Old key was exposed on GitHub - generate new one |
| Free Trial in ASC | [ ] | Optional: Add introductory offer in App Store Connect |

## App Store Connect Metadata

| Item | Status | Notes |
|------|--------|-------|
| App Description | [ ] | Write compelling description |
| Keywords | [ ] | Research relevant keywords |
| Screenshots | [ ] | All device sizes (6.7", 6.5", 5.5" minimum) |
| Age Rating | [ ] | Will need 17+ due to sensitive content |
| Subscription Screenshot | [ ] | Required for IAP review |
| Support URL | [ ] | |
| Copyright | [ ] | |

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

---

## File References

| File | Purpose |
|------|---------|
| `ImanPath/Assets.xcassets/AppIcon.appiconset/` | App icon (needs 1024x1024 image) |
| `ImanPath/PrivacyInfo.xcprivacy` | Privacy manifest (needs to be created) |
| `ImanPath/Onboarding/Screens/PaywallScreen.swift` | Subscription paywall with pricing cards |
| `Products.storekit` | Local StoreKit testing |
| `docs/SUBSCRIPTIONS.md` | Subscription documentation |
