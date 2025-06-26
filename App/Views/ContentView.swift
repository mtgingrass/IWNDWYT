//
//  ContentView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @EnvironmentObject private var settings: AppSettingsViewModel
    @State private var showEndConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    VStack(spacing: 24) {
                        if viewModel.isActiveStreak {
                            VStack(spacing: 20) {
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
                                
                                VStack(spacing: 16) {
                                    Text("Progress Milestones")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    MilestoneProgressView(currentStreak: viewModel.currentStreak)
                                        .padding(.vertical, 12)
                                        .frame(maxHeight: 320)
                                }
                            }
                        } else {
                            VStack(spacing: 16) {
                                Text("Ready for a Fresh Start?")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                if viewModel.longestStreak > 0 {
                                    VStack(spacing: 12) {
                                        HStack {
                                            Image(systemName: "trophy.fill")
                                                .foregroundColor(.yellow)
                                            Text("Best Streak: \(viewModel.longestStreak) days")
                                                .font(.headline)
                                                .foregroundColor(.green)
                                        }
                                        
                                        if let lastStreak = viewModel.sobrietyData.pastStreaks.sorted(by: { $0.endDate > $1.endDate }).first {
                                            let daysSinceLastStreak = Calendar.current.dateComponents([.day], from: lastStreak.endDate, to: Date()).day ?? 0
                                            
                                            VStack(spacing: 4) {
                                                if daysSinceLastStreak > 0 {
                                                    Text(daysSinceLastStreak == 1 ? 
                                                        "It's been 1 day since your last streak" :
                                                        "It's been \(daysSinceLastStreak) days since your last streak")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                HStack {
                                                    Image(systemName: "clock.arrow.circlepath")
                                                        .foregroundColor(.orange)
                                                    Text("Last streak: \(lastStreak.length) days")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                            
                                            if daysSinceLastStreak > 7 {
                                                Text("Ready to get back on track?")
                                                    .font(.headline)
                                                    .foregroundColor(.green)
                                            }
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
                                
                                // Motivational message
                                if viewModel.totalAttempts > 0 {
                                    Text("Each attempt makes you stronger 💪")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                }
                                Spacer()
                                
                                // Access to metrics and milestones
                                NavigationLink(destination: MetricsView()) {
                                    HStack {
                                        Image(systemName: "chart.bar.fill")
                                        Text(viewModel.longestStreak > 0 ? "View Progress & History" : "View Milestones")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        settings.toggleColorScheme()
                    } label: {
                        Image(systemName: settings.colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                            .imageScale(.medium)
                            .foregroundColor(settings.colorScheme == .dark ? .yellow : .primary)
                    }
                }
                
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
        .environmentObject(AppSettingsViewModel.shared)
}
