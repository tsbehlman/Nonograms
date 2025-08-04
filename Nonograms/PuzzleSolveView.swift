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
    @State var isSolved = false
    @State var showSettings = false

    @AppStorage("validate") var validate = NonogramsDefaults.validate

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                ControlButton(icon: "gearshape", active: false, disabled: false)
                    .onTapGesture {
                        showSettings = true
                    }
            }
                .padding(.horizontal, 16)
            Spacer()
            PuzzleMetricsProvider(puzzle: puzzle) {
                PuzzleGridView(puzzle: $puzzle, mode: $mode, fitsView: $fitsView, offset: $offset) { row, column, state in
                    guard case let .fill(selectedState) = mode else { return }
                    puzzle.set(row: row, column: column, to: state ?? selectedState, holding: state != nil, validate: validate)
                    solver.set(row: row, column: column, to: puzzle.tile(row: row, column: column))
                    if state ?? selectedState == .filled && puzzle.isSolved() {
                        isSolved = true
                        puzzle.solve()
                    }
                }
            }
            .environment(\.puzzleColor, isSolved ? .green.mix(with: .primary, by: 0.125) : .accentColor)
            ControlView(puzzle: $puzzle, solver: $solver, mode: $mode, fitsView: $fitsView, isSolved: $isSolved)
                .padding(.horizontal, 16)
            Spacer()
        }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
    }
}

#Preview {
    PuzzleSolveView()
}
