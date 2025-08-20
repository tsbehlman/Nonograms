//
//  PuzzleSolveView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

struct PuzzleSolveView: View {
    @State var gameState = GameState()
    @State var fitsView: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Spacer()
            PuzzleMetricsProvider {
                PuzzleGridView(fitsView: $fitsView)
            }
            ControlView(gameState: $gameState, fitsView: fitsView)
                .padding(.horizontal, 16)
            Spacer()
        }
            .environment(\.gameState, gameState)
    }
}

#Preview {
    PuzzleSolveView()
}
