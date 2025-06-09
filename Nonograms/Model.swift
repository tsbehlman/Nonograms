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

enum SequenceState {
    case missing
    case complete
}

struct Sequence: Identifiable, Equatable {
    let length: Int
    let startIndex: Int
    let state: SequenceState

    var endIndex: Int {
        startIndex + length
    }

    var range: Range<Int> {
        startIndex..<endIndex
    }

    var id: UInt {
        (0xFFFFFFFF >> (32 - length)) << startIndex
    }

    func with(state: SequenceState) -> Sequence {
        Sequence(length: length, startIndex: startIndex, state: state)
    }
}

struct Solver {
    let rows: [[Int]]
    let columns: [[Int]]

    var tiles: [TileState]
    var rowIndex = 0
    var columnIndex = 0
    var isSolvingRow = true

    init(rows: [[Int]], columns: [[Int]]) {
        self.rows = rows
        self.columns = columns
        tiles = Array(repeating: .blank, count: rows.count * columns.count)
    }

    private mutating func attemptSolution() -> Bool {
        var foundPartialSolution = false

        let sequences = self.sequences
        let states = self.states

        let sumOfSequences = sequences.reduce(0, +) + max(1, sequences.count) - 1
        if sumOfSequences == 0 {
            foundPartialSolution = fill(attempt: states.map { ($0.0, .blocked) })
        } else if sumOfSequences == length {
            var index = 0
            for sequence in sequences {
                for _ in 0..<sequence {
                    let (tileIndex, state) = states[index]
                    if state != .filled {
                        foundPartialSolution = true
                        tiles[tileIndex] = .filled
                    }
                    index += 1
                }
                if index < length {
                    let (tileIndex, state) = states[index]
                    if state != .blocked {
                        foundPartialSolution = true
                        tiles[tileIndex] = .blocked
                    }
                    index += 1
                }
            }
        } else {
            let tolerance = length - sumOfSequences
            var index = 0
            for sequence in sequences {
                for _ in 0..<tolerance {
                    index += 1
                }
                for _ in 0..<max(0, sequence - tolerance) {
                    let (tileIndex, state) = states[index]
                    if state != .filled {
                        foundPartialSolution = true
                        tiles[tileIndex] = .filled
                    }
                    index += 1
                }
                for _ in 0..<tolerance {
                    index += 1
                }
            }
        }

        if isSolvingRow {
            rowIndex += 1
            if rowIndex >= rows.count {
                rowIndex = 0
            }
            isSolvingRow = false
        } else {
            columnIndex += 1
            if columnIndex >= columns.count {
                columnIndex = 0
            }
            isSolvingRow = true
        }
        return foundPartialSolution
    }

    private mutating func fill(attempt: [(Int, TileState)]) -> Bool {
        var foundPartialSolution = false
        for (index, newState) in attempt {
            let state = tiles[index]
            if state == .blank && state != newState {
                tiles[index] = newState
                foundPartialSolution = true
            }
        }
        return foundPartialSolution
    }

    @discardableResult mutating func step() -> Bool {
        for _ in 0..<(rows.count + columns.count) {
            if attemptSolution() {
                return true
            }
        }
        return false
    }

    mutating func canSolvePuzzle() -> Bool {
        while step() {
            if tiles.allSatisfy({ $0 != .blank }) {
                return true
            }
        }
        return false
    }

    var sequences: [Int] {
        isSolvingRow ? rows[rowIndex] : columns[columnIndex]
    }

    var length: Int {
        isSolvingRow ? columns.count : rows.count
    }

