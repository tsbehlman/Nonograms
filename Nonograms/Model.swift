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

    func moving(toAtLeast minIndex: Int) -> Segment {
        Segment(length: length, startIndex: min(startIndex, minIndex), state: state)
    }

    func moving(toAtMost maxIndex: Int) -> Segment {
        Segment(length: length, startIndex: max(endIndex, maxIndex) - length, state: state)
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

        let segments = self.segments
        let states = self.states

        if segments.only == 0 {
            foundPartialSolution = fill(attempt: states.map { ($0.0, .blocked) })
        } else {
            var minSegments = [Segment]()
            var index = 0
            for length in segments {
                var startIndex = index
                while index - startIndex < length {
                    let (_, state) = states[index]
                    index += 1
                    if state == .blocked {
                        startIndex = index
                    }
                }
                minSegments.append(Segment(length: length, startIndex: startIndex, state: .missing))
                index += 1
            }

            var maxSegments = [Segment]()
            index = states.count - 1
            for length in segments.reversed() {
                var endIndex = index
                while endIndex - index < length {
                    let (_, state) = states[index]
                    index -= 1
                    if state == .blocked {
                        endIndex = index
                    }
                }
                maxSegments.insert(Segment(length: length, startIndex: endIndex - length + 1, state: .missing), at: 0)
                index -= 1
            }

            var filledRanges = [Range<Int>]()
            var length = 0
            index = 0
            for (_, state) in states {
                if state == .filled {
                   length += 1
                } else if length > 0 {
                    filledRanges.append((index - length)..<index)
                    length = 0
                }
                index += 1
            }
            if length > 0 {
                filledRanges.append((index - length)..<index)
            }

            var segmentBounds = zip(minSegments, maxSegments).map { (minSegment, maxSegment) in
                minSegment.startIndex..<maxSegment.endIndex
            }

            for filledRange in filledRanges {
                if let matchingIndex = segmentBounds.onlyIndex(where: { $0.contains(filledRange) }) {
                    if filledRange.upperBound > minSegments[matchingIndex].endIndex {
                        var nextPosition = filledRange.upperBound
                        var newSegment = minSegments[matchingIndex].moving(toAtMost: nextPosition)
                        minSegments[matchingIndex] = newSegment
                        segmentBounds[matchingIndex] = newSegment.startIndex..<maxSegments[matchingIndex].endIndex
                        for segmentIndex in (matchingIndex + 1)..<segments.count {
                            nextPosition = max(newSegment.endIndex + 1, minSegments[segmentIndex].startIndex)
                            newSegment = Segment(length: minSegments[segmentIndex].length, startIndex: nextPosition, state: .missing)
                            minSegments[segmentIndex] = newSegment
                            segmentBounds[segmentIndex] = newSegment.startIndex..<maxSegments[segmentIndex].endIndex
                        }
                    }
                    if filledRange.lowerBound < maxSegments[matchingIndex].startIndex {
                        var nextPosition = filledRange.lowerBound
                        var newSegment = maxSegments[matchingIndex].moving(toAtLeast: nextPosition)
                        maxSegments[matchingIndex] = newSegment
                        for segmentIndex in (0..<matchingIndex).reversed() {
                            nextPosition = min(newSegment.startIndex - 1, maxSegments[segmentIndex].endIndex)
                            newSegment = Segment(length: maxSegments[segmentIndex].length, startIndex: max(0, nextPosition - maxSegments[segmentIndex].length), state: .missing)
                            maxSegments[segmentIndex] = newSegment
                            segmentBounds[segmentIndex] = minSegments[segmentIndex].startIndex..<newSegment.endIndex
                        }
                    }
                }
            }

            index = 0
            for segmentBound in segmentBounds {
                while index < segmentBound.lowerBound {
                    let (tileIndex, state) = states[index]
                    if state != .blocked {
                        foundPartialSolution = true
                        tiles[tileIndex] = .blocked
                    }
                    index += 1
                }
                index = segmentBound.upperBound
            }
            while index < states.count {
                let (tileIndex, state) = states[index]
                if state != .blocked {
                    foundPartialSolution = true
                    tiles[tileIndex] = .blocked
                }
                index += 1
            }

            for (minSegment, maxSegment) in zip(minSegments, maxSegments) {
                if let intersection = minSegment.range.intersection(with: maxSegment.range) {
                    for index in intersection {
                        let (tileIndex, state) = states[index]
                        if state != .filled {
                            foundPartialSolution = true
                            tiles[tileIndex] = .filled
                        }
                    }
                    if minSegment == maxSegment {
                        if minSegment.startIndex > 0 {
                            let (tileIndex, state) = states[minSegment.startIndex - 1]
                            if state != .blocked {
                                foundPartialSolution = true
                                tiles[tileIndex] = .blocked
                            }
                        }
                        if minSegment.endIndex < states.count - 1 {
                            let (tileIndex, state) = states[minSegment.endIndex]
                            if state != .blocked {
                                foundPartialSolution = true
                                tiles[tileIndex] = .blocked
                            }
                        }
                    }
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

    var segments: [Int] {
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
