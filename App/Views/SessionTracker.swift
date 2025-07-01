import SwiftUI

class SessionTracker: ObservableObject {
    static let shared = SessionTracker()
    
    private let lastOpenKey = "lastOpenDate"
    private let openCountKey = "openCount"
    private let sessionTimeout: TimeInterval = 60 * 15 // 15 minutes
    private let milestoneKey = "lastMilestoneShown"

    @Published var openCount: Int = UserDefaults.standard.integer(forKey: "openCount")
    @Published var shouldShowTipPrompt: Bool = false
    @Published var shouldShowMotivationalPopup: Bool = false
    @Published var motivationalMessage: String = ""

    private init() {
        // Listen for notification to show motivational popup
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showMotivationalPopup),
            name: .showMotivationalPopup,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

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
    
    @objc func showMotivationalPopup() {
        motivationalMessage = MotivationManager.shared.getRandomMotivationalMessage()
        shouldShowMotivationalPopup = true
    }
    
    func dismissMotivationalPopup() {
        shouldShowMotivationalPopup = false
    }
}
