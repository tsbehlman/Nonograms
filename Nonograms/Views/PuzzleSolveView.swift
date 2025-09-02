//
//  PuzzleSolveView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

struct PuzzleSolveView: View {
    @Binding var gameState: GameState
    @State var fitsView: Bool = false
    @State var showSettings = false
    @State var showNewGame = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Spacer()
            PuzzleMetricsProvider {
                PuzzleGridView(fitsView: $fitsView)
            }
            ControlView(gameState: $gameState, fitsView: fitsView, showSettings: $showSettings, showNewGame: $showNewGame)
                .padding(.horizontal, 16)
                .frame(maxWidth: 512)
            Spacer()
        }
            .environment(\.gameState, gameState)
            .sheet(isPresented: $showSettings) {
                SettingsView(gameState: $gameState)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showNewGame) {
                NewGameSheetView(gameState: $gameState)
            }
    }
}

#Preview {
    @Previewable @State var gameState = GameState().newGame(width: 5, height: 5, difficulty: .medium, validate: false)
    PuzzleSolveView(gameState: $gameState)
}
