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
        ControlButton(icon: icon, active: mode.tileState == control, disabled: disabled, bordered: false)
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
    @Binding var isEmpty: Bool
    @Binding var hint: SolverAttempt?

    @State var showSettings = false
    @AppStorage("difficulty") var difficulty = NonogramsDefaults.difficulty

    var body: some View {
        HStack(spacing: 12) {
            StaggeredStack(angle: .degrees(45), spacing: 16) {
                Menu {
                    Button {
                        generateNewPuzzle(ofSize: 5)
                    } label: {
                        Text("5x5")
                    }
                    Button {
                        generateNewPuzzle(ofSize: 8)
                    } label: {
                        Text("8x8")
                    }
                    Button {
                        generateNewPuzzle(ofSize: 10)
                    } label: {
                        Text("10x10")
                    }
                } label: {
                    ControlButton(icon: "arrow.2.circlepath")
                        .when(isSolved) {
                            $0.background(RippleView())
                        }
                }
                ControlButton(icon: "gearshape")
                    .onTapGesture {
                        showSettings = true
                    }
                ControlButton(icon: "questionmark")
                    .when(isEmpty) {
                        $0.background(RippleView())
                    }
                    .onTapGesture {
                        if !isSolved {
                            hint = solver.step()
                        }
                    }
            }
            Spacer()
            StaggeredStack(angle: .degrees(-45), spacing: 16) {
                ControlIconView(mode: $mode, control: .filled, icon: "square.fill", disabled: false)
                ControlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", active: !fitsView && mode.tileState == nil, disabled: fitsView, bordered: false)
                    .onTapGesture {
                        if !fitsView {
                            mode = .move
                        }
                    }
                ControlIconView(mode: $mode, control: .blocked, icon: "xmark", disabled: false)
            }
                .traceBackground(padding: 7, curvature: 21) {
                    $0.stroke(Color.primary.opacity(0.375)).fill(Color.primary.opacity(0.25))
                }
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
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            generateNewPuzzle()
        }
    }

    func generateNewPuzzle(ofSize size: Int = 5) {
        puzzle = makeSolvablePuzzle(ofSize: size, difficulty: difficulty)
        solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
        isSolved = false
        isEmpty = true
        hint = nil
    }
}

#Preview {
    @Previewable @State var mode: InteractionMode = .fill(.filled)
    @Previewable @State var puzzle = Puzzle(size: 1, data: 0b0)
    @Previewable @State var solver = Solver(rows: [], columns: [])
    @Previewable @State var fitsView: Bool = false
    @Previewable @State var isSolved: Bool = false
    @Previewable @State var isEmpty: Bool = true
    @Previewable @State var hint: SolverAttempt?

    ControlView(puzzle: $puzzle, solver: $solver, mode: $mode, fitsView: $fitsView, isSolved: $isSolved, isEmpty: $isEmpty, hint: $hint)
        .padding()
}
