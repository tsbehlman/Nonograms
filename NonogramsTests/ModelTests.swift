//
//  ModelTests.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import Testing
@testable import Nonograms

struct ModelTests {
    @Test func example() throws {
        let puzzle = Puzzle(size: 5, solution:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        #expect(puzzle.sequences(forColumn: 0).map { $0.length }.elementsEqual([5]))
        #expect(puzzle.sequences(forColumn: 1).map { $0.length }.elementsEqual([1, 1]))
        #expect(puzzle.sequences(forColumn: 2).map { $0.length }.elementsEqual([1, 1, 1]))
        #expect(puzzle.sequences(forColumn: 3).map { $0.length }.elementsEqual([1, 1]))
        #expect(puzzle.sequences(forColumn: 4).map { $0.length }.elementsEqual([5]))
    }
}
