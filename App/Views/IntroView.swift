//
//  IntroView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/27/25.
//

import SwiftUI

struct IntroView: View {
    @Binding var hasSeenIntro: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(NSLocalizedString("intro_title", comment: "Intro view title"))
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(NSLocalizedString("intro_description", comment: "Intro view description"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                hasSeenIntro = true
            }) {
                Text(NSLocalizedString("btn_get_started", comment: "Get started button"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    // Use a temporary state so the preview works
    StatefulPreviewWrapper(false) { hasSeenIntro in
        IntroView(hasSeenIntro: hasSeenIntro)
            .preferredColorScheme(.light)
    }
}
