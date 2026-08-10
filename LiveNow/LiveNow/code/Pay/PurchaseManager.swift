//
//  PurchaseManager.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 31. 5. 2026.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let weeklyProductID = "livenow_premium_weekly"
    private let yearlyProductID = "livenow_premium_yearly"
    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await checkPremiumStatus()
                }
            }
        }
    }
    
    func checkPremiumStatus() async {
        isLoading = true
        errorMessage = nil

        var hasPremium = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {

                if [weeklyProductID, yearlyProductID].contains(transaction.productID),
                   transaction.revocationDate == nil {
                    hasPremium = true
                }
            }
        }

        isPremium = hasPremium

        isLoading = false
    }

    func purchase(plan: PaywallPlan) async {
        isLoading = true
        errorMessage = nil

        do {
            let productID: String

            switch plan {
            case .weekly:
                productID = weeklyProductID
            case .yearly:
                productID = yearlyProductID
            }

            let products = try await Product.products(for: [productID])

            guard let product = products.first else {
                errorMessage = "Subscription not found."
                isLoading = false
                return
            }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {

                    await transaction.finish()

                    isPremium = true

                    await checkPremiumStatus()

                } else {
                    errorMessage = "Purchase could not be verified."
                }

            case .userCancelled:
                break

            case .pending:
                errorMessage = "Purchase is pending approval."

            @unknown default:
                errorMessage = "Something went wrong."
            }

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func restore() async {
        isLoading = true
        defer {
            isLoading = false
        }

        errorMessage = nil

        do {
            try await AppStore.sync()

            await checkPremiumStatus()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
