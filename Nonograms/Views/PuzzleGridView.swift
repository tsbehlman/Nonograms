//
//  PuzzleGridView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

struct TileView: View {
    let status: TileState

    @Environment(\.gameState.puzzleColor) var puzzleColor
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
    enum DragState: Equatable {
        case inactive
        case dragging(row: Int, column: Int, state: TileState)
    }

    @GestureState private var dragState: DragState = .inactive
    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    var body: some View {
        let puzzle = gameState.puzzle
        let mode = gameState.mode
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
        PuzzleTilesView()
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
    }
}

struct PuzzleTilesView: View {
    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    var body: some View {
        let puzzle = gameState.puzzle
        ZStack {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<puzzle.size, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(0..<puzzle.size, id: \.self) { columnIndex in
                            TileView(status: puzzle.tile(row: rowIndex, column: columnIndex))
                                .onTapGesture {
                                    gameState.fill(row: rowIndex, column: columnIndex, state: nil)
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
    @Binding var fitsView: Bool
    @State var offset: CGPoint = .zero

    @Environment(\.puzzleMetrics) var puzzleMetrics
    @Environment(\.gameState) var gameState

    var body: some View {
        let puzzle = gameState.puzzle
        let maxSegments = (puzzle.size + 1) / 2
        let labelSize = puzzleMetrics.segmentFontSize * CGFloat(maxSegments)
        let segmentSize = labelSize + puzzleMetrics.segmentPadding * 2
        let puzzleSize = puzzleMetrics.tileSize * CGFloat(puzzle.size)
        let totalSize = puzzleSize + segmentSize

        ZStack {
            PannableView(scrollEnabled: gameState.mode.tileState == nil, fitsView: $fitsView, offset: $offset) {
                VStack(spacing: 0) {
                    SegmentsBackground(axis: .horizontal, offset: offset, segmentSize: segmentSize)
                        .frame(width: puzzleSize, height: segmentSize)
                        .padding(.leading, segmentSize)
                    HStack(alignment: .top, spacing: 0) {
                        SegmentsBackground(axis: .vertical, offset: offset, segmentSize: segmentSize)
                            .frame(width: segmentSize, height: puzzleSize)
                        ZStack(alignment: .topLeading) {
                            DraggablePuzzleTilesView()
                            if let hint = gameState.hint {
                                HintOverlayView(hint: hint)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
            }
            GeometryReader { _ in
                VStack(spacing: 0) {
                    SegmentsView(axis: .horizontal, puzzle: puzzle, offset: offset, labelSize: labelSize)
                        .padding(.leading, segmentSize)
                    HStack(alignment: .top, spacing: 0) {
                        SegmentsView(axis: .vertical, puzzle: puzzle, offset: offset, labelSize: labelSize)
                        Spacer()
                            .frame(width: puzzleSize, height: puzzleSize)
                    }
                    .clipped()
                }
            }
                .allowsHitTesting(false)
        }
            .frame(maxWidth: totalSize, maxHeight: totalSize)
            .padding(6)
            .clipped()
    }
}

#Preview {
    @Previewable @State var gameState = GameState().newGame(ofSize: 5, difficulty: .easy)
    @Previewable @State var fitsView: Bool = false

    PuzzleGridView(fitsView: $fitsView)
        .environment(\.gameState, gameState)
        .onAppear {
            gameState.puzzle.solve()
        }
}
