//
//  Generator.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/20/25.
//

import Foundation

private let minTargetFillRate = 0.375
private let maxTargetFillRate = 0.625

extension IndexSet {
    func randomIndex() -> Element {
        var choice = Element.random(in: 0..<count)
        for range in rangeView {
            if range.length > choice {
                return range.lowerBound + choice
            }
            choice -= range.length
        }
        fatalError("Unable to identify a random index")
    }
}

func makeSolvablePuzzle(ofSize size: Int) -> Puzzle {
    let numTiles = size * size
    var tiles: [TileState] = Array(repeating: .blocked, count: numTiles)
    var indexSet = IndexSet(integersIn: tiles.indices)

    let targetFillRate = Double.random(in: minTargetFillRate..<maxTargetFillRate)

    for _ in 0..<Int(Double(numTiles) * targetFillRate) {
        let index = indexSet.randomIndex()
        indexSet.remove(index)
        tiles[index] = .filled
    }

    var puzzle = Puzzle(size: size, solution: tiles)

    while !isSolvable(puzzle) {
        let index = indexSet.randomIndex()
        indexSet.remove(index)
        tiles[index] = .filled
        puzzle = Puzzle(size: size, solution: tiles)
    }

    return puzzle
}

private func isSolvable(_ puzzle: Puzzle) -> Bool {
    var solver = Solver(
        rows: (0..<puzzle.size).map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
        columns: (0..<puzzle.size).map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
    )
    return solver.canSolvePuzzle()
}
