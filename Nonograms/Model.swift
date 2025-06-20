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

enum SegmentState {
    case missing
    case complete
}

struct Segment: Identifiable, Equatable {
    let length: Int
    let startIndex: Int
    let state: SegmentState

    var endIndex: Int {
        startIndex + length
    }

    var range: Range<Int> {
        startIndex..<endIndex
    }

    var id: UInt {
        (0xFFFFFFFF >> (32 - length)) << startIndex
    }

    func with(state: SegmentState) -> Segment {
        Segment(length: length, startIndex: startIndex, state: state)
    }
}

struct Solver {
    let rows: [[Int]]
    let columns: [[Int]]
    var tiles: [TileState]

    init(rows: [[Int]], columns: [[Int]]) {
        self.rows = rows
        self.columns = columns
        tiles = Array(repeating: .blank, count: rows.count * columns.count)
    }

    private mutating func makeAttempt(from initialStates: [TileState], forLengths lengths: [Int]) -> [TileState] {
        var states = initialStates

        if lengths.only == 0 {
            return Array(repeating: .blocked, count: states.count)
        } else {
            var minRanges = [Range<Int>]()
            var index = 0
            for length in lengths {
                var startIndex = index
                while index - startIndex < length {
                    let state = states[index]
                    index += 1
                    if state == .blocked {
                        startIndex = index
                    }
                }
                minRanges.append(startIndex..<(startIndex + length))
                index += 1
            }

            var maxRanges = [Range<Int>]()
            index = states.count - 1
            for length in lengths.reversed() {
                var endIndex = index
                while endIndex - index < length {
                    let state = states[index]
                    index -= 1
                    if state == .blocked {
                        endIndex = index
                    }
                }
                maxRanges.insert((endIndex - length + 1)..<(endIndex + 1), at: 0)
                index -= 1
            }

            var filledRanges = [Range<Int>]()
            var filledLength = 0
            index = 0
            for state in states {
                if state == .filled {
                    filledLength += 1
                } else if filledLength > 0 {
                    filledRanges.append((index - filledLength)..<index)
                    filledLength = 0
                }
                index += 1
            }
            if filledLength > 0 {
                filledRanges.append((index - filledLength)..<index)
            }

            var rangeBounds = zip(minRanges, maxRanges).map { (minRange, maxRange) in
                minRange.lowerBound..<maxRange.upperBound
            }

            for filledRange in filledRanges {
                if let matchingIndex = rangeBounds.onlyIndex(where: { $0.contains(filledRange) }) {
                    var minRange = minRanges[matchingIndex]
                    var maxRange = maxRanges[matchingIndex]
                    if filledRange.upperBound > minRange.upperBound {
                        minRange = minRange.moving(toAtMost: filledRange.upperBound)
                    }
                    if filledRange.lowerBound < maxRange.lowerBound {
                        maxRange = maxRange.moving(toAtLeast: filledRange.lowerBound)
                    }
                    minRanges[matchingIndex] = minRange
                    maxRanges[matchingIndex] = maxRange
                    rangeBounds[matchingIndex] = minRange.lowerBound..<maxRange.upperBound
                }
            }

            index = 0
            for rangeBound in rangeBounds {
                while index < rangeBound.lowerBound {
                    states[index] = .blocked
                    index += 1
                }
                index = rangeBound.upperBound
            }
            while index < states.count {
                states[index] = .blocked
                index += 1
            }

            for (minRange, maxRange) in zip(minRanges, maxRanges) {
                if let intersection = minRange.intersection(with: maxRange) {
                    for index in intersection {
                        states[index] = .filled
                    }
                    if minRange == maxRange {
                        if minRange.lowerBound > 0 {
                            states[minRange.lowerBound - 1] = .blocked
                        }
                        if minRange.upperBound < states.count - 1 {
                            states[minRange.upperBound] = .blocked
                        }
                    }
                }
            }
        }

        return states
    }

    private mutating func attemptSolution(forLengths lengths: [Int], at indices: some Sequence<Int>) -> Bool {
        var foundPartialSolution = false

        let oldStates = indices.map { tiles[$0] }
        let newStates = makeAttempt(from: oldStates, forLengths: lengths)

        for (stateIndex, tileIndex) in indices.enumerated() {
            if newStates[stateIndex] != oldStates[stateIndex] {
                foundPartialSolution = true
                tiles[tileIndex] = newStates[stateIndex]
            }
        }

        return foundPartialSolution
    }

