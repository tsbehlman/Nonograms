//
//  PuzzleMetrics.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/4/25.
//

import SwiftUI

struct PuzzleMetrics {
    let tileSize: CGFloat
    let majorTileSize: CGFloat
    let segmentFontSize: CGFloat
    let segmentFont: Font
    let segmentPadding: CGFloat

    init(size: Int, tileSize: CGFloat) {
        let majorTileCount = [5, 4, 3, 2].first { size.isMultiple(of: $0) } ?? size
        self.tileSize = tileSize
        majorTileSize = tileSize * CGFloat(majorTileCount)
        segmentFontSize = tileSize / 2
        segmentFont = Font.system(size: segmentFontSize, weight: .bold, design: .monospaced)
        segmentPadding = segmentFontSize / 3
    }
}

struct PuzzleMetricsProvider<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @Environment(\.gameState.puzzle.size) var puzzleSize
    @AppStorage("tileSize") var tileSize = NonogramsDefaults.tileSize

    var body: some View {
        content()
            .environment(\.puzzleMetrics, PuzzleMetrics(
                size: puzzleSize,
                tileSize: tileSize
            ))
    }
}
