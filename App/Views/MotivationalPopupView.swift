import SwiftUI
import UIKit

struct MotivationalPopupView: View {
    @Binding var isPresented: Bool
    let message: String
    
    var body: some View {
        ZStack {
            // Background overlay with blur effect
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture {
                    dismissPopup()
                }
            
            // Popup content
            VStack(spacing: 0) {
                // Gradient header with close button
                ZStack {
                    // Gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    HStack {
                        Spacer()
                        Button(action: dismissPopup) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Motivational icon with glow effect
                    VStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                        
                        Text("IWNDWYT")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(2)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 24)
                }
                .frame(height: 140)
                
                // Message content
                VStack(spacing: 24) {
                    Text(message)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    // Dismiss button with modern styling
                    Button(action: dismissPopup) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                            Text("I've got this")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPresented)
                }
                .padding(.bottom, 32)
                .background(Color(.systemBackground))
            }
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 10)
            .padding(.horizontal, 32)
            .scaleEffect(isPresented ? 1.0 : 0.8)
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.8)).combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .scale(scale: 0.9))
        ))
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isPresented)
    }
    
    private func dismissPopup() {
        // Clear the app badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        withAnimation {
            isPresented = false
        }
    }
}

#Preview {
    MotivationalPopupView(
        isPresented: .constant(true),
        message: "Today's a good day to begin again."
    )
} 