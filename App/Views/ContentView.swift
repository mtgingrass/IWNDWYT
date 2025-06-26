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
                    VStack(spacing: 20) {
                        if viewModel.isActiveStreak {
                            NavigationLink(destination: MetricsView()) {
                                VStack(spacing: 8) {
                                    Text("🟢 \(viewModel.currentStreak) days")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.green)
                                    
                                    Text("Tap for detailed metrics")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            VStack(spacing: 16) {
                                Text("Ready for a Fresh Start?")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                if viewModel.longestStreak > 0 {
                                    VStack(spacing: 8) {
                                        HStack {
                                            Image(systemName: "trophy.fill")
                                                .foregroundColor(.yellow)
                                            Text("Best Streak: \(viewModel.longestStreak) days")
                                                .font(.headline)
                                                .foregroundColor(.green)
                                        }
                                        
                                        if let lastStreak = viewModel.sobrietyData.pastStreaks.sorted(by: { $0.endDate > $1.endDate }).first {
                                            VStack(spacing: 4) {
                                                Text("Last Attempt: \(lastStreak.endDate.formatted(date: .abbreviated, time: .omitted))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Text("\(lastStreak.length) days")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                } else {
                                    Text("Today is a Perfect Day to Start!")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                
                                Button(action: {
                                    viewModel.startStreak()
                                }) {
                                    HStack {
                                        Image(systemName: "sunrise.fill")
                                            .imageScale(.large)
                                        Text("Start New Streak")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                if viewModel.totalAttempts > 0 {
                                    Text("Each attempt makes you stronger 💪")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                }
                            }
                        }
                    }

                    Spacer()

                    VStack(spacing: 16) {
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
                        }
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
