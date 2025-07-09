//
//  ControlView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/2/25.
//

import SwiftUI

struct ControlIconView: View {
    @Binding var mode: InteractionMode
    let control: TileState
    let icon: String
    let disabled: Bool

    var body: some View {
        ControlButton(icon: icon, active: mode.tileState == control, disabled: disabled)
            .onTapGesture {
                if !disabled {
                    mode = .fill(control)
                }
            }
    }
}

struct ControlView: View {
    @StateObject var keyboardObserver = KeyboardObserver()
    @Binding var puzzle: Puzzle
    @Binding var solver: Solver
    @Binding var mode: InteractionMode
    @Binding var fitsView: Bool
    @Binding var isSolved: Bool

    var body: some View {
        HStack(spacing: 12) {
            Menu {
                Button {
                    generateNewPuzzle(ofSize: 5)
                } label: {
                    Text("5x5")
                }
                Button {
                    generateNewPuzzle(ofSize: 10)
                } label: {
                    Text("10x10")
                }
            } label: {
                ControlButton(icon: "arrow.2.circlepath", active: false, disabled: false)
            }
            ControlButton(icon: "questionmark", active: false, disabled: false)
                .onTapGesture {
                    solver.step()
                    for (index, tile) in solver.tiles.enumerated() {
                        puzzle.tiles[index] = tile
                    }
                }
            Spacer()
            ControlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", active: !fitsView && mode.tileState == nil, disabled: fitsView)
                .onTapGesture {
                    if !fitsView {
                        mode = .move
                    }
                }
            ControlIconView(mode: $mode, control: .filled, icon: "square.fill", disabled: false)
            ControlIconView(mode: $mode, control: .blocked, icon: "xmark", disabled: false)
        }
        .onChange(of: keyboardObserver.modifiers.contains(.option)) { _, isOptionPressed in
            if isOptionPressed {
                mode = .fill(.blocked)
            } else {
                mode = .fill(.filled)
            }
        }
        .onChange(of: fitsView) { _, fitsView in
            if fitsView, case .move = mode {
                mode = .fill(.blocked)
            }
        }
        .onAppear {
            generateNewPuzzle()
        }
    }

    func generateNewPuzzle(ofSize size: Int = 5) {
        puzzle = makeSolvablePuzzle(ofSize: size)
        solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
        isSolved = false
    }
}

#Preview {
    @Previewable @State var mode: InteractionMode = .fill(.filled)
    @Previewable @State var puzzle = Puzzle(size: 1, data: 0b0)
    @Previewable @State var solver = Solver(rows: [], columns: [])
    @Previewable @State var fitsView: Bool = false
    @Previewable @State var isSolved: Bool = false

    ControlView(puzzle: $puzzle, solver: $solver, mode: $mode, fitsView: $fitsView, isSolved: $isSolved)
}
