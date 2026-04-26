//
//  PuzzleSolveView.swift
//  Pattern Painter
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
        VStack(spacing: 0) {
            Spacer()
            Spacer()
            VStack(alignment: .center) {
                PuzzleMetricsProvider {
                    PuzzleGridView(fitsView: $fitsView)
                }
            }
                .frame(maxWidth: .infinity)
            ControlView(gameState: $gameState, fitsView: fitsView, showSettings: $showSettings, showNewGame: $showNewGame)
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .frame(maxWidth: 512)
                .background(LinearGradient(colors: [
                    Color(UIColor.systemBackground.withAlphaComponent(0)),
                    Color(UIColor.systemBackground),
                ], startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 0.0625)))
            Spacer()
                .background(Color(UIColor.systemBackground).containerRelativeFrame(.horizontal))
        }
            .ignoresSafeArea(.all)
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
