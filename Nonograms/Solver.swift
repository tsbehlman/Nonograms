//
//  Solver.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/20/25.
//

struct Solver {
    let rows: [[Int]]
    let columns: [[Int]]
    var tiles: [TileState]

    init(rows: [[Int]], columns: [[Int]]) {
        self.rows = rows
        self.columns = columns
        tiles = Array(repeating: .blank, count: rows.count * columns.count)
    }

    mutating func set(row: Int, column: Int, to newState: TileState) {
        tiles[row * columns.count + column] = newState
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
