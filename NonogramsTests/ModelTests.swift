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
        #expect(puzzle.sequences(forColumn: 0).elementsEqual([5]))
        #expect(puzzle.sequences(forColumn: 1).elementsEqual([1, 1]))
        #expect(puzzle.sequences(forColumn: 2).elementsEqual([1, 1, 1]))
        #expect(puzzle.sequences(forColumn: 3).elementsEqual([1, 1]))
        #expect(puzzle.sequences(forColumn: 4).elementsEqual([5]))
    }
}
