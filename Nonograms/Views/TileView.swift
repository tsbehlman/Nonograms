//
//  TileView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/19/25.
//

import SwiftUI

struct TileView: View {
    let status: TileState

    @Environment(\.gameState.puzzleColor) var puzzleColor
    @Environment(\.puzzleMetrics) var puzzleMetrics

    var body: some View {
        Group {
            if status == .filled {
                Rectangle()
                    .fill(puzzleColor)
                    .transition(.opacity.animation(.easeOut(duration: 8 / 60)).combined(with: .asymmetric(
                            insertion: .scale(scale: 1.5),
                            removal: .scale(scale: 0.5)
                        ).animation(.easeOut(duration: 10 / 60))
                    ))
            } else {
                let marked = status.isBlocked
                let trimValue = marked ? 1.0 : 0.0
                XMarkShape()
                    .trim(from: 0.0, to: trimValue)
                    .stroke(status == .error ? Color.red.opacity(0.75) : Color.secondary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .keyframeAnimation(trimValue) {
                        let half = marked ? 0.4999 : 0.5001
                        LinearKeyframe(half, duration: 4 / 60)
                        LinearKeyframe(half, duration: 3 / 60)
                        LinearKeyframe(1.0, duration: 4 / 60)
                    }
                    .frame(width: puzzleMetrics.tileSize * 0.5, height: puzzleMetrics.tileSize * 0.5)
            }
        }
            .frame(width: puzzleMetrics.tileSize, height: puzzleMetrics.tileSize, alignment: .center)
    }
}

#Preview {
    @Previewable @State var gameState = GameState()
    @Previewable @State var tiles: [TileState] = [.blank, .blank]

    VStack {
        ForEach(Array(tiles.enumerated()), id: \.0) { (_, status) in
            TileView(status: status)
                .border(Color.primary.opacity(0.25))
        }
    }
        .contentShape(Rectangle())
        .onTapGesture {
            if tiles.first == .blank {
                tiles = [.filled, .blocked]
            } else {
                tiles = [.blank, .blank]
            }
        }
}
