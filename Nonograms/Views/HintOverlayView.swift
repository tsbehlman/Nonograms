//
//  HintOverlayView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/5/25.
//

import SwiftUI

private let hintOutlineWidth: CGFloat = 1.5
private let hintStrokeWidth: CGFloat = 2.5 + hintOutlineWidth
private let hintInset: CGFloat = -4
private let hintCornerRadius: CGFloat = 4

struct HintOutlineView: View {
    let hint: SolverAttempt
    let minRange: Range<Int>
    let maxRange: Range<Int>

    @State var isAnimating = false

    @Environment(\.puzzleMetrics) var puzzleMetrics

    var destination: CGSize {
        let travelDistance = CGFloat(maxRange.lowerBound - minRange.lowerBound) * puzzleMetrics.tileSize
        if (hint.isRow) {
            return CGSize(width: travelDistance, height: 0)
        } else {
            return CGSize(width: 0, height: travelDistance)
        }
    }

    var rect: CGRect {
        let crossAxisPosition = CGFloat(hint.index) * puzzleMetrics.tileSize
        let position = CGFloat(minRange.lowerBound) * puzzleMetrics.tileSize
        let size = CGFloat(minRange.length) * puzzleMetrics.tileSize
        let rect = hint.isRow
            ? CGRect(x: position, y: crossAxisPosition, width: size, height: puzzleMetrics.tileSize)
            : CGRect(x: crossAxisPosition, y: position, width: puzzleMetrics.tileSize, height: size)
        return rect.insetBy(dx: hintInset, dy: hintInset)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: hintCornerRadius)
            .path(in: rect)
            .strokedPath(StrokeStyle(lineWidth: hintStrokeWidth))
            .fill(Color.yellow)
            .stroke(Color.white, style: StrokeStyle(lineWidth: hintOutlineWidth, lineJoin: .round))
            .offset(isAnimating ? destination : .zero)
            .animation(
                .easeInOut(duration: 1).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct HintTileView: View {
    let hint: SolverAttempt
    let stateIndex: Int

    @State var isAnimating = false

    @Environment(\.puzzleMetrics) var puzzleMetrics

    var offset: CGSize {
        let position = CGFloat(stateIndex) * puzzleMetrics.tileSize
        let crossAxisPosition = CGFloat(hint.index) * puzzleMetrics.tileSize
        if (hint.isRow) {
            return CGSize(width: position, height: crossAxisPosition)
        } else {
            return CGSize(width: crossAxisPosition, height: position)
        }
    }

    var body: some View {
        Image(systemName: hint.newStates[stateIndex] == .blocked ? "xmark" : "square.fill")
            .font(.system(size: puzzleMetrics.tileSize * 0.75, weight: .light))
            .foregroundStyle(Color.yellow)
            .frame(width: puzzleMetrics.tileSize, height: puzzleMetrics.tileSize)
            .offset(offset)
            .opacity(isAnimating ? 1 : 0)
            .animation(
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct HintOverlayView: View {
    let hint: SolverAttempt

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(hint.minRanges.indices, id: \.self) { rangeIndex in
                HintOutlineView(hint: hint, minRange: hint.minRanges[rangeIndex], maxRange: hint.maxRanges[rangeIndex])
            }
            ForEach(hint.newStates.indices, id: \.self) { stateIndex in
                if hint.newStates[stateIndex] != hint.oldStates[stateIndex] {
                    HintTileView(hint: hint, stateIndex: stateIndex)
                }
            }
        }
    }
}
