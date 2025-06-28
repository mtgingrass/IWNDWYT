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