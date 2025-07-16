import SwiftUI

struct MilestoneProgressView: View {
    let currentStreak: Int
    @State private var celebratingMilestones: Set<Int> = []
    @State private var lastCelebrated: Int = -1
    
    private var milestones: [Milestone] {
        return [
            // Row 1 - Early Wins
            Milestone(days: 1, title: NSLocalizedString("milestone_day_1", comment: "Day 1 milestone"), emoji: "🌱"),
            Milestone(days: 2, title: NSLocalizedString("milestone_2_days", comment: "2 Days milestone"), emoji: "🍀"),
            Milestone(days: 5, title: NSLocalizedString("milestone_5_days", comment: "5 Days milestone"), emoji: "⭐️"),
            Milestone(days: 7, title: NSLocalizedString("milestone_1_week", comment: "1 Week milestone"), emoji: "🌟"),
            // Row 2 - Building Momentum
            Milestone(days: 14, title: NSLocalizedString("milestone_2_weeks", comment: "2 Weeks milestone"), emoji: "🎯"),
            Milestone(days: 30, title: NSLocalizedString("milestone_1_month", comment: "1 Month milestone"), emoji: "🏆"),
            Milestone(days: 60, title: NSLocalizedString("milestone_2_months", comment: "2 Months milestone"), emoji: "💫"),
            Milestone(days: 90, title: NSLocalizedString("milestone_3_months", comment: "3 Months milestone"), emoji: "🌙"),
            // Row 3 - Major Achievements
            Milestone(days: 180, title: NSLocalizedString("milestone_6_months", comment: "6 Months milestone"), emoji: "🌞"),
            Milestone(days: 365, title: NSLocalizedString("milestone_1_year", comment: "1 Year milestone"), emoji: "👑"),
            Milestone(days: 730, title: NSLocalizedString("milestone_2_years", comment: "2 Years milestone"), emoji: "🎊"),
            Milestone(days: 1095, title: NSLocalizedString("milestone_3_years", comment: "3 Years milestone"), emoji: "⚡️")
        ]
    }
    
    private var rows: [[Milestone]] {
        var result: [[Milestone]] = []
        var currentRow: [Milestone] = []
        
        for (index, milestone) in milestones.enumerated() {
            currentRow.append(milestone)
            
            // Each row gets 4 items
            if currentRow.count == 4 || index == milestones.count - 1 {
                result.append(currentRow)
                currentRow = []
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(rows.enumerated()), id: \.0) { rowIndex, rowMilestones in
                HStack(spacing: 16) {
                    ForEach(rowMilestones) { milestone in
                VStack(spacing: 8) {
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 4)
                        
                        // Progress circle with gradient
                        Circle()
                            .trim(from: 0, to: min(CGFloat(max(0, currentStreak - 1)) / CGFloat(milestone.days), 1.0))
                            .stroke(
                                (currentStreak - 1) >= milestone.days ? 
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .mint, .cyan]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    gradient: Gradient(colors: [.green.opacity(0.5), .green.opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .scaleEffect((currentStreak - 1) >= milestone.days && celebratingMilestones.contains(milestone.days) ? 1.2 : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentStreak)
                        
                        // Glow effect for completed milestones
                        if (currentStreak - 1) >= milestone.days {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.cyan.opacity(0.3), .green.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 12
                                )
                                .blur(radius: 4)
                                .scaleEffect(celebratingMilestones.contains(milestone.days) ? 1.3 : 1.1)
                                .opacity(celebratingMilestones.contains(milestone.days) ? 0.8 : 0.4)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: celebratingMilestones.contains(milestone.days))
                        }
                        
                        // Celebration particles
                        if celebratingMilestones.contains(milestone.days) {
                            ForEach(0..<8, id: \.self) { index in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.yellow, .orange, .red]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 4, height: 4)
                                    .offset(
                                        x: cos(Double(index) * .pi / 4) * 30,
                                        y: sin(Double(index) * .pi / 4) * 30
                                    )
                                    .scaleEffect(celebratingMilestones.contains(milestone.days) ? 1.5 : 0)
                                    .opacity(celebratingMilestones.contains(milestone.days) ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.1),
                                        value: celebratingMilestones.contains(milestone.days)
                                    )
                            }
                        }
                        
                        // Center content with enhanced styling
                        VStack(spacing: 2) {
                            Text(milestone.emoji)
                                .font(.title2)
                                .scaleEffect((currentStreak - 1) >= milestone.days ? 
                                    (celebratingMilestones.contains(milestone.days) ? 1.5 : 1.2) : 0.8)
                                .opacity((currentStreak - 1) >= milestone.days ? 1 : 0.4)
                                .shadow(
                                    color: (currentStreak - 1) >= milestone.days ? .yellow.opacity(0.6) : .clear,
                                    radius: celebratingMilestones.contains(milestone.days) ? 8 : 0
                                )
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentStreak)
                            
                            if currentStreak <= milestone.days {
                                let completedDays = max(0, currentStreak - 1)
                                Text("\(completedDays)/\(milestone.days)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        // Completion checkmark
                        if (currentStreak - 1) >= milestone.days {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 16, height: 16)
                                        )
                                        .scaleEffect(celebratingMilestones.contains(milestone.days) ? 1.3 : 1.0)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: celebratingMilestones.contains(milestone.days))
                                }
                                Spacer()
                            }
                            .frame(width: 55, height: 55)
                        }
                    }
                    .frame(width: 55, height: 55)
                    
                    Text(milestone.title)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(height: 28)
                }
                .scaleEffect(celebratingMilestones.contains(milestone.days) ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStreak)
                .onChange(of: currentStreak) { _, newValue in
                    checkForNewMilestones(newStreak: newValue)
                }
            }
            //Spacer()  // Center the items if row is not full
        }
    }
}
        .padding(.horizontal)
        .onAppear {
            // Initialize celebration state
            lastCelebrated = currentStreak
        }
    }
    
    private func checkForNewMilestones(newStreak: Int) {
        // Find newly completed milestones
        let newlyCompleted = milestones.filter { milestone in
            (newStreak - 1) >= milestone.days && lastCelebrated < milestone.days
        }
        
        // Trigger celebrations for new milestones
        for milestone in newlyCompleted {
            triggerCelebration(for: milestone.days)
        }
        
        lastCelebrated = newStreak
    }
    
    private func triggerCelebration(for milestoneDay: Int) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Start visual celebration
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            celebratingMilestones.insert(milestoneDay)
        }
        
        // Major milestone celebrations are now handled globally by DayCounterViewModel
        
        // Auto-remove celebration after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                _ = celebratingMilestones.remove(milestoneDay)
            }
        }
    }
    
    private func isMajorMilestone(_ days: Int) -> Bool {
        // Define which milestones get the full celebration treatment
        let majorMilestones = [7, 14, 30, 60, 90, 180, 365, 730, 1095]
        return majorMilestones.contains(days)
    }
}

#Preview {
    VStack {
        MilestoneProgressView(currentStreak: 6)
        MilestoneProgressView(currentStreak: 0)
        MilestoneProgressView(currentStreak: 35)
    }
    .padding()
} 
