import SwiftUI

class AppSettingsViewModel: ObservableObject {
    static let shared = AppSettingsViewModel()
    
    @AppStorage("hasChosenStartDate") var hasChosenStartDate = false
    
    // Always use light mode
    let colorScheme: ColorScheme = .light
    
    init() {
        // No color scheme initialization needed - always light
    }
    
    func markStartDateChosen() {
        hasChosenStartDate = true
    }
    
    func resetStartDateFlag() {
        hasChosenStartDate = false
    }
} 