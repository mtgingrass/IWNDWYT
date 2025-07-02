import SwiftUI

struct MilestoneCelebrationView: View {
    @Binding var isPresented: Bool
    let milestone: Milestone
    let currentStreak: Int
    
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var showContent = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Animated background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture {
                    dismissCelebration()
                }
            
            // Confetti animation
            ForEach(confettiParticles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .animation(.easeOut(duration: particle.duration), value: particle.position)
            }
            
            // Main celebration content
            VStack(spacing: 0) {
                // Celebration header with gradient
                ZStack {
                    // Animated gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.9),
                            Color.blue.opacity(0.8),
                            Color.cyan.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .hueRotation(.degrees(pulseAnimation ? 30 : 0))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    VStack(spacing: 16) {
                        // Celebration text
                        Text("🎉 MILESTONE ACHIEVED! 🎉")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1.5)
                            .scaleEffect(showContent ? 1.0 : 0.5)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                        
                        // Giant milestone emoji with glow
                        Text(milestone.emoji)
                            .font(.system(size: 80, weight: .medium))
                            .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 0)
                            .shadow(color: .cyan.opacity(0.3), radius: 40, x: 0, y: 0)
                            .scaleEffect(showContent ? 1.0 : 0.3)
                            .rotationEffect(.degrees(showContent ? 0 : 180))
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4), value: showContent)
                        
                        // Milestone title
                        Text(milestone.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(showContent ? 1.0 : 0.5)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6), value: showContent)
                        
                        // Streak count with emphasis
                        Text("\\(currentStreak) DAYS STRONG!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                            .scaleEffect(showContent ? 1.0 : 0.5)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8), value: showContent)
                    }
                    .padding(.vertical, 32)
                }
                .frame(height: 280)
                
                // Motivational message section
                VStack(spacing: 24) {
                    Text(getMilestoneMessage())
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.0), value: showContent)
                    
                    // Celebration button
                    Button(action: dismissCelebration) {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Keep Going!")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue, .cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 6)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    }
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2), value: showContent)
                }
                .padding(.bottom, 40)
                .background(Color(.systemBackground))
            }
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.2), radius: 40, x: 0, y: 20)
            .padding(.horizontal, 24)
            .scaleEffect(isPresented ? 1.0 : 0.7)
            .opacity(isPresented ? 1 : 0)
        }
        .onAppear {
            startCelebration()
        }
    }
    
    private func startCelebration() {
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Start animations
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showContent = true
            pulseAnimation = true
        }
        
        // Create confetti particles
        createConfetti()
        
        // Auto-dismiss after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            dismissCelebration()
        }
    }
    
    private func createConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        
        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 4...12),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -20
                ),
                opacity: 1.0,
                scale: 1.0,
                duration: Double.random(in: 2...4)
            )
            confettiParticles.append(particle)
            
            // Animate particle falling
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.easeOut(duration: particle.duration)) {
                    if let index = confettiParticles.firstIndex(where: { $0.id == particle.id }) {
                        confettiParticles[index].position.y = UIScreen.main.bounds.height + 50
                        confettiParticles[index].opacity = 0
                        confettiParticles[index].scale = 0.5
                    }
                }
            }
        }
    }
    
    private func dismissCelebration() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
    
    private func getMilestoneMessage() -> String {
        switch milestone.days {
        case 1:
            return "Every journey begins with a single step. You've taken yours!"
        case 2:
            return "Two days of strength. You're building something amazing!"
        case 5:
            return "Five days of commitment. Your determination is inspiring!"
        case 7:
            return "One week of sobriety! You've proven you can do this!"
        case 14:
            return "Two weeks strong! You're creating lasting change!"
        case 30:
            return "One month of transformation! Your strength is remarkable!"
        case 60:
            return "Two months of growth! You're becoming unstoppable!"
        case 90:
            return "Three months of dedication! You've built a new foundation!"
        case 180:
            return "Six months of triumph! You've changed your life!"
        case 365:
            return "One full year! You are a true inspiration!"
        case 730:
            return "Two years of excellence! You've mastered this journey!"
        case 1095:
            return "Three years of greatness! You are absolutely incredible!"
        default:
            return "Another milestone reached! Your journey continues to inspire!"
        }
    }
}

struct ConfettiParticle {
    let id: Int
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
    var scale: CGFloat
    let duration: Double
}

#Preview {
    MilestoneCelebrationView(
        isPresented: .constant(true),
        milestone: Milestone(days: 7, title: "1 Week", emoji: "🌟"),
        currentStreak: 7
    )
}