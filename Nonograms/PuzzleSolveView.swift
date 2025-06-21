//
//  PuzzleSolveView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

struct PuzzleSolveView: View {
    @State var puzzle = Puzzle(size: 5, solution:
                               0b00000,
                               0b00000,
                               0b00000,
                               0b00000,
                               0b00000)
    @State var solver: Solver = Solver(
        rows: [[0], [0], [0], [0], [0]],
        columns: [[0], [0], [0], [0], [0]]
    )
    @State var selectedState: TileState = .filled

    var body: some View {
        EqualStack(axis: .vertical, spacing: 16) {
            PuzzleGridView(puzzle: $puzzle, selectedState: $selectedState) { row, column, state in
                puzzle.set(row: row, column: column, to: state ?? selectedState, holding: state != nil)
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