    var states: [(Int, TileState)] {
        let indices: StrideTo<Int>
        if isSolvingRow {
            let startIndex = rowIndex * columns.count
            indices = stride(from: startIndex, to: startIndex + columns.count, by: 1)
        } else {
            indices = stride(from: columnIndex, to: columnIndex + columns.count * rows.count, by: columns.count)
        }
        return indices.map { ( $0, tiles[$0]) }
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

    var indices: Range<Int> {
        0..<size
    }

    mutating func set(row: Int, column: Int, to newState: TileState) {
        let tileIndex = row * size + column
        let currentState = tiles[tileIndex]
        switch (currentState, newState) {
        case (.blank, .blocked):
            tiles[row * size + column] = .blocked
        case (.blank, .filled):
            let columnBit = bit(forColumn: column)
            let shouldBeFilled = solution[row] & columnBit > 0
            if shouldBeFilled {
                tiles[row * size + column] = .filled
            } else {
                tiles[row * size + column] = .blocked
            }
        case (.blocked, .blocked):
            tiles[row * size + column] = .blank
        case (.blocked, _):
            break
        case (.filled, _):
            break
        case (_, .blank):
            break
        }
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
        let columnBit = bit(forColumn: columnIndex)
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
        for columnIndex in (0..<size).reversed() {
            if row & 1 == 1 {
                length += 1
            } else if length > 0 {
                sequences.append(Sequence(length: length, startIndex: columnIndex + 1, state: .missing))
                length = 0
            }
            row >>= 1
        }
        if length > 0 {
            sequences.append(Sequence(length: length, startIndex: 0, state: .missing))
        }
        sequences = sequences.reversed()

        if sequences.isEmpty {
            return [Sequence(length: 0, startIndex: 0, state: .complete)]
        }

        var iterator = BidirectionalZippedIterator(sequences.indices, completeSequences(forRow: rowIndex))

        while let (index, completeSequence) = iterator.next() {
            if sequences[index].range == completeSequence.range {
                sequences[index] = completeSequence
            } else if iterator.isAdvancing {
                iterator.flip()
            } else {
                break
            }
        }

        return sequences
    }

    private func completeSequences(forRow rowIndex: Int) -> [Sequence] {
        var sequences = [Sequence]()
        var length = 0
        for columnIndex in 0..<size {
            if tile(row: rowIndex, column: columnIndex) == .filled {
                length += 1
            } else if length > 0 {
                sequences.append(Sequence(length: length, startIndex: columnIndex - length, state: .complete))
                length = 0
            }
        }
        if length > 0 {
            sequences.append(Sequence(length: length, startIndex: size - length, state: .complete))
        }
        return sequences
    }

    func sequences(forColumn columnIndex: Int) -> [Sequence] {
        var sequences = [Sequence]()
        var length = 0
        let columnBit = bit(forColumn: columnIndex)
        for rowIndex in 0..<size {
            if solution[rowIndex] & columnBit > 0 {
                length += 1
            } else if length > 0 {
                sequences.append(Sequence(length: length, startIndex: rowIndex - length, state: .missing))
                length = 0
            }
        }
        if length > 0 {
            sequences.append(Sequence(length: length, startIndex: size - length, state: .missing))
        }

        if sequences.isEmpty {
            return [Sequence(length: 0, startIndex: 0, state: .complete)]
        }

        var iterator = BidirectionalZippedIterator(sequences.indices, completeSequences(forColumn: columnIndex))

        while let (index, completeSequence) = iterator.next() {
            if sequences[index].range == completeSequence.range {
                sequences[index] = completeSequence
            } else if iterator.isAdvancing {
                iterator.flip()
            } else {
                break
            }
        }

        return sequences
    }

    private func completeSequences(forColumn columnIndex: Int) -> [Sequence] {
        var sequences = [Sequence]()
        var length = 0
        for rowIndex in 0..<size {
            if tile(row: rowIndex, column: columnIndex) == .filled {
                length += 1
            } else if length > 0 {
                sequences.append(Sequence(length: length, startIndex: rowIndex - length, state: .complete))
                length = 0
            }
        }
        if length > 0 {
            sequences.append(Sequence(length: length, startIndex: size - length, state: .complete))
        }
        return sequences
    }

    mutating func solve() {
        fill(data: solution)
    }

    mutating func fill(_ data: UInt...) {
        fill(data: data)
    }

    func bit(forColumn columnIndex: Int) -> UInt {
        1 << (size - columnIndex - 1)
    }

    private mutating func fill(data: [UInt]) {
        var rowIndex = 0
        for var row in data {
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
