//
//  TipStore.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/27/25.
//

import Foundation
import StoreKit

@MainActor
class TipStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchaseState: PurchaseState = .idle
    @Published var errorMessage: String?
    @Published private(set) var purchasedProductIDs: Set<String> = [] {
        didSet {
            savePurchasedProducts()
        }
    }
    
    private let purchasedProductsKey = "TipStore.purchasedProducts"
    
    init() {
        loadPurchasedProducts()
    }
    
    private func loadPurchasedProducts() {
        if let savedIDs = UserDefaults.standard.array(forKey: purchasedProductsKey) as? [String] {
            purchasedProductIDs = Set(savedIDs)
        }
    }
    
    private func savePurchasedProducts() {
        UserDefaults.standard.set(Array(purchasedProductIDs), forKey: purchasedProductsKey)
    }
    
    enum PurchaseState {
        case idle
        case purchasing
        case success
        case failed
    }

    let productIDs = ["small.tip", "medium.tip", "big.tip"]

    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
            self.products.sort { $0.displayPrice < $1.displayPrice } // Optional: sort low to high
        } catch {
            print("Failed to load products: \(error)")
            self.errorMessage = "Failed to load tip options. Please try again."
        }
    }

    func purchase(_ product: Product) async {
        guard purchaseState != .purchasing else { return }
        
        purchaseState = .purchasing
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handlePurchaseResult(verification)
            case .userCancelled:
                print("User cancelled purchase")
                purchaseState = .idle
            case .pending:
                print("Purchase is pending")
                purchaseState = .idle
                errorMessage = "Purchase is pending approval"
            @unknown default:
                print("Unknown purchase result: \(result)")
                purchaseState = .failed
                errorMessage = "Purchase failed with unknown error"
            }
        } catch {
            print("Error purchasing: \(error)")
            purchaseState = .failed
            
            if let storeError = error as? StoreKitError {
                switch storeError {
                case .userCancelled:
                    errorMessage = nil
                    purchaseState = .idle
                case .networkError:
                    errorMessage = "Network error. Please check your connection."
                case .systemError:
                    errorMessage = "System error. Please try again."
                default:
                    errorMessage = "Purchase failed. Please try again."
                }
            } else {
                errorMessage = "Purchase failed. Please try again."
            }
        }
    }
    
    private func handlePurchaseResult(_ verification: VerificationResult<Transaction>) async {
        switch verification {
        case .verified(let transaction):
            print("✅ Purchase successful: \(transaction.productID)")
            // Store the purchased product ID
            purchasedProductIDs.insert(transaction.productID)
            // Finish the transaction - this is crucial!
            await transaction.finish()
            purchaseState = .success
        case .unverified(let transaction, let error):
            print("❌ Purchase not verified: \(error)")
            await transaction.finish()
            purchaseState = .failed
            errorMessage = "Purchase could not be verified"
        }
    }
    
    func clearState() {
        purchaseState = .idle
        errorMessage = nil
    }
    
    func hasBeenPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    func hasBeenPurchased(_ product: Product) -> Bool {
        hasBeenPurchased(product.id)
    }
}
