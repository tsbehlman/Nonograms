//
//  NonogramsApp.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

@main
struct NonogramsApp: App {
    @State var puzzle = Puzzle(size: 5, solution:
                                   0b11111,
                                   0b10001,
                                   0b10101,
                                   0b10001,
                                   0b11111
    )
    @State var selectedState: TileState = .filled

    var body: some Scene {
        WindowGroup {
            VStack(alignment: .center) {
                PuzzleGridView(puzzle: $puzzle, selectedState: $selectedState)
                ControlView(state: $selectedState)
            }
        }
    }
}
