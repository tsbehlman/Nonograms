//
//  EnvironmentValues.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 7/8/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var gameState = GameState()
    @Entry var puzzleMetrics = PuzzleMetrics(
        width: 5,
        height: 5,
        tileSize: AppDefaults.tileSize
    )
}
