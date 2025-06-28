import SwiftUI

#if DEBUG
struct DebugPanelView: View {
    @EnvironmentObject private var dayCounterViewModel: DayCounterViewModel
    
    @State private var offset = DateProvider.offsetInDays
    @State private var showingResetAlert = false

    var body: some View {
        Form {
            Section(header: Text("Debug: Simulated Time")) {
                Stepper("Days Offset: \(offset)", value: $offset, in: -30...365)
                    .onChange(of: offset) {
                        DateProvider.offsetInDays = offset
                        // Force refresh of any views relying on DateProvider.now
                        NotificationCenter.default.post(name: .dateOffsetChanged, object: nil)
                    }

                Button("Reset Offset") {
                    DateProvider.reset()
                    offset = 0
                }
            }
            
            Section(header: Text("Debug: App State")) {
                Button("Reset All User Defaults", role: .destructive) {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
                
                Text("This will clear all app data and reset to a fresh install state")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Debug Panel")
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllUserDefaults()
            }
        } message: {
            Text("This will clear all user defaults and reset the app to a fresh install state. This action cannot be undone.")
        }
    }
    
    private func resetAllUserDefaults() {
        // Clear all UserDefaults keys used by the app
        UserDefaults.standard.removeObject(forKey: "sobriety_data")
        UserDefaults.standard.removeObject(forKey: "hasChosenStartDate") 
        UserDefaults.standard.removeObject(forKey: "hasSeenIntro")
        
        // Reset DateProvider offset as well
        DateProvider.reset()
        offset = 0
        
        // Reset ViewModels to fresh state
        dayCounterViewModel.sobrietyData = SobrietyData(
            currentStartDate: DateProvider.now, 
            pastStreaks: [], 
            isActiveStreak: false
        )
        
        // Reset app settings using shared instance - this will trigger StartDatePickerView
        AppSettingsViewModel.shared.hasChosenStartDate = false
        
        // Force UI refresh
        dayCounterViewModel.objectWillChange.send()
        AppSettingsViewModel.shared.objectWillChange.send()
    }
}
#endif


