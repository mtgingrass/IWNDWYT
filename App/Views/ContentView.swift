//
//  ContentView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DayCounterViewModel()
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text("🟢 \(viewModel.currentStreak) days")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.green)

                    Spacer()

                    Text("Longest streak: \(viewModel.longestStreak) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Total attempts: \(viewModel.totalAttempts)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Text("Reset Streak")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showResetConfirmation) {
                        Alert(
                            title: Text("Confirm Reset"),
                            message: Text("Are you sure you want to reset your current streak?"),
                            primaryButton: .destructive(Text("Reset")) {
                                viewModel.resetStreak()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    #if DEBUG
                    NavigationLink("Open Debug Panel") {
                        DebugPanelView()
                    }
                    .font(.footnote)
                    .padding(.top)
                    #endif
                    
                }
                .padding()
            }
            .navigationBarTitle("IWNDWYT", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
