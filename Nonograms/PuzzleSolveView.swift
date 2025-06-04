//
//  PuzzleSolveView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

struct PuzzleSolveView: View {
    @State var puzzle = Puzzle(size: 5, solution:
                                   0b11111,
                                   0b10001,
                                   0b10101,
                                   0b10001,
                                   0b11111
    )
    @State var selectedState: TileState = .filled

    var body: some View {
        VStack(alignment: .trailing) {
            PuzzleGridView(puzzle: $puzzle, selectedState: $selectedState)
            ControlView(state: $selectedState)
        }
    }
}

#Preview {
    PuzzleSolveView()
}
