//
//  SubscriptionManager.swift
//  Return
//
//  Handles StoreKit 2 subscriptions
//

import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // Product IDs matching App Store Connect
    enum ProductID: String, CaseIterable {
        case weekly = "week_5"
        case monthly = "month_10"
        case yearly = "yearly_50"

        var sortOrder: Int {
            switch self {
            case .weekly: return 0
            case .monthly: return 1
            case .yearly: return 2
            }
        }
    }

    // Published properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedSubscriptions: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // Subscription status
    var isSubscribed: Bool {
        !purchasedSubscriptions.isEmpty
    }

    // Transaction listener task
    private var transactionListener: Task<Void, Error>?

    private init() {
        // Start listening for transactions
        transactionListener = listenForTransactions()

        // Load products and check status on init
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: productIDs)

            // Sort by our preferred order
            products = storeProducts.sorted { p1, p2 in
                let order1 = ProductID(rawValue: p1.id)?.sortOrder ?? 99
                let order2 = ProductID(rawValue: p2.id)?.sortOrder ?? 99
                return order1 < order2
            }

            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Check if transaction is verified
                let transaction = try checkVerified(verification)

                // Update subscription status
                await updateSubscriptionStatus()

                // Finish the transaction
                await transaction.finish()

                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                // Transaction is pending (e.g., Ask to Buy)
                isLoading = false
                errorMessage = "Purchase is pending approval"
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            isLoading = false
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            isLoading = false
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Update Subscription Status

    func updateSubscriptionStatus() async {
        var activeSubscriptions: Set<String> = []

        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if it's one of our subscription products
                if ProductID(rawValue: transaction.productID) != nil {
                    activeSubscriptions.insert(transaction.productID)
                }
            } catch {
                // Transaction failed verification
                continue
            }
        }

        purchasedSubscriptions = activeSubscriptions
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for transactions that happen outside the app
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    // Update status on main actor
                    await self.updateSubscriptionStatus()

                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    // Transaction failed verification
                }
            }
        }
    }

    // MARK: - Verification Helper

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helper Methods

    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }

    func weeklyEquivalent(for product: Product) -> String? {
        guard let subscription = product.subscription else { return nil }

        let price = product.price
        let weeks: Decimal

        switch subscription.subscriptionPeriod.unit {
        case .week:
            weeks = Decimal(subscription.subscriptionPeriod.value)
        case .month:
            weeks = Decimal(subscription.subscriptionPeriod.value) * 4.33
        case .year:
            weeks = Decimal(subscription.subscriptionPeriod.value) * 52
        default:
            return nil
        }

        let weeklyPrice = price / weeks

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale

        if let formatted = formatter.string(from: weeklyPrice as NSDecimalNumber) {
            return "\(formatted)/week"
        }
        return nil
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    case purchaseFailed
    case productNotFound
}
