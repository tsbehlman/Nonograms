//
//  SolverTests.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/15/25.
//

import XCTest
@testable import Nonograms

class CanSolvePuzzleTestCase: TestCase {
    var puzzle: Puzzle
    var solver: Solver

    init(_ size: Int, _ solution: UInt..., file: StaticString = #file, line: UInt = #line) {
        let puzzle = Puzzle(size: size, data: solution)
        self.solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
        self.puzzle = puzzle
        super.init(file, line)
    }
}

final class SolverTests: XCTestCase {
    private static var canSolvePuzzleCases: [CanSolvePuzzleTestCase] = [
        .init(
            6,
            0b000000,
            0b011111,
            0b111100,
            0b110110,
            0b011101,
            0b111111
        ),
        .init(
            5,
            0b11111,
            0b10001,
            0b10101,
            0b10001,
            0b11111
        )
    ]
    
    func testCanSolvePuzzle() {
        for testCase in SolverTests.canSolvePuzzleCases {
            let didSolve = testCase.solver.canSolvePuzzle()
            testCase.assert(XCTAssertTrue, didSolve)
            testCase.puzzle.solve()
            testCase.assert(XCTAssertEqual, testCase.solver.tiles, testCase.puzzle.tiles)
        }
    }

    func testSolverPerformance() throws {
        let testCase = CanSolvePuzzleTestCase(
            6,
            0b000000,
            0b011111,
            0b111100,
            0b110110,
            0b011101,
            0b111111
        )
        self.measure {
            let _ = testCase.solver.canSolvePuzzle()
        }
    }
}
