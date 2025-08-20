//
//  Generator.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/20/25.
//

import Foundation

enum PuzzleDifficulty: Int {
    case easy
    case medium
    case hard

    var fillRate: Range<Double> {
        switch self {
        case .easy:
            return 0.625..<0.750
        case .medium:
            return 0.500..<0.625
        case .hard:
            return 0.375..<0.500
        }
    }
}

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

func makeSolvablePuzzle(width: Int, height: Int, difficulty: PuzzleDifficulty = .easy) -> Puzzle {
    let numTiles = width * height
    var tiles: [TileState] = Array(repeating: .blocked, count: numTiles)
    var indexSet = IndexSet(integersIn: tiles.indices)

    let targetFillRate = Double.random(in: difficulty.fillRate)

    for _ in 0..<Int(Double(numTiles) * targetFillRate) {
        let index = indexSet.randomIndex()
        indexSet.remove(index)
        tiles[index] = .filled
    }

    var puzzle = Puzzle(width: width, height: height, solution: tiles)

    while !isSolvable(puzzle) {
        let index = indexSet.randomIndex()
        indexSet.remove(index)
        tiles[index] = .filled
        puzzle = Puzzle(width: width, height: height, solution: tiles)
    }

    return puzzle
}

private func isSolvable(_ puzzle: Puzzle) -> Bool {
    var solver = Solver(
        rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
        columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
    )
    return solver.canSolvePuzzle()
}
