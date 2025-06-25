//
//  DayCounterViewModel.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation
import SwiftUI

class DayCounterViewModel: ObservableObject {
    static let shared = DayCounterViewModel()
    
    @Published var sobrietyData: SobrietyData

    private let storageKey = "sobriety_data"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(SobrietyData.self, from: data) {
            sobrietyData = decoded
        } else {
            // First time user
            sobrietyData = SobrietyData(currentStartDate: DateProvider.now, pastStreaks: [], isActiveStreak: false)
            save()
        }
        
        #if DEBUG
        NotificationCenter.default.addObserver(forName: .dateOffsetChanged, object: nil, queue: .main) { [weak self] _ in
            self?.refresh()
        }
        #endif
    }

    // Save to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(sobrietyData) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    // End current streak without starting a new one
    func endStreak() {
        guard sobrietyData.isActiveStreak else { return }
        
        let today = DateProvider.now
        let length = Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: today).day ?? 0

        let finishedStreak = Streak(
            id: UUID(),
            startDate: sobrietyData.currentStartDate,
            endDate: today,
            length: length
        )

        sobrietyData.pastStreaks.append(finishedStreak)
        sobrietyData.isActiveStreak = false
        save()
    }
    
    // Start a new streak
    func startStreak() {
        sobrietyData.currentStartDate = DateProvider.now
        sobrietyData.isActiveStreak = true
        save()
    }
    
    // Reset all data
    func resetAllData() {
        sobrietyData = SobrietyData(currentStartDate: DateProvider.now, pastStreaks: [], isActiveStreak: false)
        
        // Clear UserDefaults for this key
        UserDefaults.standard.removeObject(forKey: storageKey)
        
        // Save the fresh state
        save()
        
        // Force a refresh of the UI
        objectWillChange.send()
    }
    
    func refresh() {
        objectWillChange.send()
    }

    // Calculate days since currentStartDate
    var currentStreak: Int {
        guard sobrietyData.isActiveStreak else { return 0 }
        return Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: DateProvider.now).day ?? 0
    }

    var totalAttempts: Int {
        sobrietyData.pastStreaks.count + (sobrietyData.isActiveStreak ? 1 : 0)
    }

    var longestStreak: Int {
        let past = sobrietyData.pastStreaks.map { $0.length }.max() ?? 0
        return max(past, currentStreak)
    }
    
    var isActiveStreak: Bool {
        sobrietyData.isActiveStreak
    }
}
