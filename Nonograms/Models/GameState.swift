//
//  GameState.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/13/25.
//

import SwiftUI

enum InteractionMode: Codable, Equatable {
    case move
    case fill(TileState)

    var tileState: TileState? {
        switch self {
        case .fill(let state):
            return state
        default:
            return nil
        }
    }
}

@Observable
final class GameState: RepresentableWithCoding {
    var puzzle: Puzzle
    var solver: Solver
    var mode: InteractionMode = .fill(.filled)
    let validate: Bool
    var isEmpty = true
    var isSolved = false
    var hint: SolverAttempt?
    var history: [PuzzleTransaction] = []
    var historyIndex = 0
    var transactionGroup: PuzzleTransactionGroup?

    var puzzleColor: Color {
        isSolved
            ? .green.mix(with: .primary.forScheme(.light), by: 0.125)
            : .accentColor
    }

    private enum CodingKeys: CodingKey {
        case puzzle, mode, validate, isEmpty, isSolved
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let puzzle = try container.decode(Puzzle.self, forKey: .puzzle)
        self.puzzle = puzzle
        solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
        mode = try container.decode(InteractionMode.self, forKey: .mode)
        validate = try container.decode(Bool.self, forKey: .validate)
        isEmpty = try container.decode(Bool.self, forKey: .isEmpty)
        isSolved = try container.decode(Bool.self, forKey: .isSolved)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(puzzle, forKey: .puzzle)
        try container.encode(mode, forKey: .mode)
        try container.encode(validate, forKey: .validate)
        try container.encode(isEmpty, forKey: .isEmpty)
        try container.encode(isSolved, forKey: .isSolved)
    }

    init(puzzle: Puzzle = Puzzle(width: 1, height: 1, solution: [.filled]), solver: Solver = Solver(rows: [[1]], columns: [[1]]), validate: Bool = false) {
        self.puzzle = puzzle
        self.solver = solver
        self.validate = validate
    }

    func newGame(width: Int, height: Int, difficulty: PuzzleDifficulty, validate: Bool = false) -> GameState {
        let puzzle = makeSolvablePuzzle(width: width, height: height, difficulty: difficulty)
        let solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
        let nextGame = GameState(puzzle: puzzle, solver: solver, validate: validate)
        nextGame.mode = mode
        return nextGame
    }

    private func set(_ tileIndex: Int, to desiredState: TileState, isHolding: Bool) -> TileState {
        let currentState = puzzle.tiles[tileIndex]
        let expectedState = puzzle.solution[tileIndex]
        var newState = currentState
        switch (currentState, desiredState) {
        case (.blank, .blocked):
            newState = .blocked
        case (.blank, .filled):
            if !validate || expectedState == .filled {
                newState = .filled
            } else {
                newState = .error
            }
        case (.blocked, .blocked):
            if !isHolding {
                newState = .blank
            }
        case (.blocked, .blank):
            if mode == .fill(.blocked) {
                newState = .blank
            }
        case (.filled, .blank):
            if !validate && mode == .fill(.filled) {
                newState = .blank
            }
        case (.filled, .filled):
            if !validate && !isHolding {
                newState = .blank
            }
        case (_, .error):
            newState = .error
        case (.blocked, _):
            break
        case (.error, _):
            break
        case (.filled, _):
            break
        case (_, .blank):
            break
        }

        puzzle.tiles[tileIndex] = newState
        if newState == puzzle.solution[tileIndex] || newState == .error || newState == .blank {
            solver.set(tileIndex, to: newState)
        }

        return newState
    }

    func fill(row: Int, column: Int, state: TileState?) {
        guard case let .fill(selectedState) = mode, !isSolved else { return }
        let isHolding = state != nil
        let desiredState = state ?? selectedState
        let tileIndex = puzzle.tileIndex(row: row, column: column)
        let oldState = puzzle.tiles[tileIndex]
        let newState = set(tileIndex, to: desiredState, isHolding: isHolding)
        if desiredState == .filled && puzzle.isSolved() {
            isSolved = true
            puzzle.solve()
        } else if newState != oldState {
            let transaction = SinglePuzzleTransaction(tileIndex: tileIndex, oldState: oldState, newState: newState)
            if transactionGroup != nil {
                transactionGroup!.transactions.append(transaction)
            } else {
                history.insert(transaction, at: historyIndex)
                historyIndex += 1
                history.removeSubrange(historyIndex...)
            }
        }
        isEmpty = false
        hint = nil
    }

    func beginTransaction() {
        guard transactionGroup == nil else { return }
        transactionGroup = PuzzleTransactionGroup()
    }

    func endTransaction() {
        guard let group = transactionGroup else { return }
        if !group.transactions.isEmpty {
            history.insert(group, at: historyIndex)
            historyIndex += 1
            history.removeSubrange(historyIndex...)
        }
        transactionGroup = nil
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
        if historyIndex == 0 {
            isEmpty = true
        }
    }

    func redo() {
        guard hasRedo else { return }
        history[historyIndex].applyRedo(self)
        historyIndex += 1
    }
}

protocol PuzzleTransaction {
    func applyUndo(_ gameState: GameState)
    func applyRedo(_ gameState: GameState)
}

struct SinglePuzzleTransaction: PuzzleTransaction {
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

struct PuzzleTransactionGroup: PuzzleTransaction {
    var transactions: [SinglePuzzleTransaction] = []

    func applyUndo(_ gameState: GameState) {
        for transaction in transactions.reversed() {
            transaction.applyUndo(gameState)
        }
    }

    func applyRedo(_ gameState: GameState) {
        for transaction in transactions {
            transaction.applyRedo(gameState)
        }
    }
}
