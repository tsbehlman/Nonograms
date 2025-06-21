//
//  Generator.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/20/25.
//

import Foundation

private let minTargetFillRate = 0.375

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
    var tiles: [TileState] = Array(repeating: .blank, count: numTiles)
    var indexSet = IndexSet(integersIn: tiles.indices)

    for _ in 0..<Int(Double(numTiles) * minTargetFillRate) {
        let index = indexSet.randomIndex()
        indexSet.remove(index)
        tiles[index] = .filled
    }

    while !makesSolvablePuzzle(tiles: tiles, size: size) {
        let index = indexSet.randomIndex()
        indexSet.remove(index)
        tiles[index] = .filled
    }

    return Puzzle(size: size, solution: solution(forTiles: tiles, size: size))
}

private func makesSolvablePuzzle(tiles: [TileState], size: Int) -> Bool {
    let rows = (0..<size).map { rowIndex in
        let states = tiles.gridIndices(forRow: rowIndex, width: size).map { tiles[$0] }

        var lengths: [Int] = []
        var length = 0
        for state in states {
            if state == .filled {
                length += 1
            } else if length > 0 {
                lengths.append(length)
                length = 0
            }
        }
        if length > 0 {
            lengths.append(length)
        }

        return lengths
    }

    let columns = (0..<size).map { rowIndex in
        let states = tiles.gridIndices(forColumn: rowIndex, width: size).map { tiles[$0] }

        var lengths: [Int] = []
        var length = 0
        for state in states {
            if state == .filled {
                length += 1
            } else if length > 0 {
                lengths.append(length)
                length = 0
            }
        }
        if length > 0 {
            lengths.append(length)
        }

        return lengths
    }

    var solver = Solver(rows: rows, columns: columns)
    return solver.canSolvePuzzle()
}

private func solution(forTiles tiles: [TileState], size: Int) -> [UInt] {
    var solution: [UInt] = []

    var tileIndex = 0
    for rowIndex in 0..<size {
        var row: UInt = 0
        for columnIndex in 0..<size {
            if tiles[tileIndex] == .filled {
                row |= 1
            }
            row = row << 1
            tileIndex += 1
        }
        solution.append(row)
    }

    return solution
}
