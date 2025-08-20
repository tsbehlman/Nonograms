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
    let puzzleSize: CGSize
    let labelSize: CGSize
    let segmentSize: CGSize
    let totalSize: CGSize

    init(width: Int, height: Int, tileSize: CGFloat) {
        let size = max(width, height)
        let majorTileCount = [5, 4, 3, 2].first { size.isMultiple(of: $0) } ?? size
        self.tileSize = tileSize
        majorTileSize = tileSize * CGFloat(majorTileCount)
        segmentFontSize = tileSize / 2
        segmentFont = Font.system(size: segmentFontSize, weight: .bold, design: .monospaced)
        segmentPadding = segmentFontSize / 3
        puzzleSize = CGSize(width: CGFloat(width) * tileSize, height: CGFloat(height) * tileSize)
        labelSize = CGSize(
            width: CGFloat((width + 1) / 2) * segmentFontSize,
            height: CGFloat((height + 1) / 2) * segmentFontSize
        )
        segmentSize = CGSize(
            width: labelSize.width + segmentPadding * 2,
            height: labelSize.height + segmentPadding * 2
        )
        totalSize = CGSize(
            width: puzzleSize.width + segmentSize.width,
            height: puzzleSize.height + segmentSize.height
        )
    }
}

struct PuzzleMetricsProvider<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @Environment(\.gameState.puzzle.width) var puzzleWidth
    @Environment(\.gameState.puzzle.height) var puzzleHeight
    @AppStorage("tileSize") var tileSize = NonogramsDefaults.tileSize

    var body: some View {
        content()
            .environment(\.puzzleMetrics, PuzzleMetrics(
                width: puzzleWidth,
                height: puzzleHeight,
                tileSize: tileSize
            ))
    }
}
