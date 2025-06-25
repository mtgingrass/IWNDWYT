//
//  DateProvider.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation

#if DEBUG
final class DateProvider {
    static var offsetInDays: Int = 0

    static var now: Date {
        Calendar.current.date(byAdding: .day, value: offsetInDays, to: Date()) ?? Date()
    }

    static func reset() {
        offsetInDays = 0
    }
}
#else
enum DateProvider {
    static var now: Date {
        Date()
    }
}
#endif

extension Notification.Name {
    static let dateOffsetChanged = Notification.Name("dateOffsetChanged")
}
