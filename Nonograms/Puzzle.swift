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

struct Puzzle {
    let size: Int
    var tiles: [TileState]
    let solution: [TileState]

    init(size: Int, solution: [TileState]) {
        self.size = size
        self.solution = solution
        self.tiles = Array<TileState>(repeating: .blank, count: Int(size) * Int(size))
    }

    init(size: Int, data: [UInt]) {
        assert(size <= 32, "Puzzles larger than 32x32 are not supported")
        assert(data.count == size, "Puzzles must be square, you must provide data for each row")

        var solution = Array<TileState>(repeating: .blank, count: Int(size) * Int(size))
        fillTiles(&solution, with: data, size: size)
        self.init(size: size, solution: solution)
    }

    init(size: Int, data: UInt...) {
        self.init(size: size, data: data)
    }

    func tile(row: Int, column: Int) -> TileState {
        tiles[row * size + column]
    }

    var indices: Range<Int> {
        0..<size
    }

    mutating func set(row: Int, column: Int, to newState: TileState, holding: Bool = false) {
        let tileIndex = row * size + column
        let currentState = tiles[tileIndex]
        switch (currentState, newState) {
        case (.blank, .blocked):
            tiles[row * size + column] = .blocked
        case (.blank, .filled):
            if solution[tileIndex] == .filled {
                tiles[tileIndex] = .filled
            } else {
                tiles[tileIndex] = .blocked
            }
        case (.blocked, .blocked):
            if !holding {
                tiles[tileIndex] = .blank
            }
        case (.blocked, .blank):
            tiles[tileIndex] = .blank
        case (.blocked, _):
            break
        case (.filled, _):
            break
        case (_, .blank):
            break
        }
    }

    func segments(forRow rowIndex: Int) -> [Segment] {
        var segments = [Segment]()
        var length = 0
        for columnIndex in (0..<size).reversed() {
            let tileIndex = rowIndex * size + columnIndex
            if solution[tileIndex] == .filled {
                length += 1
            } else if length > 0 {
                segments.append(Segment(length: length, startIndex: columnIndex + 1, state: .missing))
                length = 0
            }
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
        for rowIndex in 0..<size {
            let tileIndex = rowIndex * size + columnIndex
            if solution[tileIndex] == .filled {
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
        tiles = solution
    }

    mutating func fill(_ data: UInt...) {
        fillTiles(&tiles, with: data, size: size)
    }

    func bit(forColumn columnIndex: Int) -> UInt {
        1 << (size - columnIndex - 1)
    }
}

private func fillTiles(_ tiles: inout [TileState], with data: [UInt], size: Int) {
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
