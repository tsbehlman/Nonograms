//
//  PuzzleSolveView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

enum InteractionMode {
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

struct PuzzleSolveView: View {
    @State var puzzle = Puzzle(size: 1, data: 1)
    @State var solver: Solver = Solver(rows: [[1]], columns: [[1]])
    @State var mode: InteractionMode = .fill(.filled)
    @State var scrollEnabled: Bool = false
    @State var fitsView: Bool = false
    @State var offset: CGPoint = .zero
    @State var isEmpty = true
    @State var isSolved = false
    @State var hint: SolverAttempt?

    @AppStorage("validate") var validate = NonogramsDefaults.validate

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Spacer()
            PuzzleMetricsProvider(puzzle: puzzle) {
                PuzzleGridView(puzzle: $puzzle, mode: $mode, fitsView: $fitsView, offset: $offset, hint: hint) { row, column, state in
                    guard case let .fill(selectedState) = mode else { return }
                    hint = nil
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
                }
            }
                .environment(\.puzzleColor, isSolved ? .green.mix(with: .primary.forScheme(.light), by: 0.125) : .accentColor)
            ControlView(puzzle: $puzzle, solver: $solver, mode: $mode, fitsView: $fitsView, isSolved: $isSolved, isEmpty: $isEmpty, hint: $hint)
                .padding(.horizontal, 16)
            Spacer()
        }
    }
}

#Preview {
    PuzzleSolveView()
}
