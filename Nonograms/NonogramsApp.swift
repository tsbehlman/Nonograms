//
//  NonogramsApp.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

struct NonogramsApp: App {
    var body: some Scene {
        WindowGroup {
            NonogramsAppView()
        }
    }
}

struct NonogramsAppView: View {
    @SceneStorage("PuzzleSolveView.persistedGameState") var gameState: GameState?

    @AppStorage("difficulty") var difficulty = NonogramsDefaults.difficulty
    @AppStorage("validate") var validate = NonogramsDefaults.validate
    @AppStorage("autofill") var autofill = NonogramsDefaults.autofill
    @AppStorage("puzzleWidth") var puzzleWidth = NonogramsDefaults.puzzleWidth
    @AppStorage("puzzleHeight") var puzzleHeight = NonogramsDefaults.puzzleHeight

    var body: some View {
        if let unwrapped = Binding($gameState) {
            PuzzleSolveView(gameState: unwrapped)
        } else {
            Color.clear.task {
                self.gameState = GameState().newGame(width: puzzleWidth, height: puzzleHeight, difficulty: difficulty, validate: validate, autofill: autofill)
            }
        }
    }
}

@main
struct NonogramsMain {
    static func main() {
#if DEBUG
        guard !(BuildChecker.areTestsRunning() || BuildChecker.arePreviewsRunning()) else {
            return TestApp.main()
        }
#endif
        NonogramsApp.main()
    }
}

#if DEBUG
struct TestApp: App {
    var body: some Scene {
        WindowGroup {}
    }
}
#endif
