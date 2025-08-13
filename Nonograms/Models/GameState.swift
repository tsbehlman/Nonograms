//
//  GameState.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/13/25.
//

import SwiftUI

@Observable
class GameState {
    var puzzle: Puzzle
    var solver: Solver
    var mode: InteractionMode = .fill(.filled)
    let validate: Bool
    var isEmpty = true
    var isSolved = false
    var hint: SolverAttempt?

    var puzzleColor: Color {
        isSolved
            ? .green.mix(with: .primary.forScheme(.light), by: 0.125)
            : .accentColor
    }

    init(puzzle: Puzzle = Puzzle(size: 1, solution: [.filled]), solver: Solver = Solver(rows: [[1]], columns: [[1]])) {
        self.puzzle = puzzle
        self.solver = solver
        self.validate = false
    }

    init(size: Int, difficulty: PuzzleDifficulty, validate: Bool) {
        let puzzle = makeSolvablePuzzle(ofSize: size, difficulty: difficulty)
        self.puzzle = puzzle
        self.solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
        self.validate = validate
    }

    func fill(row: Int, column: Int, state: TileState?) {
        guard case let .fill(selectedState) = mode, !isSolved else { return }
        puzzle.set(row: row, column: column, to: state ?? selectedState, holding: state != nil, validate: validate)
        let tileIndex = puzzle.tileIndex(row: row, column: column)
        let newTile = puzzle.tiles[tileIndex]
        if newTile == puzzle.solution[tileIndex] || newTile == .error || newTile == .blank {
            solver.set(row: row, column: column, to: newTile)
        }
        if state ?? selectedState == .filled && puzzle.isSolved() {
            isSolved = true
            puzzle.solve()
        }
        isEmpty = false
        hint = nil
    }

    func showHint() {
        guard !isSolved else { return }
        hint = solver.step()
    }
}
