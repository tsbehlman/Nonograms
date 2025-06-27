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
                .stroke(Color.primary.opacity(0.25))
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
                ControlButton(icon: "arrow.2.circlepath", isActive: false)
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

    func generateNewPuzzle(ofSize size: Int = 5) {
        puzzle = makeSolvablePuzzle(ofSize: size)
        solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
    }
}

#Preview {
    @Previewable @State var state: TileState = .filled
    @Previewable @State var puzzle = Puzzle(size: 1, data: 0b0)
    @Previewable @State var solver = Solver(rows: [], columns: [])
    ControlView(state: $state, puzzle: $puzzle, solver: $solver)
}
