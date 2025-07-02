import StoreKit
import SwiftUI

class RatingManager: ObservableObject {
    static let shared = RatingManager()
    
    @AppStorage("hasRequestedRating") private var hasRequestedRating = false
    @AppStorage("ratingRequestCount") private var ratingRequestCount = 0
    @AppStorage("lastRatingRequestDate") private var lastRatingRequestDate: TimeInterval = 0
    @AppStorage("firstAppLaunchDate") private var firstAppLaunchDate: TimeInterval = 0
    
    private let maxRatingRequests = 3
    private let minimumDaysBetweenRequests = 60
    private let minimumAppUsageDays = 3
    
    private init() {
        if firstAppLaunchDate == 0 {
            firstAppLaunchDate = Date().timeIntervalSince1970
            print("📱 First app launch recorded: \(Date())")
        }
    }
    
    /// Check if we should request a rating with detailed logging
    func checkForRatingRequest(currentStreak: Int, isActiveStreak: Bool) {
        print("🔍 Rating check - Streak: \(currentStreak), Active: \(isActiveStreak)")
        
        // Check each condition with logging
        guard ratingRequestCount < maxRatingRequests else {
            print("❌ Rating blocked: Too many requests (\(ratingRequestCount)/\(maxRatingRequests))")
            return
        }
        
        let daysSinceLastRequest = daysSince(lastRatingRequestDate)
        guard daysSinceLastRequest >= minimumDaysBetweenRequests else {
            print("❌ Rating blocked: Too recent (\(daysSinceLastRequest)/\(minimumDaysBetweenRequests) days)")
            return
        }
        
        let daysSinceFirstLaunch = daysSince(firstAppLaunchDate)
        guard daysSinceFirstLaunch >= minimumAppUsageDays else {
            print("❌ Rating blocked: App too new (\(daysSinceFirstLaunch)/\(minimumAppUsageDays) days)")
            return
        }
        
        guard isActiveStreak else {
            print("❌ Rating blocked: No active streak")
            return
        }
        
        let shouldRequest = checkOptimalConditions(currentStreak: currentStreak)
        print("🎯 Optimal conditions met: \(shouldRequest)")
        
        if shouldRequest {
            print("✅ All conditions met - requesting rating!")
            requestRating()
        } else {
            print("⏳ Waiting for optimal streak milestone")
        }
    }
    
    /// Check optimal conditions with detailed logging
    func checkOptimalConditions(currentStreak: Int) -> Bool {
        // Tier 1: Sweet spot
        if currentStreak == 3 || currentStreak == 7 {
            print("🌟 Tier 1 milestone reached: Day \(currentStreak)")
            return true
        }
        
        // Tier 2: Weekly milestones
        if currentStreak > 7 && currentStreak % 7 == 0 && currentStreak <= 28 {
            let shouldShow = ratingRequestCount == 0
            print("📅 Weekly milestone: Day \(currentStreak), First request: \(shouldShow)")
            return shouldShow
        }
        
        // Tier 3: Major milestones
        if currentStreak == 30 || currentStreak == 60 || currentStreak == 90 {
            print("🏆 Major milestone reached: Day \(currentStreak)")
            return true
        }
        
        print("⏳ No milestone conditions met for day \(currentStreak)")
        return false
    }
    
    /// Request rating with logging
    private func requestRating() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                
                print("📱 Showing rating dialog...")
                SKStoreReviewController.requestReview(in: windowScene)
                
                self.ratingRequestCount += 1
                self.lastRatingRequestDate = Date().timeIntervalSince1970
                
