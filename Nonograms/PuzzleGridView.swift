//
//  PuzzleGridView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

private let tileSize: CGFloat = 48
private let segmentFont = Font.system(size: tileSize / 2, weight: .bold, design: .monospaced)

struct SegmentLabel: View {
    let segment: Segment

    var body: some View {
        Text("\(segment.length)")
            .font(segmentFont)
            .foregroundStyle(segment.state == .complete ? Color.accentColor : Color.primary)
    }
}

struct TileView: View {
    let status: TileState

    var body: some View {
        ZStack {
            Rectangle()
                .fill(status == .filled ? Color.accentColor : Color(UIColor.systemBackground))
                .stroke(Color(uiColor: .separator), lineWidth: 1, antialiased: false)
            if status == .blocked {
                Image(systemName: "xmark")
                    .font(.system(size: tileSize * 0.75, weight: .light))
                    .foregroundStyle(Color.secondary)
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
    let fill: (Int, Int) -> Void

    enum DragState: Equatable {
        case inactive
        case dragging(row: Int, column: Int)
    }

    @GestureState private var dragState: DragState = .inactive

    var body: some View {
        let gesture = DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .updating($dragState) { value, state, transaction in
                let row = clamp(Int(value.location.y / tileSize), min: 0, max: puzzle.size - 1)
                let column = clamp(Int(value.location.x / tileSize), min: 0, max: puzzle.size - 1)
                state = .dragging(row: row, column: column)
            }
        PuzzleTilesView(puzzle: $puzzle, fill: fill)
            .highPriorityGesture(gesture)
            .onChange(of: dragState) {
                guard case let .dragging(row, column) = dragState,
                      puzzle.indices.contains(row),
                      puzzle.indices.contains(column) else { return }
                fill(row, column)
            }
    }
}

struct PuzzleTilesView: View {
    @Binding var puzzle: Puzzle
    let fill: (Int, Int) -> Void

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<puzzle.size, id: \.self) { rowIndex in
                GridRow {
                    ForEach(0..<puzzle.size, id: \.self) { columnIndex in
                        TileView(status: puzzle.tile(row: rowIndex, column: columnIndex))
                            .onTapGesture {
                                fill(rowIndex, columnIndex)
                            }
                    }
                }
            }
        }
    }
}

struct PuzzleGridView: View {
    @Binding var puzzle: Puzzle
    let fill: (Int, Int) -> Void

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
                            VStack(spacing: 0) {
                                Spacer()
                                ForEach(puzzle.segments(forColumn: columnIndex)) { segment in
                                    SegmentLabel(segment: segment)
                                }
                            }
                            .padding(.bottom, 12)
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
                            HStack(spacing: 8) {
                                Spacer()
                                ForEach(puzzle.segments(forRow: rowIndex)) { segment in
                                    SegmentLabel(segment: segment)
                                }
                            }
                            .padding(.trailing, 12)
                        }
                    }
                }
                DraggablePuzzleTilesView(puzzle: $puzzle, fill: fill)
                    .gridCellUnsizedAxes([.horizontal, .vertical])
            }
        }
    }
}

#Preview {
    @Previewable @State var puzzle = Puzzle(size: 5, solution:
                                   0b11111,
                                   0b10001,
                                   0b10101,
                                   0b10001,
                                   0b11111
    )
    @Previewable @State var selectedState = TileState.filled

    PuzzleGridView(puzzle: $puzzle) { row, column in
        puzzle.set(row: row, column: column, to: selectedState)
    }
        .onAppear {
            puzzle.solve()
        }
}
