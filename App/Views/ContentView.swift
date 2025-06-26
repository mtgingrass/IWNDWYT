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
    @State private var showCancelConfirmation = false

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
                                    .padding(.bottom, 4)
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
                                .padding(.bottom, 8)

                                Spacer()

                                if viewModel.longestStreak > 0 {
                                    VStack(spacing: 16) {
//                                        Text("Your Progress")
//                                            .font(.title)
//                                            .foregroundColor(.secondary)
                                        SectionHeaderView(title: "Your Progress", systemImage: "flag.fill")

                                        VStack(spacing: 12) {
                                            MetricCardView(icon: "🏆", title: "Best Streak", value: "\(viewModel.longestStreak) days", valueColor: .green)

                                            if let lastStreak = viewModel.sobrietyData.pastStreaks.sorted(by: { $0.endDate > $1.endDate }).first {
                                                MetricCardView(icon: "⏱", title: "Previous Streak Ended", value: "\(lastStreak.length) days ago", valueColor: .primary)
                                            }

                                            MetricCardView(icon: "📈", title: "Total Attempts", value: "\(viewModel.totalAttempts)", valueColor: .primary)
                                        }
                                        .padding(.horizontal)
                                    }
                                } else {
                                    Text("Today is a Perfect Day to Start!")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                Spacer()
                                SectionHeaderView(title: "DETAILED HISTORY", systemImage: "chart.bar.fill")
                                NavigationLink(destination: MetricsView()) {
                                    MetricCardView(
                                        icon: "📊",
                                        title: "Progress & History",
                                        value: "View Details",
                                        valueColor: .secondary
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    if viewModel.isActiveStreak {
                        VStack(spacing: 12) {
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

                            if Calendar.current.isDate(viewModel.sobrietyData.currentStartDate, inSameDayAs: DateProvider.now) {
                                Button(action: {
                                    showCancelConfirmation = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.uturn.backward")
                                        Text("Cancel Streak")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.red.opacity(0.3), lineWidth: 1))
                                }
                            }
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
            .alert("Cancel Streak?", isPresented: $showCancelConfirmation) {
                Button("Keep Streak", role: .cancel) { }
                Button("Cancel Streak", role: .destructive) {
                    viewModel.cancelStreak()
                }
            } message: {
                Text("This will completely remove this streak attempt. It won't be saved or counted in your history. This action cannot be undone.")
            }
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    let systemImage: String?

    var body: some View {
        HStack {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
            }

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environmentObject(DayCounterViewModel.shared)
        .environmentObject(AppSettingsViewModel.shared)
}
