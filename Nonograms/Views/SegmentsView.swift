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
    @Environment(\.puzzleColor) var puzzleColor
    @Environment(\.puzzleMetrics) var puzzleMetrics

    var color: Color {
        if isHighlighted {
            Color.yellow.mix(with: Color.orange, by: 0.25)
        } else if segment.state == .complete {
            puzzleColor
        } else {
            Color.primary
        }
    }

    var body: some View {
        Text("\(segment.range.length)")
            .font(puzzleMetrics.segmentFont)
            .foregroundStyle(color)
            .stroke(Color.primary.forScheme(colorScheme.inverted), width: 0.625)
    }
}

struct SegmentLabels: View {
    let puzzle: Puzzle
    let axis: Axis
    let index: Int
    let size: CGFloat
    let offset: CGPoint
    let isHighlighted: Bool

    @Environment(\.puzzleMetrics) var puzzleMetrics

    var segments: [Segment] {
        axis == .horizontal
            ? puzzle.segments(forRow: index)
            : puzzle.segments(forColumn: index)
    }

    var spacing: CGFloat {
        if axis == .horizontal {
            puzzleMetrics.segmentFontSize / 3
        } else {
            0
        }
    }

    var body: some View {
        SqueezeStack(axis, reversed: true, offset: axis == .horizontal ? offset.x : offset.y, spacing: spacing) {
            ForEach(segments) { segment in
                SegmentLabel(segment: segment, isHighlighted: isHighlighted)
                    .frame(minHeight: puzzleMetrics.segmentFontSize, maxHeight: puzzleMetrics.segmentFontSize, alignment: .center)
            }
        }
        .frame(
            width: axis == .horizontal ? size : puzzleMetrics.tileSize,
            height: axis == .horizontal ? puzzleMetrics.tileSize : size,
            alignment: axis == .horizontal ? .trailing : .bottom
        )
        .padding(axis == .horizontal ? .horizontal : .vertical, puzzleMetrics.segmentPadding)
    }
}

struct SegmentsView: View {
    let axis: Axis
    let puzzle: Puzzle
    let offset: CGPoint
    let labelSize: CGFloat
    let segmentSize: CGFloat
    let puzzleSize: CGFloat
    let hint: SolverAttempt?

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.puzzleColor) var puzzleColor
    @Environment(\.puzzleMetrics) var puzzleMetrics

    func makeGradient(axisOffset: CGFloat, overScroll: CGFloat) -> LinearGradient {
        let overscrollMultiplier = segmentSize / (segmentSize + overScroll)
        let opacity = colorScheme == .dark ? 1.0 : 0.5
        return LinearGradient(
            stops: [
                Gradient.Stop(color: puzzleColor.opacity(0.00 * opacity), location: 0.000),
                Gradient.Stop(color: puzzleColor.opacity(0.25 * opacity), location: 0.375),
                Gradient.Stop(color: puzzleColor.opacity(0.50 * opacity), location: 1.000),
            ],
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: axis == .horizontal
                ? UnitPoint(x: 0, y: overscrollMultiplier)
                : UnitPoint(x: overscrollMultiplier, y: 0)
        )
    }

    var body: some View {
        let axisOffset = axis == .horizontal ? offset.y : offset.x
        let overScroll = Swift.max(0.0, -axisOffset)

        ZStack {
            Rectangle()
                .fill(makeGradient(axisOffset: axisOffset, overScroll: overScroll))
                .mask {
                    Path { path in
                        for index in stride(from: 0, to: puzzle.size, by: 2) {
                            if axis == .horizontal {
                                path.addRect(CGRectMake(CGFloat(index) * puzzleMetrics.tileSize, 0, puzzleMetrics.tileSize, segmentSize - axisOffset))
                            } else {
                                path.addRect(CGRectMake(0, CGFloat(index) * puzzleMetrics.tileSize, segmentSize - axisOffset, puzzleMetrics.tileSize))
                            }
                        }
                    }
                }
            EqualStack(
                axis: axis,
                itemWidth: axis == .horizontal ? .fixed(puzzleMetrics.tileSize) : .flexible,
                itemHeight: axis == .horizontal ? .flexible : .fixed(puzzleMetrics.tileSize)
            ) {
                ForEach(0..<puzzle.size, id: \.self) { index in
                    SegmentLabels(puzzle: puzzle, axis: axis.opposing, index: index, size: labelSize, offset: offset, isHighlighted: hint?.axis == axis.opposing && hint?.index == index)
                }
            }
                .padding(axis == .horizontal ? .top : .leading, overScroll)
        }
    }
}
