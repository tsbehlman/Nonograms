//
//  Solver.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 6/20/25.
//

import SwiftUI

struct SolverAttempt: Codable {
    var axis: Axis
    var index: Int
    var minRanges: [Range<Int>]
    var maxRanges: [Range<Int>]
    var oldStates: [TileState]
    var newStates: [TileState]
    var madeProgress = false
    var complete = false
}

struct Solver: Codable {
    let rows: [[Int]]
    let columns: [[Int]]
    let minInferenceLength: Int
    var tiles: [TileState]
    var currentIndex = 0

    init(rows: [[Int]], columns: [[Int]], skillLevel: PuzzleDifficulty = .hard) {
        self.rows = rows
        self.columns = columns
        self.minInferenceLength = skillLevel.minInferenceLength(forSize: min(rows.count, columns.count))
        tiles = Array(repeating: .blank, count: rows.count * columns.count)
    }

    mutating func set(_ tileIndex: Int, to newState: TileState) {
        tiles[tileIndex] = newState
    }

    mutating func set(row: Int, column: Int, to newState: TileState) {
        set(row * columns.count + column, to: newState)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func make(attempt: inout SolverAttempt, forLengths lengths: [Int]) {
        guard lengths.only != 0 else {
            attempt.minRanges = []
            attempt.maxRanges = []
            attempt.newStates = Array(repeating: .blocked, count: attempt.oldStates.count)
            return
        }

        var states = attempt.oldStates
        var minRanges = [Range<Int>]()
        var index = 0
        for length in lengths {
            var startIndex = index
            while index - startIndex < length {
                let state = states[index]
                index += 1
                if state.isBlocked {
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
                if state.isBlocked {
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
                    minRange = minRange.maximumUpperBound(filledRange.upperBound)
                }
                if filledRange.lowerBound < maxRange.lowerBound {
                    maxRange = maxRange.minimumLowerBound(filledRange.lowerBound)
                }
                minRanges[matchingIndex] = minRange
                maxRanges[matchingIndex] = maxRange
            }
        }

        index = 0
        for (rangeIndex, minRange) in minRanges.enumerated() {
            let newRange = minRange.maximumLowerBound(index)
            minRanges[rangeIndex] = newRange
            index = newRange.upperBound + 1
        }

        index = states.count
        for (rangeIndex, maxRange) in maxRanges.enumerated().reversed() {
            let newRange = maxRange.minimumUpperBound(index)
            maxRanges[rangeIndex] = newRange
            index = newRange.lowerBound - 1
        }

        rangeBounds = zip(minRanges, maxRanges).map { (minRange, maxRange) in
            minRange.lowerBound..<maxRange.upperBound
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
            if let intersection = minRange.intersection(with: maxRange), intersection.length >= minInferenceLength || minRange == maxRange {
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

        attempt.minRanges = minRanges
        attempt.maxRanges = maxRanges
        attempt.newStates = states
    }

    private func check(attempt: inout SolverAttempt, forLengths lengths: [Int], at indices: some Sequence<Int>) {
        attempt.oldStates = indices.map { index in
            let state = tiles[index]
            if state == .error {
                return TileState.blocked
            } else {
                return state
            }
        }

        let blankIndices = attempt.oldStates.enumerated().compactMap { (index, state) in
            if state == .blank {
                return index
            } else {
                return nil
            }
        }

        if blankIndices.isEmpty {
            attempt.complete = true
            return
        }

        make(attempt: &attempt, forLengths: lengths)

        attempt.complete = true

        for index in blankIndices {
            if attempt.newStates[index] != .blank {
                attempt.madeProgress = true
            } else {
                attempt.complete = false
            }
        }
    }

    private func check(row index: Int) -> SolverAttempt {
        var attempt = SolverAttempt(axis: .horizontal, index: index, minRanges: [], maxRanges: [], oldStates: [], newStates: [])
        check(attempt: &attempt, forLengths: rows[index], at: indices(forRow: index))
        return attempt
    }

    private func check(column index: Int) -> SolverAttempt {
        var attempt = SolverAttempt(axis: .vertical, index: index, minRanges: [], maxRanges: [], oldStates: [], newStates: [])
        check(attempt: &attempt, forLengths: columns[index], at: indices(forColumn: index))
        return attempt
    }

    private mutating func applyAttempt(_ attempt: SolverAttempt, at indices: some Sequence<Int>) {
        for (tileIndex, newState) in zip(indices, attempt.newStates) {
            if newState != .blank {
                tiles[tileIndex] = newState
            }
        }
    }

    mutating func step() -> SolverAttempt? {
        var attempt: SolverAttempt
        for tileIndex in (currentIndex..<tiles.count).concat(0..<currentIndex) where tiles[tileIndex] == .blank {
            attempt = check(row: tileIndex / columns.count)
            if attempt.madeProgress {
                return attempt
            }

            attempt = check(column: tileIndex % columns.count)
            if attempt.madeProgress {
                return attempt
            }
        }
        return nil
    }

    mutating func canSolvePuzzle() -> Bool {
        var progressMade = false
        var rowIndices = IndexSet(integersIn: rows.indices)
        var columnIndices = IndexSet(integersIn: columns.indices)
        repeat {
            progressMade = false
            for rowIndex in rowIndices {
                let attempt = check(row: rowIndex)
                if attempt.madeProgress {
                    progressMade = true
                    applyAttempt(attempt, at: indices(forRow: attempt.index))
                }
                if attempt.complete {
                    rowIndices.remove(attempt.index)
                }
            }
            if rowIndices.isEmpty {
                return true
            }

            for columnIndex in columnIndices {
                let attempt = check(column: columnIndex)
                if attempt.madeProgress {
                    progressMade = true
                    applyAttempt(attempt, at: indices(forColumn: attempt.index))
                }
                if attempt.complete {
                    columnIndices.remove(attempt.index)
                }
            }
            if columnIndices.isEmpty {
                return true
            }
        } while progressMade
        return false
    }

    func indices(forRow rowIndex: Int) -> some Sequence<Int> {
        tiles.gridIndices(forRow: rowIndex, width: columns.count)
    }

    func indices(forColumn columnIndex: Int) -> some Sequence<Int> {
        tiles.gridIndices(forColumn: columnIndex, width: columns.count)
    }
}
