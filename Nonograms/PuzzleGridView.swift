//
//  PuzzleGridView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

private let tileSize: CGFloat = 42
private let majorTileSize = tileSize * 5
private let segmentFontSize = tileSize / 2
private let segmentFont = Font.system(size: segmentFontSize, weight: .bold, design: .monospaced)
private let segmentPadding = segmentFontSize / 3

struct SegmentLabel: View {
    let segment: Segment

    @Environment(\.puzzleColor) var puzzleColor: Color

    var body: some View {
        Text("\(segment.range.length)")
            .font(segmentFont)
            .foregroundStyle(segment.state == .complete ? puzzleColor : Color.primary)
            .stroke(.white, width: 0.625)
    }
}

struct SegmentLabels: View {
    let puzzle: Puzzle
    let axis: Axis
    let index: Int
    let size: CGFloat

    var segments: [Segment] {
        axis == .horizontal
            ? puzzle.segments(forRow: index)
            : puzzle.segments(forColumn: index)
    }

    var body: some View {
        Stack(axis, spacing: 0) {
            Spacer()
            ForEach(segments) { segment in
                SegmentLabel(segment: segment)
                    .frame(minWidth: segmentFontSize, minHeight: segmentFontSize, maxHeight: segmentFontSize, alignment: .center)
            }
        }
        .frame(
            width: axis == .horizontal ? size : tileSize,
            height: axis == .horizontal ? tileSize : size,
            alignment: axis == .horizontal ? .trailing : .bottom
        )
        .padding(axis == .horizontal ? .trailing : .bottom, segmentPadding)
    }
}

struct SegmentsView: View {
    let axis: Axis
    let puzzle: Puzzle
    let offset: CGPoint
    let labelSize: CGFloat
    let segmentSize: CGFloat
    let puzzleSize: CGFloat

    @Environment(\.puzzleColor) var puzzleColor: Color

    var body: some View {
        let axisOffset = axis == .horizontal ? offset.y : offset.x
        let opacity = 0.5 + 0.5 * max(0, min(1.0 - axisOffset / segmentSize, 1))
        let segmentGradient = Gradient(stops: [
            .init(color: puzzleColor.opacity(0.000 * opacity), location: 0.0),
            .init(color: puzzleColor.opacity(0.125 * opacity), location: 0.375),
            .init(color: puzzleColor.opacity(0.250 * opacity), location: 1.0),
        ])

        EqualStack(
            axis: axis,
            itemWidth: axis == .horizontal ? .fixed(tileSize) : .flexible,
            itemHeight: axis == .horizontal ? .flexible : .fixed(tileSize)
        ) {
            ForEach(0..<puzzle.size, id: \.self) { index in
                ZStack {
                    if index.isMultiple(of: 2) {
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: segmentGradient,
                                startPoint: axis == .horizontal ? .top : .leading,
                                endPoint: axis == .horizontal ? .bottom : .trailing
                            ))
                    }
                    SegmentLabels(puzzle: puzzle, axis: axis.opposing, index: index, size: labelSize)
                }
            }
        }
    }
}

struct TileView: View {
    let status: TileState

    @Environment(\.puzzleColor) var puzzleColor: Color

    var body: some View {
        Group {
            if status == .blocked {
                Image(systemName: "xmark")
                    .font(.system(size: tileSize * 0.75, weight: .light))
                    .foregroundStyle(Color.secondary)
            } else {
                Rectangle()
                    .fill(status == .filled ? puzzleColor : Color(UIColor.systemBackground))
            }
        }
            .frame(width: tileSize, height: tileSize, alignment: .center)
    }
}

struct DraggablePuzzleTilesView: View {
    @Binding var puzzle: Puzzle
    @Binding var mode: InteractionMode
    let fill: (Int, Int, TileState?) -> Void

    enum DragState: Equatable {
        case inactive
        case dragging(row: Int, column: Int, state: TileState)
    }

    @GestureState private var dragState: DragState = .inactive

    var body: some View {
        let gesture = DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .updating($dragState) { value, state, transaction in
                guard var tileState = mode.tileState else { return }
                let row = clamp(Int(value.location.y / tileSize), min: 0, max: puzzle.size - 1)
                let column = clamp(Int(value.location.x / tileSize), min: 0, max: puzzle.size - 1)
                if case let .dragging(_, _, currentState) = state {
                    tileState = currentState
                } else if puzzle.tile(row: row, column: column) == mode.tileState {
                    tileState = .blank
                }
                state = .dragging(row: row, column: column, state: tileState)
            }
        PuzzleTilesView(puzzle: $puzzle, fill: fill)
            .highPriorityGesture(gesture, isEnabled: mode.tileState != nil)
            .onChange(of: dragState) {
                guard case let .dragging(row, column, state) = dragState,
                      puzzle.rowIndices.contains(row),
                      puzzle.columnIndices.contains(column) else { return }
                fill(row, column, state)
            }
    }
}

