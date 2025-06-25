//
//  ContentView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var showEndConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    NavigationLink(destination: MetricsView()) {
                        VStack(spacing: 8) {
                            if viewModel.isActiveStreak {
                                Text("🟢 \(viewModel.currentStreak) days")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                            } else {
                                Text("Not tracking")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Tap for detailed metrics")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    if viewModel.longestStreak > 0 {
                        Text("Longest streak: \(viewModel.longestStreak) days")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Total attempts: \(viewModel.totalAttempts)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if viewModel.isActiveStreak {
                        Button(action: {
                            showEndConfirmation = true
                        }) {
                            Text("End Streak")
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            viewModel.startStreak()
                        }) {
                            Text("Start New Streak")
                                .foregroundColor(.green)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
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
            .alert("End Current Streak?", isPresented: $showEndConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("End Streak", role: .destructive) {
                    viewModel.endStreak()
                }
            } message: {
                Text("Are you sure you want to end your current streak? This will mark today as the end date.")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DayCounterViewModel.shared)
}
