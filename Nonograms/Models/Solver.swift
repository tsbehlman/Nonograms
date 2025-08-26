//
//  Solver.swift
//  Nonograms
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
}

struct Solver: Codable {
    let rows: [[Int]]
    let columns: [[Int]]
    var tiles: [TileState]
    var currentIndex = 0

    init(rows: [[Int]], columns: [[Int]]) {
        self.rows = rows
        self.columns = columns
        tiles = Array(repeating: .blank, count: rows.count * columns.count)
    }

    mutating func set(_ tileIndex: Int, to newState: TileState) {
        tiles[tileIndex] = newState
    }

    mutating func set(row: Int, column: Int, to newState: TileState) {
        set(row * columns.count + column, to: newState)
    }

    private mutating func make(attempt: inout SolverAttempt, forLengths lengths: [Int]) {
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

        attempt.minRanges = minRanges
        attempt.maxRanges = maxRanges
        attempt.newStates = states
    }

    private mutating func check(attempt: inout SolverAttempt, forLengths lengths: [Int], at indices: some Sequence<Int>) -> Bool {
        attempt.oldStates = indices.map { index in
            let state = tiles[index]
            if state == .error {
                return TileState.blocked
            } else {
                return state
            }
        }

        make(attempt: &attempt, forLengths: lengths)

        for (oldState, newState) in zip(attempt.oldStates, attempt.newStates) {
            if oldState != newState {
                return true
            }
        }

        return false
    }

    private mutating func applyAttempt(_ attempt: SolverAttempt, at indices: some Sequence<Int>) {
        for (stateIndex, tileIndex) in indices.enumerated() {
            let oldState = tiles[tileIndex]
            let newState = attempt.newStates[stateIndex]
            if newState != oldState && oldState != .error {
                tiles[tileIndex] = attempt.newStates[stateIndex]
            }
        }
    }

    @discardableResult mutating func step() -> SolverAttempt? {
        var attempt = SolverAttempt(axis: .horizontal, index: 0, minRanges: [], maxRanges: [], oldStates: [], newStates: [])
        for tileIndex in (currentIndex..<tiles.count).concat(0..<currentIndex) where tiles[tileIndex] == .blank {
            attempt.axis = .horizontal
            attempt.index = tileIndex / columns.count
            if check(attempt: &attempt, forLengths: rows[attempt.index], at: indices(forRow: attempt.index)) {
                return attempt
            }

            attempt.axis = .vertical
            attempt.index = tileIndex % columns.count
            if check(attempt: &attempt, forLengths: columns[attempt.index], at: indices(forColumn: attempt.index)) {
                return attempt
            }
        }
        return nil
    }

    mutating func canSolvePuzzle() -> Bool {
        while let nextAttempt = step() {
            if nextAttempt.axis == .horizontal {
                applyAttempt(nextAttempt, at: indices(forRow: nextAttempt.index))
            } else {
                applyAttempt(nextAttempt, at: indices(forColumn: nextAttempt.index))
            }
            if tiles.allSatisfy({ $0 != .blank }) {
                return true
            }
        }
        return false
    }

    func indices(forRow rowIndex: Int) -> some Sequence<Int> {
        tiles.gridIndices(forRow: rowIndex, width: columns.count)
    }

    func indices(forColumn columnIndex: Int) -> some Sequence<Int> {
        tiles.gridIndices(forColumn: columnIndex, width: columns.count)
    }
}
