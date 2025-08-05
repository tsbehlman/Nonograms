//
//  PuzzleGridView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

struct TileView: View {
    let status: TileState

    @Environment(\.puzzleColor) var puzzleColor: Color
    @Environment(\.puzzleMetrics) var puzzleMetrics

    var body: some View {
        Group {
            if status.isBlocked {
                Image(systemName: "xmark")
                    .font(.system(size: puzzleMetrics.tileSize * 0.75, weight: .light))
                    .foregroundStyle(status == .error ? Color.red.opacity(0.75) : Color.secondary)
            } else {
                Rectangle()
                    .fill(status == .filled ? puzzleColor : Color(UIColor.systemBackground))
            }
        }
        .frame(width: puzzleMetrics.tileSize, height: puzzleMetrics.tileSize, alignment: .center)
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
    @Environment(\.puzzleMetrics) var puzzleMetrics

    var body: some View {
        let gesture = DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .updating($dragState) { value, state, transaction in
                guard var tileState = mode.tileState else { return }
                let row = clamp(Int(value.location.y / puzzleMetrics.tileSize), min: 0, max: puzzle.size - 1)
                let column = clamp(Int(value.location.x / puzzleMetrics.tileSize), min: 0, max: puzzle.size - 1)
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

    @Environment(\.puzzleMetrics) var puzzleMetrics

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
                let edge = CGFloat(puzzle.size) * puzzleMetrics.tileSize
                for x in stride(from: 0, through: edge, by: puzzleMetrics.tileSize) {
                    path.move(to: CGPointMake(x, 0))
                    path.addLine(to: CGPointMake(x, edge))
                }
                for y in stride(from: 0, through: edge, by: puzzleMetrics.tileSize) {
                    path.move(to: CGPointMake(0, y))
                    path.addLine(to: CGPointMake(edge, y))
                }
            }
                .stroke(Color.primary.opacity(0.25), lineWidth: 1, antialiased: false)

            Path { path in
                let edge = CGFloat(puzzle.size) * puzzleMetrics.tileSize
                for x in stride(from: 0, through: edge, by: puzzleMetrics.majorTileSize) {
                    path.move(to: CGPointMake(x, 0))
                    path.addLine(to: CGPointMake(x, edge))
                }
                for y in stride(from: 0, through: edge, by: puzzleMetrics.majorTileSize) {
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
    let hint: SolverAttempt?
    let fill: (Int, Int, TileState?) -> Void

    @Environment(\.puzzleMetrics) var puzzleMetrics

    var body: some View {
        let maxSegments = (puzzle.size + 1) / 2
        let labelSize = puzzleMetrics.segmentFontSize * CGFloat(maxSegments)
        let segmentSize = labelSize + puzzleMetrics.segmentPadding * 2
        let puzzleSize = puzzleMetrics.tileSize * CGFloat(puzzle.size)

        ZStack {
            PannableView(scrollEnabled: mode.tileState == nil, fitsView: $fitsView, offset: $offset) {
                ZStack {
                    DraggablePuzzleTilesView(puzzle: $puzzle, mode: $mode, fill: fill)
                    if let hint = hint {
                        HintOverlayView(hint: hint)
                            .allowsHitTesting(false)
                    }
                }
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
                    .clipped()
            }
                .allowsHitTesting(false)
        }
            .padding(6)
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

    PuzzleGridView(puzzle: $puzzle, mode: $mode, fitsView: $fitsView, offset: $offset, hint: nil) { row, column, state in
        puzzle.set(row: row, column: column, to: state ?? mode.tileState!, holding: state != nil)
    }
        .onAppear {
            puzzle.solve()
        }
}