    @discardableResult mutating func step(startingAt tileIndex: Int = 0) -> Int? {
        for tileIndex in (tileIndex..<tiles.count).concat(0..<tileIndex) where tiles[tileIndex] == .blank {
            let rowIndex = tileIndex / columns.count
            if attemptSolution(forLengths: rows[rowIndex], at: indices(forRow: rowIndex)) {
                return tileIndex
            }
            let columnIndex = tileIndex % columns.count
            if attemptSolution(forLengths: columns[columnIndex], at: indices(forColumn: columnIndex)) {
                return tileIndex
            }
        }
        return nil
    }

    mutating func canSolvePuzzle() -> Bool {
        var index = 0
        while let nextIndex = step(startingAt: index) {
            if tiles.allSatisfy({ $0 != .blank }) {
                return true
            }
            index = nextIndex
        }
        return false
    }

    func indices(forRow rowIndex: Int) -> StrideTo<Int> {
        let startIndex = rowIndex * columns.count
        return stride(from: startIndex, to: startIndex + columns.count, by: 1)
    }

    func indices(forColumn columnIndex: Int) -> StrideTo<Int> {
        return stride(from: columnIndex, to: columnIndex + columns.count * rows.count, by: columns.count)
    }
}

struct Puzzle {
    let size: Int
    var tiles: [TileState]
    let solution: [UInt]

    init(size: Int, solution: [UInt]) {
        assert(size <= 32, "Puzzles larger than 32x32 are not supported")
        assert(solution.count == size, "Puzzles must be square, you must provide data for each row")

        self.size = Int(size)
        self.solution = solution
        tiles = Array<TileState>(repeating: .blank, count: Int(size) * Int(size))
    }

    init(size: Int, solution: UInt...) {
        self.init(size: size, solution: solution)
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

    func segments(forRow rowIndex: Int) -> [Segment] {
        var segments = [Segment]()
        var length = 0
        var row = solution[rowIndex]
        for columnIndex in (0..<size).reversed() {
            if row & 1 == 1 {
                length += 1
            } else if length > 0 {
                segments.append(Segment(length: length, startIndex: columnIndex + 1, state: .missing))
                length = 0
            }
            row >>= 1
        }
        if length > 0 {
            segments.append(Segment(length: length, startIndex: 0, state: .missing))
        }
        segments = segments.reversed()

        if segments.isEmpty {
            return [Segment(length: 0, startIndex: 0, state: .complete)]
        }

        var iterator = BidirectionalZippedIterator(segments.indices, completeSegments(forRow: rowIndex))

        while let (index, completeSegment) = iterator.next() {
            if segments[index].range == completeSegment.range {
                segments[index] = completeSegment
            } else if iterator.isAdvancing {
                iterator.flip()
            } else {
                break
            }
        }

        return segments
    }

    private func completeSegments(forRow rowIndex: Int) -> [Segment] {
        var segments = [Segment]()
        var length = 0
        for columnIndex in 0..<size {
            if tile(row: rowIndex, column: columnIndex) == .filled {
                length += 1
            } else if length > 0 {
                segments.append(Segment(length: length, startIndex: columnIndex - length, state: .complete))
                length = 0
            }
        }
        if length > 0 {
            segments.append(Segment(length: length, startIndex: size - length, state: .complete))
        }
        return segments
    }

    func segments(forColumn columnIndex: Int) -> [Segment] {
        var segments = [Segment]()
        var length = 0
        let columnBit = bit(forColumn: columnIndex)
        for rowIndex in 0..<size {
            if solution[rowIndex] & columnBit > 0 {
                length += 1
            } else if length > 0 {
                segments.append(Segment(length: length, startIndex: rowIndex - length, state: .missing))
                length = 0
            }
        }
        if length > 0 {
            segments.append(Segment(length: length, startIndex: size - length, state: .missing))
        }

        if segments.isEmpty {
            return [Segment(length: 0, startIndex: 0, state: .complete)]
        }

        var iterator = BidirectionalZippedIterator(segments.indices, completeSegments(forColumn: columnIndex))

        while let (index, completeSegment) = iterator.next() {
            if segments[index].range == completeSegment.range {
                segments[index] = completeSegment
            } else if iterator.isAdvancing {
                iterator.flip()
            } else {
                break
            }
        }

        return segments
    }

    private func completeSegments(forColumn columnIndex: Int) -> [Segment] {
        var segments = [Segment]()
        var length = 0
        for rowIndex in 0..<size {
            if tile(row: rowIndex, column: columnIndex) == .filled {
                length += 1
            } else if length > 0 {
                segments.append(Segment(length: length, startIndex: rowIndex - length, state: .complete))
                length = 0
            }
        }
        if length > 0 {
            segments.append(Segment(length: length, startIndex: size - length, state: .complete))
        }
        return segments
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
