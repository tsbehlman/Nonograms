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

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            PuzzleGridView(puzzle: $puzzle, mode: $mode, fitsView: $fitsView, offset: $offset) { row, column, state in
                guard case let .fill(selectedState) = mode else { return }
                puzzle.set(row: row, column: column, to: state ?? selectedState, holding: state != nil)
                solver.set(row: row, column: column, to: puzzle.tile(row: row, column: column))
            }
            ControlView(puzzle: $puzzle, solver: $solver, mode: $mode, fitsView: $fitsView)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    PuzzleSolveView()
}
