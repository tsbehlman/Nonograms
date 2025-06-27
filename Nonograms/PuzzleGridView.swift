//
//  PuzzleGridView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

private let tileSize: CGFloat = 48
private let majorTileSize = tileSize * 5
private let segmentFontSize = tileSize / 2
private let segmentFont = Font.system(size: segmentFontSize, weight: .bold, design: .monospaced)

struct SegmentLabel: View {
    let segment: Segment

    var body: some View {
        Text("\(segment.length)")
            .font(segmentFont)
            .foregroundStyle(segment.state == .complete ? Color.accentColor : Color.primary)
    }
}

struct SegmentLabels: View {
    let puzzle: Puzzle
    let axis: Axis
    let index: Int

    var maxSegments: Int {
        (puzzle.size + 1) / 2
    }

    var labelSize: CGFloat {
        segmentFontSize * CGFloat(maxSegments)
    }

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
            width: axis == .horizontal ? labelSize : tileSize,
            height: axis == .horizontal ? tileSize : labelSize,
            alignment: axis == .horizontal ? .trailing : .bottom
        )
        .padding(axis == .horizontal ? .trailing : .bottom, segmentFontSize / 2)
    }
}

struct TileView: View {
    let status: TileState

    var body: some View {
        Group {
            if status == .blocked {
                Image(systemName: "xmark")
                    .font(.system(size: tileSize * 0.75, weight: .light))
                    .foregroundStyle(Color.secondary)
            } else {
                Rectangle()
                    .fill(status == .filled ? Color.accentColor : Color(UIColor.systemBackground))
            }
        }
            .frame(width: tileSize, height: tileSize, alignment: .center)
    }
}

let segmentGradient = Gradient(stops: [
    .init(color: Color.accentColor.opacity(0.000), location: 0.0),
    .init(color: Color.accentColor.opacity(0.125), location: 0.375),
    .init(color: Color.accentColor.opacity(0.250), location: 1.0),
])

struct DraggablePuzzleTilesView: View {
    @Binding var puzzle: Puzzle
    @Binding var selectedState: TileState
    let fill: (Int, Int, TileState?) -> Void

    enum DragState: Equatable {
        case inactive
        case dragging(row: Int, column: Int, state: TileState)
    }

    @GestureState private var dragState: DragState = .inactive

    var body: some View {
        let gesture = DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .updating($dragState) { value, state, transaction in
                let row = clamp(Int(value.location.y / tileSize), min: 0, max: puzzle.size - 1)
                let column = clamp(Int(value.location.x / tileSize), min: 0, max: puzzle.size - 1)
                var tileState = selectedState
                if case let .dragging(_, _, currentState) = state {
                    tileState = currentState
                } else if puzzle.tile(row: row, column: column) == selectedState {
                    tileState = .blank
                }
                state = .dragging(row: row, column: column, state: tileState)
            }
        PuzzleTilesView(puzzle: $puzzle, fill: fill)
            .highPriorityGesture(gesture)
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
                .stroke(Color.primary.opacity(1), lineWidth: 1, antialiased: false)
        }
    }
}

struct PuzzleGridView: View {
    @Binding var puzzle: Puzzle
    @Binding var selectedState: TileState
    let fill: (Int, Int, TileState?) -> Void

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])
                EqualStack(axis: .horizontal, itemWidth: .fixed(tileSize)) {
                    ForEach(0..<puzzle.size, id: \.self) { columnIndex in
                        ZStack {
                            if columnIndex.isMultiple(of: 2) {
                                Rectangle()
                                    .fill(LinearGradient(gradient: segmentGradient, startPoint: .top, endPoint: .bottom))
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                            }
                            SegmentLabels(puzzle: puzzle, axis: .vertical, index: columnIndex)
                        }
                    }
                }
            }
            GridRow {
                EqualStack(axis: .vertical, itemHeight: .fixed(tileSize)) {
                    ForEach(0..<puzzle.size, id: \.self) { rowIndex in
                        ZStack {
                            if rowIndex.isMultiple(of: 2) {
                                Rectangle()
                                    .fill(LinearGradient(gradient: segmentGradient, startPoint: .leading, endPoint: .trailing))
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                            }
                            SegmentLabels(puzzle: puzzle, axis: .horizontal, index: rowIndex)
                        }
                    }
                }
                DraggablePuzzleTilesView(puzzle: $puzzle, selectedState: $selectedState, fill: fill)
                    .gridCellUnsizedAxes([.horizontal, .vertical])
            }
        }
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
    @Previewable @State var selectedState = TileState.filled

    PuzzleGridView(puzzle: $puzzle, selectedState: $selectedState) { row, column, state in
        puzzle.set(row: row, column: column, to: state ?? selectedState, holding: state != nil)
    }
        .onAppear {
            puzzle.solve()
        }
}
