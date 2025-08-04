//
//  EnvironmentValues.swift
//  Nonograms
//
//  Created by Trevor Behlman on 7/8/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var puzzleColor: Color = .accentColor
    @Entry var puzzleMetrics = PuzzleMetrics(
        size: 5,
        tileSize: NonogramsDefaults.tileSize
    )
}
