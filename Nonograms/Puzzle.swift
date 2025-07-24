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
    case error

    var isBlocked: Bool {
        return self == .blocked || self == .error
    }
}

enum SegmentState {
    case missing
    case complete
}

struct Segment: Identifiable, Equatable {
    let range: Range<Int>
    let state: SegmentState

    init(_ range: Range<Int>, state: SegmentState) {
        self.range = range
        self.state = state
    }

    init(length: Int, startIndex: Int, state: SegmentState) {
        self.init(startIndex..<(startIndex + length), state: state)
    }

    var id: UInt {
        (0xFFFFFFFF >> (32 - range.length)) << range.lowerBound
    }

    func with(state: SegmentState) -> Segment {
        Segment(range, state: state)
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

    var rowIndices: Range<Int> {
        0..<size
    }

    var columnIndices: Range<Int> {
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
                tiles[tileIndex] = .error
            }
        case (.blocked, .blocked):
            if !holding {
                tiles[tileIndex] = .blank
            }
        case (.blocked, .blank):
            tiles[tileIndex] = .blank
        case (_, .error):
            tiles[tileIndex] = .error
        case (.blocked, _):
            break
        case (.error, _):
            break
        case (.filled, _):
            break
        case (_, .blank):
            break
        }
    }

    private func segmentRanges(in tileIndices: some Sequence<Int>) -> [Range<Int>] {
        var ranges = [Range<Int>]()
        var startIndex = 0
        var endIndex = 0
        for tileIndex in tileIndices {
            if solution[tileIndex] == .filled {
                endIndex += 1
            } else if endIndex > startIndex {
                ranges.append(startIndex..<endIndex)
                startIndex = endIndex + 1
                endIndex = startIndex
            } else {
                startIndex += 1
                endIndex = startIndex
            }
        }
        if endIndex > startIndex {
            ranges.append(startIndex..<endIndex)
        }

        return ranges
    }

    func segmentRanges(forRow rowIndex: Int) -> [Range<Int>] {
        segmentRanges(in: solution.gridIndices(forRow: rowIndex, width: size))
    }

    func segmentRanges(forColumn columnIndex: Int) -> [Range<Int>] {
        segmentRanges(in: solution.gridIndices(forColumn: columnIndex, width: size))
    }

    private func segments(in tileIndices: some Sequence<Int>) -> [Segment] {
        var segments = segmentRanges(in: tileIndices).map {
            Segment($0, state: .missing)
        }

        if segments.isEmpty {
            segments.append(Segment(0..<0, state: .complete))
        }

        var tileIndices = ArraySlice(tileIndices)
        var lastTile: TileState = .blocked
        var segmentIndex = segments.startIndex
        while !tileIndices.isEmpty {
            let tileIndex = tileIndices.removeFirst()
            let nextTile = tiles[tileIndex]
            guard solution[tileIndex] == nextTile || (solution[tileIndex].isBlocked && nextTile.isBlocked) else { break }
            let isClosingSegment = nextTile.isBlocked && lastTile == .filled
            let isLastSegment = nextTile == .filled && tileIndices.isEmpty
            if isClosingSegment || isLastSegment {
                segments[segmentIndex] = segments[segmentIndex].with(state: .complete)
                segmentIndex += 1
            }
            lastTile = nextTile
        }

        lastTile = .blocked
        segmentIndex = segments.endIndex - 1
        while !tileIndices.isEmpty {
            let tileIndex = tileIndices.removeLast()
            let nextTile = tiles[tileIndex]
            guard solution[tileIndex] == nextTile else { break }
            if nextTile == .blank {
                break
            } else if nextTile.isBlocked && lastTile == .filled {
                segments[segmentIndex] = segments[segmentIndex].with(state: .complete)
                segmentIndex -= 1
            }
            lastTile = nextTile
        }

        return segments
    }

    func segments(forRow rowIndex: Int) -> [Segment] {
        segments(in: solution.gridIndices(forRow: rowIndex, width: size))
    }

    func segments(forColumn columnIndex: Int) -> [Segment] {
        segments(in: solution.gridIndices(forColumn: columnIndex, width: size))
    }

    func isSolved() -> Bool {
        zip(tiles, solution).allSatisfy { actual, expected in
            expected != .filled || actual == .filled
        }
    }

    mutating func solve() {
        for (index, (current, solved)) in zip(tiles, solution).enumerated() {
            if solved == .filled {
                tiles[index] = .filled
            } else if current != .error {
                tiles[index] = .blocked
            }
        }
    }

    mutating func fill(_ data: UInt...) {
        fillTiles(&tiles, with: data, size: size)
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
