//
//  TipJarView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/27/25.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @StateObject private var store = TipStore()
    @State private var showingSuccessAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Support the Developer")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                Text("This app is free to use. If you've found it helpful and want to leave a tip, thank you! It's greatly appreciated.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                if store.products.isEmpty {
                    ProgressView("Loading tips…")
                        .padding()
                } else {
                    VStack(spacing: 12) {
                        ForEach(store.products, id: \.id) { product in
                            Button {
                                Task {
                                    await store.purchase(product)
                                }
                            } label: {
                                HStack {
                                    Text(product.displayName)
                                    Spacer()
                                    
                                    if store.purchaseState == .purchasing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else if store.hasBeenPurchased(product) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .imageScale(.small)
                                        Text("Already Tipped")
                                            .font(.footnote)
                                    } else {
                                        Text(product.displayPrice)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(store.hasBeenPurchased(product) ? Color.gray : Color.blue, lineWidth: 1)
                                )
                            }
                            .foregroundColor(store.hasBeenPurchased(product) ? .gray : .blue)
                            .disabled(store.purchaseState == .purchasing || store.hasBeenPurchased(product))
                            .opacity(store.purchaseState == .purchasing || store.hasBeenPurchased(product) ? 0.6 : 1.0)
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Error message
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Purchase state feedback
                switch store.purchaseState {
                case .purchasing:
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Processing purchase...")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                case .success:
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Thank you for your support!")
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                case .failed:
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Purchase failed")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                case .idle:
                    EmptyView()
                }
            }
            .padding()
        }
        .navigationTitle("Leave a Tip")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.loadProducts()
        }
        .onChange(of: store.purchaseState) { _, newState in
            if newState == .success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    store.clearState()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        TipJarView()
    }
}