struct PuzzleTilesView: View {
    @Binding var puzzle: Puzzle
    let fill: (Int, Int, TileState?) -> Void

    var body: some View {
        ZStack {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<puzzle.size, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(0..<puzzle.size, id: \.self) { columnIndex in
                            TileView(status: puzzle.tile(row: rowIndex, column: columnIndex))
                                .onTapGesture {
                                    fill(rowIndex, columnIndex, nil)
                                }
                        }
                    }
                }
            }

            Path { path in
                let edge = CGFloat(puzzle.size) * tileSize
                for x in stride(from: 0, through: edge, by: tileSize) {
                    path.move(to: CGPointMake(x, 0))
                    path.addLine(to: CGPointMake(x, edge))
                }
                for y in stride(from: 0, through: edge, by: tileSize) {
                    path.move(to: CGPointMake(0, y))
                    path.addLine(to: CGPointMake(edge, y))
                }
            }
                .stroke(Color.primary.opacity(0.25), lineWidth: 1, antialiased: false)

            Path { path in
                let edge = CGFloat(puzzle.size) * tileSize
                for x in stride(from: 0, through: edge, by: majorTileSize) {
                    path.move(to: CGPointMake(x, 0))
                    path.addLine(to: CGPointMake(x, edge))
                }
                for y in stride(from: 0, through: edge, by: majorTileSize) {
                    path.move(to: CGPointMake(0, y))
                    path.addLine(to: CGPointMake(edge, y))
                }
            }
            .stroke(Color.primary.opacity(1), style: StrokeStyle(lineWidth: 1, lineCap: .square), antialiased: false)
        }
    }
}

struct PuzzleGridView: View {
    @Binding var puzzle: Puzzle
    @Binding var mode: InteractionMode
    @Binding var fitsView: Bool
    @Binding var offset: CGPoint
    let fill: (Int, Int, TileState?) -> Void

    var body: some View {
        let maxSegments = (puzzle.size + 1) / 2
        let labelSize = segmentFontSize * CGFloat(maxSegments)
        let segmentSize = labelSize + segmentPadding
        let puzzleSize = tileSize * CGFloat(puzzle.size)

        ZStack {
            PannableView(scrollEnabled: mode.tileState == nil, fitsView: $fitsView, offset: $offset) {
                DraggablePuzzleTilesView(puzzle: $puzzle, mode: $mode, fill: fill)
                    .padding([.leading, .top], segmentSize)
            }
                .frame(maxWidth: puzzleSize + segmentSize, maxHeight: puzzleSize + segmentSize)
            VStack(spacing: 0) {
                OffsetView(axis: .horizontal, offset: offset) {
                    SegmentsView(axis: .horizontal, puzzle: puzzle, offset: offset, labelSize: labelSize, segmentSize: segmentSize, puzzleSize: puzzleSize)
                        .padding(.leading, segmentSize)
                }
                    .frame(maxWidth: puzzleSize + segmentSize, maxHeight: segmentSize)
                HStack(alignment: .top, spacing: 0) {
                    OffsetView(axis: .vertical, offset: offset) {
                        SegmentsView(axis: .vertical, puzzle: puzzle, offset: offset, labelSize: labelSize, segmentSize: segmentSize, puzzleSize: puzzleSize)
                    }
                        .frame(maxWidth: segmentSize, maxHeight: puzzleSize)
                    Spacer()
                        .frame(maxWidth: puzzleSize, maxHeight: puzzleSize)
                }
            }
                .allowsHitTesting(false)
        }
            .padding(1)
            .clipped()
    }
}

#Preview {
    @Previewable @State var puzzle = Puzzle(size: 5, data:
                                   0b11111,
                                   0b10001,
                                   0b10101,
                                   0b10001,
                                   0b11111
    )
    @Previewable @State var mode: InteractionMode = .fill(.filled)
    @Previewable @State var fitsView: Bool = false
    @Previewable @State var offset: CGPoint = .zero

    PuzzleGridView(puzzle: $puzzle, mode: $mode, fitsView: $fitsView, offset: $offset) { row, column, state in
        puzzle.set(row: row, column: column, to: state ?? mode.tileState!, holding: state != nil)
    }
        .onAppear {
            puzzle.solve()
        }
}
