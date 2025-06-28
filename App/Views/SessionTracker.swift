import SwiftUI

class SessionTracker: ObservableObject {
    private let lastOpenKey = "lastOpenDate"
    private let openCountKey = "openCount"
    private let sessionTimeout: TimeInterval = 60 * 15 // 15 minutes
    private let milestoneKey = "lastMilestoneShown"

    @Published var openCount: Int = UserDefaults.standard.integer(forKey: "openCount")
    @Published var shouldShowTipPrompt: Bool = false

    func handleScenePhaseChange(to phase: ScenePhase) {
        guard phase == .active else { return }

        let now = Date()
        let lastOpen = UserDefaults.standard.object(forKey: lastOpenKey) as? Date ?? .distantPast

        if now.timeIntervalSince(lastOpen) > sessionTimeout {
            incrementOpenCount()
            UserDefaults.standard.set(now, forKey: lastOpenKey)
        }
    }

    private func incrementOpenCount() {
        openCount += 1
        UserDefaults.standard.set(openCount, forKey: openCountKey)
        print("App opened \(openCount) times")

        checkForMilestone()
    }

    private func checkForMilestone() {
        let milestones = [50, 150, 275, 500, 700]
        let lastShown = UserDefaults.standard.integer(forKey: milestoneKey)

        if milestones.contains(openCount) && openCount > lastShown {
            shouldShowTipPrompt = true
            UserDefaults.standard.set(openCount, forKey: milestoneKey)
        }
    }

    func dismissTipPrompt() {
        shouldShowTipPrompt = false
    }
}
