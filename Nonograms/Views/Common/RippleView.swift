//
//  RippleView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/7/25.
//

import SwiftUI

struct RippleView: View {
    @State var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.accentColor)
            .animation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                $0
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0.0 : 0.625)
            }
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        ControlButton(icon: "questionmark")
            .background(RippleView())
    }
}
