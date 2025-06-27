import SwiftUI

class AppSettingsViewModel: ObservableObject {
    static let shared = AppSettingsViewModel()
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasChosenStartDate") var hasChosenStartDate = false
    
    @Published var colorScheme: ColorScheme = .light
    
    init() {
        colorScheme = isDarkMode ? .dark : .light
    }
    
    func toggleColorScheme() {
        isDarkMode.toggle()
        colorScheme = isDarkMode ? .dark : .light
    }
    
    func markStartDateChosen() {
        hasChosenStartDate = true
    }
    
    func resetStartDateFlag() {
        hasChosenStartDate = false
    }
} 