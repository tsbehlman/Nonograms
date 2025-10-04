//
//  HintOverlayView.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 8/5/25.
//

import SwiftUI

private let hintCornerRadius: CGFloat = 4
let hintFillColor = Color.yellow.mix(with: Color.orange, by: 0.25)

struct HintOutlineView: View {
    let hint: SolverAttempt
    let minRange: Range<Int>
    let maxRange: Range<Int>

    @State var isAnimating = false

    @Environment(\.puzzleMetrics) var puzzleMetrics

    var destination: CGSize {
        let travelDistance = CGFloat(maxRange.lowerBound - minRange.lowerBound) * puzzleMetrics.tileSize
        if (hint.axis == .horizontal) {
            return CGSize(width: travelDistance, height: 0)
        } else {
            return CGSize(width: 0, height: travelDistance)
        }
    }

    var rect: CGRect {
        let crossAxisPosition = CGFloat(hint.index) * puzzleMetrics.tileSize
        let position = CGFloat(minRange.lowerBound) * puzzleMetrics.tileSize
        let size = CGFloat(minRange.length) * puzzleMetrics.tileSize
        let rect = hint.axis == .horizontal
            ? CGRect(x: position, y: crossAxisPosition, width: size, height: puzzleMetrics.tileSize)
            : CGRect(x: crossAxisPosition, y: position, width: puzzleMetrics.tileSize, height: size)
        return rect.insetBy(dx: puzzleMetrics.hintInset, dy: puzzleMetrics.hintInset)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: hintCornerRadius)
            .path(in: rect)
            .stroke(Color.white, style: StrokeStyle(lineWidth: puzzleMetrics.hintStrokeWidth))
            .stroke(Color.yellow, style: StrokeStyle(lineWidth: puzzleMetrics.hintOutlineWidth))
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

    @Environment(\.puzzleMetrics.tileSize) var tileSize

    var offset: CGSize {
        let position = CGFloat(stateIndex) * tileSize
        let crossAxisPosition = CGFloat(hint.index) * tileSize
        if (hint.axis == .horizontal) {
            return CGSize(width: position, height: crossAxisPosition)
        } else {
            return CGSize(width: crossAxisPosition, height: position)
        }
    }

    var body: some View {
        let isBlocked = hint.newStates[stateIndex] == .blocked
        Group {
            if isBlocked {
                BlockedTileIcon()
                    .padding(tileSize * 0.3125)
            } else {
                FilledTileIcon()
                    .padding(tileSize * 0.1875)
            }
        }
            .foregroundStyle(hintFillColor)
            .frame(width: tileSize, height: tileSize)
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

#Preview {
    VStack {
        HintTileView(hint: SolverAttempt(axis: .horizontal, index: 0, minRanges: [], maxRanges: [], oldStates: [.filled], newStates: [.filled]), stateIndex: 0)
            .border(Color.primary.opacity(0.25))
        HintTileView(hint: SolverAttempt(axis: .horizontal, index: 0, minRanges: [], maxRanges: [], oldStates: [.blocked], newStates: [.blocked]), stateIndex: 0)
            .border(Color.primary.opacity(0.25))
    }
}
