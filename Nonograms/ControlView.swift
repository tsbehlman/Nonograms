//
//  ControlView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/2/25.
//

import SwiftUI

let controlSize: CGFloat = 48

struct ControlButton: View {
    let icon: String
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isActive ? Color.accentColor : Color(UIColor.systemBackground))
                .stroke(Color(UIColor.separator))
            Image(systemName: icon)
                .foregroundStyle(isActive ? Color(UIColor.label.onFill) : Color.primary)
        }
            .frame(width: 48, height: 48, alignment: .center)
    }
}

struct ControlIconView: View {
    @Binding var state: TileState
    let control: TileState
    let icon: String

    var body: some View {
        ControlButton(icon: icon, isActive: state == control)
            .onTapGesture {
                state = control
            }
    }
}

struct ControlView: View {
    @StateObject var keyboardObserver = KeyboardObserver()
    @Binding var state: TileState
    @Binding var puzzle: Puzzle
    @Binding var solver: Solver

    var body: some View {
        HStack {
            ControlButton(icon: "arrow.2.circlepath", isActive: false)
                .onTapGesture {
                    generateNewPuzzle()
                }
            Spacer()
            ControlButton(icon: "questionmark", isActive: false)
                .onTapGesture {
                    solver.step()
                    for (index, tile) in solver.tiles.enumerated() {
                        puzzle.tiles[index] = tile
                    }
                }
            ControlIconView(state: $state, control: .filled, icon: "square.fill")
            ControlIconView(state: $state, control: .blocked, icon: "xmark")
        }
        .onChange(of: keyboardObserver.modifiers.contains(.option)) { _, isOptionPressed in
            if isOptionPressed {
                state = .blocked
            } else {
                state = .filled
            }
        }
        .onAppear {
            generateNewPuzzle()
        }
    }

    func generateNewPuzzle() {
        let size = 5
        puzzle = makeSolvablePuzzle(ofSize: size)
        solver = Solver(
            rows: (0..<size).map { puzzle.segments(forRow: $0).map { $0.length } },
            columns: (0..<size).map { puzzle.segments(forColumn: $0).map { $0.length } }
        )
    }
}

#Preview {
    @Previewable @State var state: TileState = .filled
    @Previewable @State var puzzle = Puzzle(size: 1, solution: 0b0)
    @Previewable @State var solver = Solver(rows: [], columns: [])
    ControlView(state: $state, puzzle: $puzzle, solver: $solver)
}
