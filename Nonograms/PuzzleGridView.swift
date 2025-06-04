//
//  PuzzleGridView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

private let tileSize: CGFloat = 48

struct TileView: View {
    let status: TileState

    var body: some View {
        Group {
            if status == .blocked {
                Image(systemName: "xmark")
                    .font(.system(size: tileSize * 0.75, weight: .light))
                    .foregroundStyle(Color.secondary)
            } else if status == .filled {
                Color.accentColor
            } else {
                Color(UIColor.systemBackground)
            }
        }
        .frame(width: tileSize, height: tileSize, alignment: .center)
        .border(Color(uiColor: .separator))
    }
}

struct PuzzleGridView: View {
    @Binding var puzzle: Puzzle
    @Binding var selectedState: TileState

    var body: some View {
        Grid(horizontalSpacing: -1, verticalSpacing: -1) {
            GridRow {
                Color.clear
                    .frame(width: tileSize, height: tileSize, alignment: .center)
                ForEach(0..<puzzle.size, id: \.self) { columnIndex in
                    VStack(spacing: 0) {
                        ForEach(puzzle.sequences(forColumn: columnIndex)) { sequence in
                            Text("\(sequence.length)")
                                .foregroundStyle(sequence.state == .complete ? Color.secondary : Color.primary)
                        }
                    }
                        .gridCellAnchor(.bottom)
                        .padding(.vertical, 12)
                }
            }
            ForEach(0..<puzzle.size, id: \.self) { rowIndex in
                GridRow {
                    HStack(spacing: 8) {
                        ForEach(puzzle.sequences(forRow: rowIndex)) { sequence in
                            Text("\(sequence.length)")
                                .foregroundStyle(sequence.state == .complete ? Color.secondary : Color.primary)
                        }
                    }
                        .gridCellAnchor(.trailing)
                        .padding(.horizontal, 12)
                    ForEach(0..<puzzle.size, id: \.self) { columnIndex in
                        TileView(status: puzzle.tile(row: rowIndex, column: columnIndex))
                            .onTapGesture {
                                puzzle.set(row: rowIndex, column: columnIndex, to: selectedState)
                            }
                    }
                }
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

    PuzzleGridView(puzzle: $puzzle, selectedState: $selectedState)
        .onAppear {
            puzzle.solve()
        }
}
