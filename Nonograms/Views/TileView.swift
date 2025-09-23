//
//  TileView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/19/25.
//

import SwiftUI

private let maximumDelay: TimeInterval = 48 / 60
private let contractDuration: TimeInterval = 6 / 60
private let expandDuration: TimeInterval = 6 / 60
let rippleAnimationDuration: TimeInterval = maximumDelay + contractDuration + expandDuration

struct TileView: View, Animatable {
    let status: TileState
    let row: Int
    let column: Int
    var rippleTimer: TimeInterval

    var animatableData: TimeInterval {
        get { rippleTimer }
        set { rippleTimer = newValue }
    }

    @Environment(\.gameState.isSolved) var isSolved
    @Environment(\.gameState.lastFilledTile) var lastFilledTile
    @Environment(\.gameState.puzzle.width) var puzzleWidth
    @Environment(\.gameState.puzzle.height) var puzzleHeight
    @Environment(\.puzzleMetrics) var puzzleMetrics

    var delay: TimeInterval {
        let (lastRow, lastColumn) = lastFilledTile ?? (row, column)
        let diagonal = hypot(Double(puzzleWidth), Double(puzzleHeight))
        let length = hypot(
            Double(lastRow - row),
            Double(lastColumn - column)
        ) / diagonal
        let distanceToCenter = hypot(
            Double(lastRow - puzzleWidth / 2),
            Double(lastColumn - puzzleHeight / 2)
        ) / diagonal * 2
        return min(1.0, length * (2.0 - distanceToCenter)) * maximumDelay
    }

    var scaleTimeline: KeyframeTimeline<CGFloat> {
        KeyframeTimeline(initialValue: 1.0) {
            KeyframeTrack {
                LinearKeyframe(1.0, duration: delay)
                CubicKeyframe(0.8, duration: contractDuration, startVelocity: 0.0, endVelocity: 0.0)
                CubicKeyframe(1.0, duration: expandDuration, startVelocity: 0.0, endVelocity: 0.0)
            }
        }
    }

    var colorTimeline: KeyframeTimeline<Double> {
        KeyframeTimeline(initialValue: 0.0) {
            KeyframeTrack {
                LinearKeyframe(0.0, duration: delay)
                LinearKeyframe(1.0, duration: contractDuration)
                LinearKeyframe(1.0, duration: expandDuration)
            }
        }
    }

    var body: some View {
        Group {
            if status == .filled {
                Rectangle()
                    .fill(
                        isSolved
                            ? GameState.unsolvedColor.mix(with: GameState.solvedColor, by: colorTimeline.value(time: rippleTimer))
                            : GameState.unsolvedColor
                    )
                    .transition(isSolved
                        ? .identity
                        : .opacity.animation(.easeOut(duration: 8 / 60).instant()).combined(with: .asymmetric(
                            insertion: .scale(scale: 1.5),
                            removal: .scale(scale: 0.5)
                        ).animation(.easeOut(duration: 10 / 60))
                    ))
                    .scaleEffect(
                        isSolved
                            ? scaleTimeline.value(time: rippleTimer)
                            : 1.0
                    )
            } else {
                let marked = status.isBlocked
                let trimValue = marked ? 1.0 : 0.0
                XMarkShape()
                    .trim(from: 0.0, to: trimValue)
                    .stroke(status == .error ? Color.red.opacity(0.75) : Color.secondary, style: puzzleMetrics.xmarkStrokeStyle)
                    .keyframeAnimation(trimValue) {
                        let half = marked ? 0.4999 : 0.5001
                        LinearKeyframe(half, duration: 4 / 60)
                        LinearKeyframe(half, duration: 3 / 60)
                        LinearKeyframe(1.0, duration: 4 / 60)
                    }
                    .frame(width: puzzleMetrics.tileSize * 0.45, height: puzzleMetrics.tileSize * 0.45)
            }
        }
            .frame(width: puzzleMetrics.tileSize, height: puzzleMetrics.tileSize, alignment: .center)
    }
}

#Preview {
    @Previewable @State var gameState = GameState()
    @Previewable @State var tiles: [TileState] = [.blank, .blank]

    VStack {
        ForEach(Array(tiles.enumerated()), id: \.0) { (index, status) in
            TileView(status: status, row: index, column: 0, rippleTimer: 0)
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