                print("📊 Rating request completed (attempt \(self.ratingRequestCount))")
                print("📅 Next request possible after: \(Date().addingTimeInterval(TimeInterval(self.minimumDaysBetweenRequests * 24 * 60 * 60)))")
            } else {
                print("❌ No active window scene for rating request")
            }
        }
    }
    
    /// Force rating request for testing
    func forceRatingRequest() {
        print("🧪 FORCED rating request")
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
                print("📱 Forced rating dialog shown")
            }
        }
    }
    
    /// Reset for testing
    func resetRatingData() {
        hasRequestedRating = false
        ratingRequestCount = 0
        lastRatingRequestDate = 0
        // Don't reset firstAppLaunchDate unless specifically needed
        print("🔄 Rating data reset - fresh start!")
    }
    
    /// Reset everything including first launch (for thorough testing)
    func completeReset() {
        hasRequestedRating = false
        ratingRequestCount = 0
        lastRatingRequestDate = 0
        firstAppLaunchDate = Date().timeIntervalSince1970
        print("🔄 Complete rating reset - simulating fresh install")
    }
    
    private func daysSince(_ timestamp: TimeInterval) -> Int {
        guard timestamp > 0 else { return Int.max }
        let date = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
    
    var shouldShowRateAppOption: Bool {
        let daysSinceFirstLaunch = daysSince(firstAppLaunchDate)
        return daysSinceFirstLaunch >= minimumAppUsageDays
    }
    
    var debugInfo: String {
        let daysSinceFirstLaunch = daysSince(firstAppLaunchDate)
        let daysSinceLastRequest = daysSince(lastRatingRequestDate)
        let canRequest = ratingRequestCount < maxRatingRequests && daysSinceLastRequest >= minimumDaysBetweenRequests
        
        return """
        Rating Debug:
        • Requests: \(ratingRequestCount)/\(maxRatingRequests)
        • Days since launch: \(daysSinceFirstLaunch)
        • Days since request: \(daysSinceLastRequest)
        • Can request: \(canRequest)
        • Next eligible: \(canRequest ? "Now" : "Day \(minimumDaysBetweenRequests - daysSinceLastRequest)")
        """
    }
}

#if DEBUG
// Add this extension to the end of your RatingManager.swift file
extension RatingManager {
    /// More detailed debug info
    var detailedDebugInfo: String {
        let daysSinceFirstLaunch = daysSince(firstAppLaunchDate)
        let daysSinceLastRequest = daysSince(lastRatingRequestDate)
        let canRequest = ratingRequestCount < maxRatingRequests && daysSinceLastRequest >= minimumDaysBetweenRequests
        
        return """
        Rating System Status:
        📊 Request count: \(ratingRequestCount)/\(maxRatingRequests)
        📅 Days since first launch: \(daysSinceFirstLaunch)
        ⏰ Days since last request: \(daysSinceLastRequest)
        ✅ Can request now: \(canRequest)
        🎯 Show rate option: \(shouldShowRateAppOption)
        📱 First launch: \(Date(timeIntervalSince1970: firstAppLaunchDate))
        🔄 Last request: \(lastRatingRequestDate > 0 ? Date(timeIntervalSince1970: lastRatingRequestDate).description : "Never")
        
        Milestone Status:
        🌟 Next milestones: 3, 7, 14, 21, 28, 30, 60, 90 days
        """
    }
    
    /// Test if rating would be shown for a given streak
    func wouldShowRatingFor(streak: Int, isActive: Bool) -> Bool {
        guard ratingRequestCount < maxRatingRequests else { return false }
        guard daysSince(lastRatingRequestDate) >= minimumDaysBetweenRequests else { return false }
        guard daysSince(firstAppLaunchDate) >= minimumAppUsageDays else { return false }
        guard isActive else { return false }
        
        return checkOptimalConditions(currentStreak: streak)
    }
    
    /// Test optimal conditions for debugging
    func testOptimalConditions(currentStreak: Int) -> Bool {
        return checkOptimalConditions(currentStreak: currentStreak)
    }
    
    /// Get next milestone for current streak
    func getNextMilestone(currentStreak: Int) -> Int? {
        let milestones = [3, 7, 14, 21, 28, 30, 60, 90, 180, 365]
        return milestones.first { $0 > currentStreak }
    }
}
#endif
