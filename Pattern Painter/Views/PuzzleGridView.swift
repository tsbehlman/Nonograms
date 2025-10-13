//
//  PuzzleGridView.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI
import simd

private let minTileDistanceForAxisChange: CGFloat = 0.75

struct DraggablePuzzleTilesView: View {
    enum DragState: Equatable {
        case inactive
        case dragging(row: Int, column: Int, state: TileState, axis: Axis?)

        func positions(since last: DragState) -> any Sequence<(Int, Int)> {
            guard case let .dragging(nextRow, nextColumn, _, axis) = self else { return [] }
            guard case let .dragging(lastRow, lastColumn, _, _) = last, let axis else { return [(nextRow, nextColumn)] }
            if axis == .horizontal {
                return (min(lastColumn, nextColumn)...max(lastColumn, nextColumn)).lazy.map { (nextRow, $0) }
            } else {
                return (min(lastRow, nextRow)...max(lastRow, nextRow)).lazy.map { ($0, nextColumn) }
            }
        }
    }

    @GestureState private var dragState: DragState = .inactive
    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    func location(at point: CGPoint) -> (Int, Int) {
        let row = clamp(Int(point.y / puzzleMetrics.tileSize), min: 0, max: gameState.puzzle.height - 1)
        let column = clamp(Int(point.x / puzzleMetrics.tileSize), min: 0, max: gameState.puzzle.width - 1)
        return (row, column)
    }

    func updateDragGesture(_ value: DragGesture.Value, _ state: inout DragState, _ transaction: inout Transaction) {
        guard var tileState = gameState.mode.tileState else { return }
        var (row, column) = location(at: value.location)
        var axis: Axis?
        if case let .dragging(lastRow, lastColumn, currentState, lastAxis) = state {
            tileState = currentState
            let lastPosition = Vec2(lastColumn, lastRow) + 0.5
            let distance = abs(Vec2(value.location) / puzzleMetrics.tileSize - lastPosition)
            if lastAxis == .vertical && distance.x < minTileDistanceForAxisChange {
                column = lastColumn
            } else if lastAxis == .horizontal && distance.y < minTileDistanceForAxisChange {
                row = lastRow
            }
            if row != lastRow && column == lastColumn {
                axis = .vertical
            } else if row == lastRow && column != lastColumn {
                axis = .horizontal
            } else if row == lastRow && column == lastColumn {
                axis = lastAxis
            } else {
                axis = nil
            }
        } else if gameState.puzzle.tile(row: row, column: column) == tileState {
            tileState = .blank
        }
        state = .dragging(row: row, column: column, state: tileState, axis: axis)
    }

    func onDragStateChange(_ oldState: DragState, _ newState: DragState) {
        guard case let .dragging(_, _, state, _) = newState else {
            gameState.endTransaction()
            return
        }
        gameState.beginTransaction()

        for (row, column) in newState.positions(since: oldState) {
            gameState.fill(row: row, column: column, state: state)
        }
    }

    var body: some View {
        let gesture = DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .updating($dragState, body: updateDragGesture)
        PuzzleTilesView()
            .contentShape(Rectangle())
            .highPriorityGesture(gesture, isEnabled: gameState.mode.tileState != nil)
            .onChange(of: dragState, onDragStateChange)
            .onTapGesture { point in
                let (row, column) = location(at: point)
                gameState.fill(row: row, column: column, state: nil)
            }
    }
}

struct PuzzleTilesView: View {
    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    var body: some View {
        let puzzle = gameState.puzzle
        let size = puzzleMetrics.puzzleSize
        ZStack {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(puzzle.rowIndices, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(puzzle.columnIndices, id: \.self) { columnIndex in
                            TileView(status: puzzle.tile(row: rowIndex, column: columnIndex), row: rowIndex, column: columnIndex, rippleTimer: gameState.isSolved ? rippleAnimationDuration : 0.0)
                        }
                    }
                }
            }
            .animation(.easeOut(duration: rippleAnimationDuration), value: gameState.isSolved)

            Path { path in
                for x in stride(from: 0, through: size.width, by: puzzleMetrics.tileSize) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: puzzleMetrics.tileSize) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
                .stroke(Color.primary.opacity(0.25), lineWidth: 1, antialiased: false)

            Path { path in
                for x in stride(from: 0, through: size.width, by: puzzleMetrics.majorTileSize) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: puzzleMetrics.majorTileSize) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
                .stroke(Color.primary.opacity(1), style: StrokeStyle(lineWidth: 1, lineCap: .square), antialiased: false)
        }
    }
}

struct PuzzleGridView: View {
    @Binding var fitsView: Bool
    @State var offset: CGPoint = .zero

    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    var body: some View {
        ZStack {
            PannableView(scrollEnabled: gameState.mode.tileState == nil, fitsView: $fitsView, offset: $offset) {
                VStack(spacing: 0) {
                    SegmentsBackground(axis: .horizontal, offset: offset, segmentSize: puzzleMetrics.segmentSize.height)
                        .frame(width: puzzleMetrics.puzzleSize.width, height: puzzleMetrics.segmentSize.height, alignment: .bottom)
                        .padding(.leading, puzzleMetrics.segmentSize.width)
                        .allowsHitTesting(false)
                    HStack(spacing: 0) {
                        SegmentsBackground(axis: .vertical, offset: offset, segmentSize: puzzleMetrics.segmentSize.width)
                            .frame(width: puzzleMetrics.segmentSize.width, height: puzzleMetrics.puzzleSize.height, alignment: .trailing)
                            .allowsHitTesting(false)
                        ZStack(alignment: .topLeading) {
                            DraggablePuzzleTilesView()
                            if let hint = gameState.hint {
                                HintOverlayView(hint: hint)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
                .padding([.trailing, .bottom], puzzleMetrics.puzzlePadding)
            }
            GeometryReader { _ in
                VStack(spacing: 0) {
                    SegmentsView(axis: .horizontal, offset: offset)
                        .padding(.leading, puzzleMetrics.segmentSize.width)
                    HStack(alignment: .top, spacing: 0) {
                        SegmentsView(axis: .vertical, offset: offset)
                        Spacer()
                            .frame(width: puzzleMetrics.puzzleSize.width, height: puzzleMetrics.puzzleSize.height)
                    }
                        .padding(.bottom, puzzleMetrics.puzzlePadding)
                        .clipped()
                }
                    .padding(.trailing, puzzleMetrics.puzzlePadding)
            }
                .allowsHitTesting(false)
        }
            .frame(maxWidth: puzzleMetrics.totalSize.width, maxHeight: puzzleMetrics.totalSize.height)
            .clipped()
    }
}

#Preview {
    @Previewable @State var gameState = GameState().newGame(width: 5, height: 5, difficulty: .easy)
    @Previewable @State var fitsView: Bool = false

    PuzzleGridView(fitsView: $fitsView)
        .environment(\.gameState, gameState)
        .onAppear {
            gameState.puzzle.solve()
        }
}
