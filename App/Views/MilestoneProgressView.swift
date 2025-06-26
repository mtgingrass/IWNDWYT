import SwiftUI

struct MilestoneProgressView: View {
    let currentStreak: Int
    
    private let milestones = [
        // Row 1 - Early Wins
        Milestone(days: 1, title: "Day 1", emoji: "🌱"),
        Milestone(days: 2, title: "2 Days", emoji: "🍀"),
        Milestone(days: 5, title: "5 Days", emoji: "⭐️"),
        Milestone(days: 7, title: "1 Week", emoji: "🌟"),
        // Row 2 - Building Momentum
        Milestone(days: 14, title: "2 Weeks", emoji: "🎯"),
        Milestone(days: 30, title: "1 Month", emoji: "🏆"),
        Milestone(days: 60, title: "2 Months", emoji: "💫"),
        Milestone(days: 90, title: "3 Months", emoji: "🌙"),
        // Row 3 - Major Achievements
        Milestone(days: 180, title: "6 Months", emoji: "🌞"),
        Milestone(days: 365, title: "1 Year", emoji: "👑"),
        Milestone(days: 730, title: "2 Years", emoji: "🎊"),
        Milestone(days: 1095, title: "3 Years", emoji: "⚡️")
    ]
    
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
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: min(CGFloat(currentStreak) / CGFloat(milestone.days), 1.0))
                            .stroke(
                                currentStreak >= milestone.days ? Color.green : Color.green.opacity(0.5),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        // Center content
                        VStack(spacing: 2) {
                            Text(milestone.emoji)
                                .font(.title2)
                                .opacity(currentStreak >= milestone.days ? 1 : 0.3)
                            
                            if currentStreak < milestone.days {
                                Text("\(currentStreak)/\(milestone.days)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(width: 55, height: 55)
                    
                    Text(milestone.title)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(height: 28)
                }
                .animation(.spring(response: 0.3), value: currentStreak)
            }
            //Spacer()  // Center the items if row is not full
        }
    }
}
        .padding(.horizontal)
    }
}

struct Milestone: Identifiable {
    let id = UUID()
    let days: Int
    let title: String
    let emoji: String
}

#Preview {
    VStack {
        MilestoneProgressView(currentStreak: 6)
        MilestoneProgressView(currentStreak: 0)
        MilestoneProgressView(currentStreak: 35)
    }
    .padding()
} 
