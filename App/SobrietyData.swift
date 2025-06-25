//
//  SobrietyData.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation

struct Streak: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let length: Int
}

struct SobrietyData: Codable {
    let currentStartDate: Date
    let pastStreaks: [Streak]
    
    var lastMessageDate: Date?
}
