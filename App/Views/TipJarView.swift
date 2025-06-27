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

struct TipJarView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Tip Jar")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)

                Text("This app is free and always will be. Tipping the developer is optional.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        TipButton(amount: "$0.99")
                        TipButton(amount: "$2.99")
                        TipButton(amount: "$4.99")
                    }

                    TipButton(amount: "Custom")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TipButton: View {
    var amount: String

    var body: some View {
        Button(action: {
            // Placeholder for future in-app purchase logic
        }) {
            Text(amount)
                .font(.callout)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        TipJarView()
    }
}
