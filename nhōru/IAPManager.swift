import Foundation
import StoreKit
import UIKit

// com.YoungApp.Young
// com.nhoru.com

enum TransactionStates {
    case disabled
    case restored
    case purchased
    case failed
    case noReceiptFound
    case purchasing
    case unspecific
    case noProductsFound
    case removedTransactions
    case restoreFailed
    
    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .failed: return "Transaction failed"
        case .noReceiptFound: return "No receipt found"
        case .purchasing: return "Purchasing..."
        case .unspecific: return "Unspecific"
        case .noProductsFound: return "No products found"
        case .removedTransactions: return "Removed transactions"
        case .restoreFailed: return "Restore failed"
        }
    }
}

public indirect enum ReceiptServiceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case invalidURL
    case other(Error)
    case errorMessage(errorDesc: String?, statusCode: Int64? = nil)
}

public struct Products {
    public static let premiumPlan = "com.YoungApp.Young.Premium"
    public static let featurePlan = "com.YoungApp.Young.FeaturedPost"
    public static let unspecified = ""
    public static let productIdentifiers: Set<String> = [premiumPlan, featurePlan]
}

@MainActor
class IAPHandler: ObservableObject {
    
    static let shared = IAPHandler()
    private init() {
        // Start listening for transaction updates immediately
        Task {
            await observeTransactions()
            await updateSubscriptionStatus()
        }
    }
    
    // MARK: - Published Properties for SwiftUI
    @Published var isSubscribed: Bool = false
    @Published var purchasedProductID: String = ""
    @Published var subscriptionExpiry: String = ""
    
    // MARK: - Internal properties
    private(set) var availableProducts: [Product] = []
    private var transactionState: ((TransactionStates) -> Void)?
    
    // MARK: - Fetch Products
    func fetchAvailableProducts() async {
        do {
            let products = try await Product.products(for: Products.productIdentifiers)
            availableProducts = products
            if products.isEmpty {
                transactionState?(.noProductsFound)
                SharedMethods.debugLog("No products found")
            } else {
                for product in products {
                    let priceString = product.displayPrice
                    SharedMethods.debugLog("\(product.displayName): \(product.description) - \(priceString)")
                }
            }
        } catch {
            SharedMethods.debugLog("Failed to fetch products: \(error)")
            transactionState?(.noProductsFound)
        }
    }
    
    // MARK: - Purchase Product
    func purchase(productID: String, presentingIn viewController: UIViewController) async {
        guard let product = availableProducts.first(where: { $0.id == productID }) else {
            transactionState?(.noProductsFound)
            return
        }
        
        transactionState?(.purchasing)
        LoaderUtil.shared.showLoading()
        
        do {
            let result = try await product.purchase(confirmIn: viewController)
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    await transaction.finish()
                    handleSuccessfulTransaction(transaction)
                case .unverified(_, let error):
                    SharedMethods.debugLog("Purchase verification failed: \(error)")
                    transactionState?(.failed)
                }
            case .pending:
                transactionState?(.purchasing)
            case .userCancelled:
                transactionState?(.failed)
            @unknown default:
                transactionState?(.unspecific)
            }
        } catch {
            SharedMethods.debugLog("Purchase failed: \(error)")
            transactionState?(.failed)
        }
        
        LoaderUtil.shared.hideLoading()
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        LoaderUtil.shared.showLoading()
        var restoredAny = false
        
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                restoredAny = true
                handleSuccessfulTransaction(transaction)
                transactionState?(.restored)
                SharedMethods.debugLog("Restored: \(transaction.productID)")
            case .unverified(_, let error):
                SharedMethods.debugLog("Unverified restore: \(error)")
            }
        }
        
        if !restoredAny {
            transactionState?(.restoreFailed)
        }
        LoaderUtil.shared.hideLoading()
    }
    
    // MARK: - Observe transactions in background
    private func observeTransactions() async {
        for await verification in Transaction.updates {
            await handleTransactionUpdate(verification)
        }
    }
    
    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            await transaction.finish()
            SharedMethods.debugLog("⭐ Received transaction update: \(transaction.productID)")
            handleSuccessfulTransaction(transaction)
            transactionState?(.purchased)
        case .unverified(_, let error):
            SharedMethods.debugLog("Transaction update verification failed: \(error)")
            transactionState?(.failed)
        }
    }
    
    // MARK: - Handle successful transaction
    private func handleSuccessfulTransaction(_ transaction: Transaction) {
        purchasedProductID = transaction.productID
        if let expiration = transaction.expirationDate {
            subscriptionExpiry = expiration.ISO8601Format()
            isSubscribed = expiration > Date()
        } else {
            subscriptionExpiry = Date().ISO8601Format()
            isSubscribed = true
        }
    }
    
    // MARK: - Update subscription status immediately
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if Products.productIdentifiers.contains(transaction.productID) {
                    handleSuccessfulTransaction(transaction)
                }
            case .unverified(_, _):
                isSubscribed = false
            }
        }
    }
    
    // MARK: - Listen for purchase events (UI Callback)
    func performActionOnPurchasedEvent(completion: @escaping (_ state: TransactionStates) -> Void) {
        transactionState = { state in
            if state == .purchasing {
                LoaderUtil.shared.showLoading()
            } else {
                LoaderUtil.shared.hideLoading()
            }
            completion(state)
        }
    }
    
    // MARK: - Fetches the latest subscription status immediately (on appear or app launch)
    func refreshSubscriptionStatus() async {
        var hasActiveSubscription = false
        
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if Products.productIdentifiers.contains(transaction.productID) {
                    if let expiration = transaction.expirationDate {
                        if expiration > Date() {
                            hasActiveSubscription = true
                            handleSuccessfulTransaction(transaction)
                        }
                    } else {
                        // Non-expiring product
                        hasActiveSubscription = true
                        handleSuccessfulTransaction(transaction)
                    }
                }
            case .unverified(_, _):
                continue
            }
        }
        
        // If no active subscription found
        if !hasActiveSubscription {
            isSubscribed = false
            purchasedProductID = ""
        }
    }
}
