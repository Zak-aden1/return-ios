# Subscriptions & StoreKit Integration

## Overview

Return uses StoreKit 2 for in-app subscriptions. All subscription logic is handled natively without third-party SDKs (no RevenueCat).

---

## Product IDs

| Reference Name | Product ID | Duration | Price |
|----------------|------------|----------|-------|
| Weekly 5 | `week_5` | 1 week | $4.99 |
| Monthly 10 | `month_10` | 1 month | $9.99 |
| Yearly 50 | `yearly_50` | 1 year | $49.99 |

**Subscription Group:** `superwall` (Return Premium)

---

## Architecture

### SubscriptionManager.swift

Location: `ImanPath/Services/SubscriptionManager.swift`

Singleton class that handles all StoreKit operations:

```swift
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // Published state
    @Published var products: [Product]
    @Published var purchasedSubscriptions: Set<String>
    @Published var isLoading: Bool
    @Published var errorMessage: String?

    // Computed
    var isSubscribed: Bool

    // Methods
    func loadProducts() async
    func purchase(_ product: Product) async throws -> Bool
    func restorePurchases() async
    func updateSubscriptionStatus() async
}
```

**Key Features:**
- Auto-loads products on init
- Listens for transaction updates (purchases made outside app)
- Verifies transactions before granting access
- Handles pending transactions (Ask to Buy)

### PaywallScreen.swift

Location: `ImanPath/Onboarding/Screens/PaywallScreen.swift`

Displays subscription options dynamically from StoreKit:
- Fetches real prices (localized)
- Shows loading state while products load
- Handles purchase flow with error alerts
- Restore purchases functionality

---

## Testing

### Local Testing (Recommended for Development)

1. **StoreKit Configuration File:** `Products.storekit`
   - Synced with App Store Connect
   - Contains all subscription products

2. **Enable in Scheme:**
   - Product → Scheme → Edit Scheme
   - Run → Options → StoreKit Configuration → `Products.storekit`

3. **Test Features:**
   - Purchases complete instantly (no real charges)
   - Can simulate renewals, cancellations, refunds
   - Transaction Manager: Debug → StoreKit → Manage Transactions

### Sandbox Testing (Pre-Release)

1. Create sandbox tester in App Store Connect
2. Sign out of App Store on device
3. Build and run on physical device
4. Sign in with sandbox account when prompted

### Production

Products must be "Ready to Submit" in App Store Connect and app must be approved.

---

## App Store Connect Setup

### Subscription Group
- **Name:** superwall
- **Display Name:** Return Premium

### Required Metadata (per product)
- [x] Product ID
- [x] Reference Name
- [x] Duration
- [x] Price
- [x] Localization (Display Name + Description)
- [ ] Review Screenshot (required for submission)

### Optional: Introductory Offers
To enable "3-day free trial":
1. Edit subscription in App Store Connect
2. Subscription Prices → Add Introductory Offer
3. Select "Free" → Duration: 3 days

---

## Code Integration Points

### Checking Subscription Status

```swift
// Anywhere in the app
if SubscriptionManager.shared.isSubscribed {
    // Show premium feature
} else {
    // Show paywall or limited feature
}
```

### Showing Paywall

```swift
PaywallScreen(
    onSubscribe: {
        // User subscribed - proceed to app
    },
    onRestorePurchases: {
        // Purchases restored - proceed to app
    }
)
```

### Observing Changes

```swift
@StateObject private var subscriptionManager = SubscriptionManager.shared

// In view body
.onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
    if isSubscribed {
        // Unlock features
    }
}
```

---

## Current Implementation Status

| Feature | Status |
|---------|--------|
| Product fetching | Done |
| Purchase flow | Done |
| Restore purchases | Done |
| Transaction listener | Done |
| Local testing | Done |
| Paywall UI | Done |
| Feature gating | Not implemented |
| Free trial | Not configured in ASC |
| Subscription expiry handling | Basic (via transaction listener) |

---

## Future Considerations

### Feature Gating
Currently the app does not gate features behind subscription. Options:
- Gate AI Coach (most valuable feature)
- Gate advanced lessons (Week 2+)
- Full paywall (no access without subscription)

### Analytics
Consider tracking:
- Paywall views
- Purchase attempts
- Conversion rate by product
- Trial-to-paid conversion

### Promotional Offers
App Store Connect supports:
- Introductory offers (free trial, discounted period)
- Promotional offers (for existing/lapsed subscribers)
- Offer codes (shareable codes)

---

## Files Reference

| File | Purpose |
|------|---------|
| `Services/SubscriptionManager.swift` | StoreKit logic |
| `Onboarding/Screens/PaywallScreen.swift` | Paywall UI |
| `Products.storekit` | Local testing config |
