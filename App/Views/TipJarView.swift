//
//  TipJarView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/27/25.
//

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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Support the Developer")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                Text("This app is free to use. If you’ve found it helpful and want to leave a tip, thank you! It's greatly appreciated.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                if store.products.isEmpty {
                    ProgressView("Loading tips…")
                } else {
                    ForEach(store.products, id: \.id) { product in
                        Button {
                            Task {
                                await store.purchase(product)
                            }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Leave a Tip")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.loadProducts()
        }
    }
}

#Preview {
    NavigationView {
        TipJarView()
    }
}
