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

    let productIDs = ["small.tip", "medium.tip", "big.tip"]

    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
            self.products.sort { $0.displayPrice < $1.displayPrice } // Optional: sort low to high
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    print("✅ Purchase successful: \(transaction.productID)")
                    // Optional: save purchase state if you want to disable repeat purchases
                } else {
                    print("❌ Purchase not verified")
                }
            case .userCancelled:
                print("❌ User cancelled")
            default:
                print("❌ Purchase failed: \(result)")
            }
        } catch {
            print("❌ Error purchasing: \(error)")
        }
    }
}
