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

            Text("Start with just One Day")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("""
            Get through just today. That’s all.

            This app will count down the hours until midnight. Then do it again tomorrow.

            There are milestones. Sure.
            But they come one day at a time.

            This app doesn’t track ten different habits.
            It tracks just one. The one that matters most.

            Start now.
            """)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                hasSeenIntro = true
            }) {
                Text("Get Started")
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
