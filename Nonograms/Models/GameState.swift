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
    var history: [PuzzleTransaction] = []
    var historyIndex = 0

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
        let isHolding = state != nil
        let desiredState = state ?? selectedState
        let tileIndex = puzzle.tileIndex(row: row, column: column)
        let oldState = puzzle.tiles[tileIndex]
        puzzle.set(tileIndex, to: desiredState, holding: isHolding, validate: validate)
        let newState = puzzle.tiles[tileIndex]
        if newState == puzzle.solution[tileIndex] || newState == .error || newState == .blank {
            solver.set(row: row, column: column, to: newState)
        }
        if desiredState == .filled && puzzle.isSolved() {
            isSolved = true
            puzzle.solve()
        } else if newState != oldState {
            history.append(PuzzleTransaction(tileIndex: tileIndex, oldState: oldState, newState: newState))
            historyIndex += 1
            history.removeSubrange(historyIndex...)
        }
        isEmpty = false
        hint = nil
    }

    func showHint() {
        guard !isSolved else { return }
        hint = solver.step()
    }

    var hasUndo: Bool {
        !isSolved && historyIndex > 0
    }

    var hasRedo: Bool {
        !isSolved && historyIndex < history.count
    }

    func undo() {
        guard hasUndo else { return }
        historyIndex -= 1
        history[historyIndex].applyUndo(self)
    }

    func redo() {
        guard hasRedo else { return }
        history[historyIndex].applyRedo(self)
        historyIndex += 1
    }
}

struct PuzzleTransaction {
    let tileIndex: Int
    let oldState: TileState
    let newState: TileState

    func applyUndo(_ gameState: GameState) {
        gameState.puzzle.tiles[tileIndex] = oldState
        gameState.solver.set(tileIndex, to: oldState)
    }

    func applyRedo(_ gameState: GameState) {
        gameState.puzzle.tiles[tileIndex] = newState
        if newState == gameState.puzzle.solution[tileIndex] || newState == .error || newState == .blank {
            gameState.solver.set(tileIndex, to: newState)
        }
    }
}
