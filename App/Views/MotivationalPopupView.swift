import SwiftUI
import UIKit

struct MotivationalPopupView: View {
    @Binding var isPresented: Bool
    let message: String
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissPopup()
                }
            
            // Popup content
            VStack(spacing: 20) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: dismissPopup) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                // Motivational icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
                
                // Message
                Text(message)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                // Dismiss button
                Button("Got it!") {
                    dismissPopup()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
                .padding(.top, 10)
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.3), value: isPresented)
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