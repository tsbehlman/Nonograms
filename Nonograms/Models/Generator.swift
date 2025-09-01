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
            return 0.65..<0.75
        case .medium:
            return 0.45..<0.65
        case .hard:
            return 0.35..<0.45
        }
    }

    func minInferenceLength(forSize size: Int) -> Int {
        switch self {
        case .easy:
            return max(1, Int((Double(size) / 4.0).rounded()))
        case .medium:
            return max(1, Int((Double(size) / 6.0).rounded()))
        case .hard:
            return 1
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

    while !isSolvable(puzzle, withSkillLevel: difficulty) {
        let index = indexSet.randomIndex()
        indexSet.remove(index)
        tiles[index] = .filled
        puzzle = Puzzle(width: width, height: height, solution: tiles)
    }

    return puzzle
}

private func isSolvable(_ puzzle: Puzzle, withSkillLevel skillLevel: PuzzleDifficulty) -> Bool {
    var solver = Solver(
        rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
        columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } },
        skillLevel: skillLevel
    )
    return solver.canSolvePuzzle()
}
