import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseManager: ObservableObject {

    static let shared = PurchaseManager()

    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published private(set) var weeklyProduct: Product?
    @Published private(set) var yearlyProduct: Product?

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

    // MARK: - PRODUCTS

    func loadProducts() async {

        do {

            let products = try await Product.products(
                for: [
                    weeklyProductID,
                    yearlyProductID
                ]
            )

            weeklyProduct = products.first {
                $0.id == weeklyProductID
            }

            yearlyProduct = products.first {
                $0.id == yearlyProductID
            }

        } catch {

            errorMessage = error.localizedDescription

            #if DEBUG
            print(
                "STOREKIT LOAD PRODUCTS ERROR:",
                error.localizedDescription
            )
            #endif
        }
    }

    // MARK: - DISPLAY PRICES

    var weeklyDisplayPrice: String {
        weeklyProduct?.displayPrice ?? "—"
    }

    var yearlyDisplayPrice: String {
        yearlyProduct?.displayPrice ?? "—"
    }

    // MARK: - YEARLY SAVINGS

    var yearlySavingsPercent: Int? {

        guard let weeklyProduct,
              let yearlyProduct else {
            return nil
        }

        let weeklyPrice = NSDecimalNumber(
            decimal: weeklyProduct.price
        )

        let yearlyPrice = NSDecimalNumber(
            decimal: yearlyProduct.price
        )

        let weeklyYearEquivalent =
            weeklyPrice.multiplying(
                by: NSDecimalNumber(value: 52)
            )

        guard weeklyYearEquivalent.doubleValue > 0 else {
            return nil
        }

        let difference =
            weeklyYearEquivalent.subtracting(yearlyPrice)

        let savingRatio =
            difference.dividing(by: weeklyYearEquivalent)

        let percentage =
            savingRatio.multiplying(
                by: NSDecimalNumber(value: 100)
            )

        return max(
            0,
            Int(percentage.doubleValue.rounded())
        )
    }

    var yearlySavingsText: String {

        guard let percentage = yearlySavingsPercent else {
            return ""
        }

        return "Save \(percentage)%"
    }

    // MARK: - PREMIUM STATUS

    func checkPremiumStatus() async {

        isLoading = true
        errorMessage = nil

        var hasPremium = false

        for await result in Transaction.currentEntitlements {

            if case .verified(let transaction) = result {

                if [weeklyProductID, yearlyProductID]
                    .contains(transaction.productID),
                   transaction.revocationDate == nil {

                    hasPremium = true
                }
            }
        }

        isPremium = hasPremium
        isLoading = false
    }

    // MARK: - PURCHASE

    func purchase(plan: PaywallPlan) async {

        isLoading = true
        errorMessage = nil

        do {

            let product: Product?

            switch plan {

            case .weekly:
                product = weeklyProduct

            case .yearly:
                product = yearlyProduct
            }

            let finalProduct: Product

            if let product {

                finalProduct = product

            } else {

                let productID: String

                switch plan {

                case .weekly:
                    productID = weeklyProductID

                case .yearly:
                    productID = yearlyProductID
                }

                let products = try await Product.products(
                    for: [productID]
                )

                guard let loadedProduct = products.first else {

                    errorMessage = "Subscription not found."
                    isLoading = false
                    return
                }

                finalProduct = loadedProduct
            }

            let result = try await finalProduct.purchase()

            switch result {

            case .success(let verification):

                if case .verified(let transaction) = verification {

                    await transaction.finish()

                    isPremium = true

                    await checkPremiumStatus()

                } else {

                    errorMessage =
                        "Purchase could not be verified."
                }

            case .userCancelled:

                break

            case .pending:

                errorMessage =
                    "Purchase is pending approval."

            @unknown default:

                errorMessage =
                    "Something went wrong."
            }

        } catch {

            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - RESTORE

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

            errorMessage =
                error.localizedDescription
        }
    }
}
