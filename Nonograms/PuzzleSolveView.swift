//
//  PuzzleSolveView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

struct PuzzleSolveView: View {
    @State var puzzle = Puzzle(size: 6, solution:
                                   0b111111,
                                   0b011111,
                                   0b111100,
                                   0b110110,
                                   0b011101,
                                   0b000000
    )
    @State var solver: Solver = Solver(
        rows: [[6], [5], [4], [2, 2], [3, 1], [0]],
        columns: [[1, 2], [5], [3, 1], [5], [2, 1], [2, 1]]
    )
    @State var selectedState: TileState = .filled

    var body: some View {
        EqualStack(axis: .vertical, spacing: 16) {
            PuzzleGridView(puzzle: $puzzle) { row, column in
                puzzle.set(row: row, column: column, to: selectedState)
                solver.set(row: row, column: column, to: puzzle.tile(row: row, column: column))
            }
            ControlView(state: $selectedState, puzzle: $puzzle, solver: $solver)
        }
        .padding()
    }
}

#Preview {
    PuzzleSolveView()
}
