//
//  Model.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

enum TileState {
    case blank
    case filled
    case blocked
}

struct Puzzle {
    let size: Int
    var tiles: [TileState]
    let solution: [UInt]

    init(size: Int, solution: UInt...) {
        assert(size <= 32, "Puzzles larger than 32x32 are not supported")
        assert(solution.count == size, "Puzzles must be square, you must provide data for each row")

        self.size = Int(size)
        self.solution = solution
        tiles = Array<TileState>(repeating: .blank, count: Int(size) * Int(size))
    }

    func tile(row: Int, column: Int) -> TileState {
        tiles[row * size + column]
    }

    mutating func set(row: Int, column: Int, to state: TileState) {
        tiles[row * size + column] = state
    }

    func validate(row rowIndex: Int) -> Bool {
        var row = solution[rowIndex]
        for columnIndex in (0..<size).reversed() {
            let shouldBeFilled = row & 1 == 1
            let isFilled = tile(row: rowIndex, column: columnIndex) == .filled
            if shouldBeFilled != isFilled {
                return false
            }
            row >>= 1
        }
        return true
    }

    func validate(column columnIndex: Int) -> Bool {
        let columnBit: UInt = 1 << columnIndex
        for rowIndex in 0..<size {
            let shouldBeFilled = solution[rowIndex] & columnBit > 0
            let isFilled = tile(row: rowIndex, column: columnIndex) == .filled
            if shouldBeFilled != isFilled {
                return false
            }
        }
        return true
    }

    func sequences(forRow rowIndex: Int) -> [Int] {
        var sequences = [Int]()
        var currentSequence = 0
        var row = solution[rowIndex]
        for _ in 0..<size {
            if row & 1 == 1 {
                currentSequence += 1
            } else if currentSequence > 0 {
                sequences.append(currentSequence)
                currentSequence = 0
            }
            row >>= 1
        }
        if currentSequence > 0 {
            sequences.append(currentSequence)
        }
        return sequences.reversed()
    }

    func sequences(forColumn columnIndex: Int) -> [Int] {
        var sequences = [Int]()
        var currentSequence = 0
        let columnBit: UInt = 1 << columnIndex
        for rowIndex in 0..<size {
            if solution[rowIndex] & columnBit > 0 {
                currentSequence += 1
            } else if currentSequence > 0 {
                sequences.append(currentSequence)
                currentSequence = 0
            }
        }
        if currentSequence > 0 {
            sequences.append(currentSequence)
        }
        return sequences
    }

    mutating func solve() {
        var rowIndex = 0
        for var row in solution {
            for index in (0..<size).reversed() {
                if row & 1 == 1 {
                    tiles[rowIndex + index] = .filled
                } else {
                    tiles[rowIndex + index] = .blocked
                }
                row >>= 1
            }
            rowIndex += size
        }
    }
}
