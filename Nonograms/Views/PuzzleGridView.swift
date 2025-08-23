//
//  PuzzleGridView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

struct DraggablePuzzleTilesView: View {
    enum DragState: Equatable {
        case inactive
        case dragging(row: Int, column: Int, state: TileState)
    }

    @GestureState private var dragState: DragState = .inactive
    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    func location(at point: CGPoint) -> (Int, Int) {
        let row = clamp(Int(point.y / puzzleMetrics.tileSize), min: 0, max: gameState.puzzle.height - 1)
        let column = clamp(Int(point.x / puzzleMetrics.tileSize), min: 0, max: gameState.puzzle.width - 1)
        return (row, column)
    }

    var body: some View {
        let puzzle = gameState.puzzle
        let mode = gameState.mode
        let gesture = DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .updating($dragState) { value, state, transaction in
                guard var tileState = mode.tileState else { return }
                let (row, column) = location(at: value.location)
                if case let .dragging(_, _, currentState) = state {
                    tileState = currentState
                } else if puzzle.tile(row: row, column: column) == mode.tileState {
                    tileState = .blank
                }
                state = .dragging(row: row, column: column, state: tileState)
            }
        PuzzleTilesView()
            .contentShape(Rectangle())
            .highPriorityGesture(gesture, isEnabled: mode.tileState != nil)
            .onChange(of: dragState) {
                if case .dragging = dragState {
                    gameState.beginTransaction()
                } else {
                    gameState.endTransaction()
                }
                guard case let .dragging(row, column, state) = dragState,
                      puzzle.rowIndices.contains(row),
                      puzzle.columnIndices.contains(column) else { return }
                gameState.fill(row: row, column: column, state: state)
            }
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
                            TileView(status: puzzle.tile(row: rowIndex, column: columnIndex))
                        }
                    }
                }
            }

            Path { path in
                for x in stride(from: 0, through: size.width, by: puzzleMetrics.tileSize) {
                    path.move(to: CGPointMake(x, 0))
                    path.addLine(to: CGPointMake(x, size.height))
                }
                for y in stride(from: 0, through: size.height, by: puzzleMetrics.tileSize) {
                    path.move(to: CGPointMake(0, y))
                    path.addLine(to: CGPointMake(size.width, y))
                }
            }
                .stroke(Color.primary.opacity(0.25), lineWidth: 1, antialiased: false)

            Path { path in
                for x in stride(from: 0, through: size.width, by: puzzleMetrics.majorTileSize) {
                    path.move(to: CGPointMake(x, 0))
                    path.addLine(to: CGPointMake(x, size.height))
                }
                for y in stride(from: 0, through: size.height, by: puzzleMetrics.majorTileSize) {
                    path.move(to: CGPointMake(0, y))
                    path.addLine(to: CGPointMake(size.width, y))
                }
            }
                .stroke(Color.primary.opacity(1), style: StrokeStyle(lineWidth: 1, lineCap: .square), antialiased: false)
        }
    }
}

private let puzzlePadding: CGFloat = 6

struct PuzzleGridView: View {
    @Binding var fitsView: Bool
    @State var offset: CGPoint = .zero

    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    var body: some View {
        let puzzle = gameState.puzzle

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
                    .padding(puzzlePadding)
            }
            GeometryReader { _ in
                VStack(spacing: 0) {
                    SegmentsView(axis: .horizontal, puzzle: puzzle, offset: offset, labelSize: puzzleMetrics.labelSize.height)
                        .padding(.leading, puzzleMetrics.segmentSize.width)
                    HStack(alignment: .top, spacing: 0) {
                        SegmentsView(axis: .vertical, puzzle: puzzle, offset: offset, labelSize: puzzleMetrics.labelSize.width)
                        Spacer()
                            .frame(width: puzzleMetrics.puzzleSize.width, height: puzzleMetrics.puzzleSize.height)
                    }
                        .clipped()
                }
            }
                .padding(puzzlePadding)
                .allowsHitTesting(false)
        }
            .frame(maxWidth: puzzleMetrics.totalSize.width + puzzlePadding * 2, maxHeight: puzzleMetrics.totalSize.height + puzzlePadding * 2)
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
