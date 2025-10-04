//
//  ModelTests.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 6/15/25.
//

import XCTest
@testable import Pattern_Painter

final class ModelTests: XCTestCase {
    func testEmptyRowSegments() {
        let puzzle = Puzzle(size: 5, data:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b11001,
                                0b11111
        )
        XCTAssertEqual(puzzle.segments(forRow: 0), [
            Segment(length: 5, startIndex: 0, state: .missing),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 1), [
            Segment(length: 1, startIndex: 0, state: .missing),
            Segment(length: 1, startIndex: 4, state: .missing),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 2), [
            Segment(length: 1, startIndex: 0, state: .missing),
            Segment(length: 1, startIndex: 2, state: .missing),
            Segment(length: 1, startIndex: 4, state: .missing),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 3), [
            Segment(length: 2, startIndex: 0, state: .missing),
            Segment(length: 1, startIndex: 4, state: .missing),
        ])
    }

    func testCompleteRowSegments() {
        var puzzle = Puzzle(size: 5, data:
                                0b11111,
                                0b10001,
                                0b10101,
                                0b10001,
                                0b11111
        )
        puzzle.solve()
        XCTAssertEqual(puzzle.segments(forRow: 0), [
            Segment(length: 5, startIndex: 0, state: .complete),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 1), [
            Segment(length: 1, startIndex: 0, state: .complete),
            Segment(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 2), [
            Segment(length: 1, startIndex: 0, state: .complete),
            Segment(length: 1, startIndex: 2, state: .complete),
            Segment(length: 1, startIndex: 4, state: .complete),
        ])
    }

    func testPartialRowSegments() {
        var puzzle = Puzzle(size: 5, data:
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
        XCTAssertEqual(puzzle.segments(forRow: 0), [
            Segment(length: 5, startIndex: 0, state: .missing),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 1), [
            Segment(length: 1, startIndex: 0, state: .complete),
            Segment(length: 1, startIndex: 4, state: .missing),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 2), [
            Segment(length: 1, startIndex: 0, state: .complete),
            Segment(length: 1, startIndex: 2, state: .missing),
            Segment(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 3), [
            Segment(length: 1, startIndex: 0, state: .missing),
            Segment(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.segments(forRow: 4), [
            Segment(length: 5, startIndex: 0, state: .missing),
        ])
    }

    func testPartialColumnSegments() {
        var puzzle = Puzzle(size: 5, data:
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
        XCTAssertEqual(puzzle.segments(forColumn: 0), [
            Segment(length: 5, startIndex: 0, state: .missing),
        ])
        XCTAssertEqual(puzzle.segments(forColumn: 1), [
            Segment(length: 1, startIndex: 0, state: .complete),
            Segment(length: 1, startIndex: 4, state: .missing),
        ])
        XCTAssertEqual(puzzle.segments(forColumn: 2), [
            Segment(length: 1, startIndex: 0, state: .complete),
            Segment(length: 1, startIndex: 2, state: .missing),
            Segment(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.segments(forColumn: 3), [
            Segment(length: 1, startIndex: 0, state: .missing),
            Segment(length: 1, startIndex: 4, state: .complete),
        ])
        XCTAssertEqual(puzzle.segments(forColumn: 4), [
            Segment(length: 5, startIndex: 0, state: .missing),
        ])
    }
}
