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
    @EnvironmentObject private var sessionTracker: SessionTracker
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main content area with swipe support
                TabView(selection: $selectedTab) {
                    // Home Tab
                    NavigationView {
                        ContentView(selectedTab: $selectedTab, showingSettings: $showingSettings)
                            .navigationBarTitle(NSLocalizedString("app_title", comment: "App title"), displayMode: .inline)
                    }
                    .tag(0)
                    
                    // Active Streak Tab (only show if there's an active streak)
                    if viewModel.isActiveStreak {
                        NavigationView {
                            ActiveStreakView(selectedTab: $selectedTab, showingSettings: $showingSettings)
                        }
                        .tag(1)
                    }
                    
                    // Metrics Tab
                    NavigationView {
                        MetricsView(showingSettings: $showingSettings)
                    }
                    .tag(viewModel.isActiveStreak ? 2 : 1)
                    
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
                }
                .onChange(of: selectedTab) {
                    // Dismiss settings when user switches tabs
                    showingSettings = false
                }
                
                // Custom Tab Bar
                HStack {
                    TabBarButton(
                        icon: "house.fill",
                        title: NSLocalizedString("tab_home", comment: "Home tab title"),
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    if viewModel.isActiveStreak {
                        TabBarButton(
                            icon: "flame.fill",
                            title: NSLocalizedString("tab_streak", comment: "Streak tab title"),
                            isSelected: selectedTab == 1
                        ) {
                            selectedTab = 1
                        }
                    }
                    
                    TabBarButton(
                        icon: "chart.bar.fill",
                        title: NSLocalizedString("tab_metrics", comment: "Metrics tab title"),
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
            .fullScreenCover(isPresented: .constant(hasSeenIntro && !settings.hasChosenStartDate)) {
                StartDatePickerView()
            }
            .sheet(isPresented: $showingSettings) {
                NavigationView {
                    SettingsView()
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            
            // Motivational Popup
            if sessionTracker.shouldShowMotivationalPopup {
                MotivationalPopupView(
                    isPresented: $sessionTracker.shouldShowMotivationalPopup,
                    message: sessionTracker.motivationalMessage
                )
            }
            
            // Global Milestone Celebration
            if viewModel.showingMilestoneCelebration, let milestone = viewModel.celebrationMilestone {
                MilestoneCelebrationView(
                    isPresented: $viewModel.showingMilestoneCelebration,
                    milestone: milestone,
                    currentStreak: viewModel.currentStreak
                )
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(DayCounterViewModel.shared)
        .environmentObject(AppSettingsViewModel.shared)
        .environmentObject(SessionTracker.shared)
        .preferredColorScheme(.light)
} 
