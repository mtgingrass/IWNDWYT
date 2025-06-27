//
//  MainTabView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @EnvironmentObject private var settings: AppSettingsViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area with swipe support
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationView {
                    ContentView(selectedTab: $selectedTab)
                        .navigationBarTitle("IWNDWYT", displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink {
                                    SettingsView()
                                } label: {
                                    Image(systemName: "gear")
                                        .imageScale(.medium)
                                }
                            }
                        }
                }
                .tag(0)
                
                // Active Streak Tab (only show if there's an active streak)
                if viewModel.isActiveStreak {
                    NavigationView {
                        ActiveStreakView(selectedTab: $selectedTab)
                    }
                    .tag(1)
                }
                
                // Metrics Tab
                NavigationView {
                    MetricsView()
                }
                .tag(viewModel.isActiveStreak ? 2 : 1)
                
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom Tab Bar
            HStack {
                TabBarButton(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                if viewModel.isActiveStreak {
                    TabBarButton(
                        icon: "flame.fill",
                        title: "Streak",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                }
                
                TabBarButton(
                    icon: "chart.bar.fill",
                    title: "Metrics",
                    isSelected: selectedTab == (viewModel.isActiveStreak ? 2 : 1)
                ) {
                    selectedTab = viewModel.isActiveStreak ? 2 : 1
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: -1)
        }
        .fullScreenCover(isPresented: .constant(!settings.hasChosenStartDate)) {
            StartDatePickerView()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(DayCounterViewModel.shared)
        .environmentObject(AppSettingsViewModel.shared)
        .preferredColorScheme(.light)
} 
