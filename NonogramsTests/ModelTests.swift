//
//  ModelTests.swift
//  NonogramsTests
//
//  Created by Trevor Behlman on 6/15/25.
//

import XCTest
@testable import Nonograms

final class ModelTests: XCTestCase {
    func testEmptyRowSequences() {
        let puzzle = Puzzle(size: 5, solution:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        XCTAssertEqual(puzzle.sequences(forRow: 0), [
            Sequence(length: 5, startIndex: 0, state: .missing),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 1), [
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 2), [
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 2, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ])
    }

    func testCompleteRowSequences() {
        var puzzle = Puzzle(size: 5, solution:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        puzzle.solve()
        XCTAssertEqual(puzzle.sequences(forRow: 0), [
            Sequence(length: 5, startIndex: 0, state: .complete),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 1), [
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 2), [
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 2, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ])
    }

    func testPartialRowSequences() {
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
        XCTAssertEqual(puzzle.sequences(forRow: 0), [
            Sequence(length: 5, startIndex: 0, state: .missing),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 1), [
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 2), [
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 2, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 3), [
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.sequences(forRow: 4), [
            Sequence(length: 5, startIndex: 0, state: .missing),
        ])
    }

    func testPartialColumnSequences() {
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
        XCTAssertEqual(puzzle.sequences(forColumn: 0), [
            Sequence(length: 5, startIndex: 0, state: .missing),
        ])
        XCTAssertEqual(puzzle.sequences(forColumn: 1), [
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 4, state: .missing),
        ])
        XCTAssertEqual(puzzle.sequences(forColumn: 2), [
            Sequence(length: 1, startIndex: 0, state: .complete),
            Sequence(length: 1, startIndex: 2, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.sequences(forColumn: 3), [
            Sequence(length: 1, startIndex: 0, state: .missing),
            Sequence(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.sequences(forColumn: 4), [
            Sequence(length: 5, startIndex: 0, state: .missing),
        ])
    }
}
