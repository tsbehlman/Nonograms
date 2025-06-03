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

struct Sequence: Identifiable {
    let length: Int
    let startIndex: Int

    var id: UInt {
        (0xFFFFFFFF >> (32 - length)) << startIndex
    }
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

    func sequences(forRow rowIndex: Int) -> [Sequence] {
        var sequences = [Sequence]()
        var length = 0
        var row = solution[rowIndex]
        for columnIndex in 0..<size {
            if row & 1 == 1 {
                length += 1
            } else if length > 0 {
                sequences.append(Sequence(length: length, startIndex: columnIndex - length))
                length = 0
            }
            row >>= 1
        }
        if length > 0 {
            sequences.append(Sequence(length: length, startIndex: size - length))
        }
        return sequences.reversed()
    }

    func sequences(forColumn columnIndex: Int) -> [Sequence] {
        var sequences = [Sequence]()
        var length = 0
        let columnBit: UInt = 1 << columnIndex
        for rowIndex in 0..<size {
            if solution[rowIndex] & columnBit > 0 {
                length += 1
            } else if length > 0 {
                sequences.append(Sequence(length: length, startIndex: rowIndex - length))
                length = 0
            }
        }
        if length > 0 {
            sequences.append(Sequence(length: length, startIndex: size - length))
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
