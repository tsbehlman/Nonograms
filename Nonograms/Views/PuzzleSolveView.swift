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
    @State var showSettings = false
    @State var showNewGame = false

    @AppStorage("difficulty") var difficulty = NonogramsDefaults.difficulty
    @AppStorage("validate") var validate = NonogramsDefaults.validate
    @AppStorage("puzzleWidth") var puzzleWidth = NonogramsDefaults.puzzleWidth
    @AppStorage("puzzleHeight") var puzzleHeight = NonogramsDefaults.puzzleHeight

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Spacer()
            PuzzleMetricsProvider {
                PuzzleGridView(fitsView: $fitsView)
            }
            ControlView(gameState: $gameState, fitsView: fitsView, showSettings: $showSettings, showNewGame: $showNewGame)
                .padding(.horizontal, 16)
            Spacer()
        }
            .environment(\.gameState, gameState)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showNewGame) {
                NewGameView(gameState: $gameState)
                    .presentationDetents([.medium])
            }
            .onAppear {
                gameState = gameState.newGame(width: puzzleWidth, height: puzzleHeight, difficulty: difficulty, validate: validate)
            }
    }
}

#Preview {
    PuzzleSolveView()
}
