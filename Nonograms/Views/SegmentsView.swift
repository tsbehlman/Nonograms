//
//  SegmentsView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/4/25.
//

import SwiftUI

struct SegmentLabel: View {
    let segment: Segment
    let isHighlighted: Bool

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.gameState) var gameState
    @Environment(\.puzzleMetrics.segmentFont) var segmentFont

    var color: Color {
        if isHighlighted {
            hintFillColor
        } else if segment.state == .complete {
            gameState.puzzleColor
        } else {
            Color.primary
        }
    }

    var body: some View {
        Text(verbatim: "\(segment.range.length)")
            .font(segmentFont)
            .foregroundStyle(color)
            .stroke(Color.primary.forScheme(colorScheme.inverted), width: 0.625)
    }
}

struct SegmentLabels: View {
    let segments: [Segment]
    let axis: Axis
    let index: Int
    let isHighlighted: Bool

    @Environment(\.puzzleMetrics.segmentFontSize) var segmentFontSize

    var spacing: CGFloat {
        if axis == .horizontal {
            segmentFontSize / 3
        } else {
            0
        }
    }

    var body: some View {
        Stack(axis: axis, spacing: spacing) {
            ForEach(segments) { segment in
                SegmentLabel(segment: segment, isHighlighted: isHighlighted)
                    .when(axis == .vertical) { $0.frame(maxHeight: segmentFontSize) }
            }
        }
    }
}

private struct StripedShape: Shape {
    let axis: Axis
    let size: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            for position in stride(from: 0, to: axis == .horizontal ? rect.width : rect.height, by: size * 2) {
                if axis == .horizontal {
                    path.addRect(CGRectMake(position, rect.minY, size, rect.height))
                } else {
                    path.addRect(CGRectMake(rect.minX, position, rect.width, size))
                }
            }
        }
    }
}

struct SegmentsBackground: View {
    let axis: Axis
    let offset: CGPoint
    let segmentSize: CGFloat

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.gameState) var gameState
    @Environment(\.puzzleMetrics.tileSize) var tileSize
    @Environment(\.puzzleMetrics.puzzleSize) var puzzleSize

    func makeGradient(axisOffset: CGFloat) -> LinearGradient {
        let overscrollMultiplier = axisOffset / max(1, segmentSize - axisOffset)
        let endPoint: CGFloat = 1 + overscrollMultiplier
        let opacity = colorScheme == .dark ? 1.0 : 0.5
        return LinearGradient(
            stops: [
                Gradient.Stop(color: gameState.puzzleColor.opacity(0.00 * opacity), location: 0.000),
                Gradient.Stop(color: gameState.puzzleColor.opacity(0.25 * opacity), location: 0.375),
                Gradient.Stop(color: gameState.puzzleColor.opacity(0.50 * opacity), location: 1.000),
            ],
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: axis == .horizontal
                ? UnitPoint(x: 0, y: endPoint)
                : UnitPoint(x: endPoint, y: 0)
        )
    }

    var body: some View {
        let axisOffset = axis == .horizontal ? offset.y : offset.x
        let length = max(0.0, segmentSize - axisOffset)

        StripedShape(axis: axis, size: tileSize)
            .fill(makeGradient(axisOffset: axisOffset))
            .frame(
                width: axis == .horizontal ? puzzleSize.width : length,
                height: axis == .horizontal ? length : puzzleSize.height,
            )
            .drawingGroup()
    }
}

struct SegmentsView: View {
    let axis: Axis
    let offset: CGPoint

    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    var body: some View {
        let segmentAxis = axis.opposing
        let labelSize = segmentAxis == .horizontal
            ? puzzleMetrics.labelSize.width
            : puzzleMetrics.labelSize.height
        SegmentsLayout(
            axis: axis,
            inlineSize: puzzleMetrics.tileSize,
            blockSize: labelSize,
            offset: offset
        ) {
            ForEach(axis == .horizontal ? gameState.puzzle.columnIndices : gameState.puzzle.rowIndices, id: \.self) { index in
                let segments = segmentAxis == .horizontal
                    ? gameState.puzzle.segments(forRow: index)
                    : gameState.puzzle.segments(forColumn: index)
                let isHighlighted = gameState.hint?.axis == segmentAxis && gameState.hint?.index == index
                SegmentLabels(segments: segments, axis: segmentAxis, index: index, isHighlighted: isHighlighted)
            }
        }
            .padding(axis == .horizontal ? .vertical : .horizontal, puzzleMetrics.segmentPadding)
    }
}
