//
//  ModelTests.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import Testing
@testable import Nonograms

struct ModelTests {
    @Test func testEmptyRowSequences() throws {
        let puzzle = Puzzle(size: 5, solution:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        #expect(puzzle.sequences(forRow: 0).elementsEqual([
            Sequence(length: 5, startIndex: 0, state: .missing),
        ]))
        #expect(puzzle.sequences(forRow: 1).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ]))
        #expect(puzzle.sequences(forRow: 2).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 2, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ]))
    }

    @Test func testCompleteRowSequences() throws {
        var puzzle = Puzzle(size: 5, solution:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        puzzle.solve()
        #expect(puzzle.sequences(forRow: 0).elementsEqual([
            Sequence(length: 5, startIndex: 0, state: .complete),
        ]))
        #expect(puzzle.sequences(forRow: 1).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ]))
        #expect(puzzle.sequences(forRow: 2).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 2, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ]))
    }

    @Test func testPartialRowSequences() throws {
        var puzzle = Puzzle(size: 5, solution:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        puzzle.fill(
            0b11110,
            0b10000,
            0b10001,
            0b00001,
            0b11011
        )
        #expect(puzzle.sequences(forRow: 0).elementsEqual([
            Sequence(length: 5, startIndex: 0, state: .missing),
        ]))
        #expect(puzzle.sequences(forRow: 1).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ]))
        #expect(puzzle.sequences(forRow: 2).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 2, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ]))
        #expect(puzzle.sequences(forRow: 3).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ]))
        #expect(puzzle.sequences(forRow: 4).elementsEqual([
            Sequence(length: 5, startIndex: 0, state: .missing),
        ]))
    }

    @Test func testPartialColumnSequences() throws {
        var puzzle = Puzzle(size: 5, solution:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        puzzle.fill(
            0b11101,
            0b00000,
            0b10001,
            0b10001,
            0b10111
        )
        #expect(puzzle.sequences(forColumn: 0).elementsEqual([
            Sequence(length: 5, startIndex: 0, state: .missing),
        ]))
        #expect(puzzle.sequences(forColumn: 1).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ]))
        #expect(puzzle.sequences(forColumn: 2).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 2, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ]))
        #expect(puzzle.sequences(forColumn: 3).elementsEqual([
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ]))
        #expect(puzzle.sequences(forColumn: 4).elementsEqual([
            Sequence(length: 5, startIndex: 0, state: .missing),
        ]))
    }
}
