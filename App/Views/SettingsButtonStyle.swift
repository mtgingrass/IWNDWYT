import SwiftUI

struct SettingsButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 44, height: 44) // Standard iOS touch target size
            .contentShape(Rectangle()) // Makes entire frame tappable
    }
}

extension View {
    func settingsButtonStyle() -> some View {
        modifier(SettingsButtonStyle())
    }
}

#Preview {
    HStack(spacing: 20) {
        Button("Regular") { }
        
        Button {
            // Action
        } label: {
            Image(systemName: "gear")
        }
        .settingsButtonStyle()
        
        Button {
            // Action
        } label: {
            Image(systemName: "plus")
        }
        .settingsButtonStyle()
    }
    .padding()
} 