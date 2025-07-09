//
//  StreakData.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation

///Each streak has a start and end date and a calculated length. Once the streak has an end date, it can be added to the `pastStreaks` array.
struct Streak: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let length: Int
}

struct StreakData: Codable {
    var currentStartDate: Date
    var pastStreaks: [Streak]
    var isActiveStreak: Bool
    
    var lastMessageDate: Date?
    
    init(currentStartDate: Date, pastStreaks: [Streak], isActiveStreak: Bool = true) {
        self.currentStartDate = currentStartDate
        self.pastStreaks = pastStreaks
        self.isActiveStreak = isActiveStreak
    }
}
