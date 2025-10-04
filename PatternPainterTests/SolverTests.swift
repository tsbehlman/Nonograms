//
//  SolverTests.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 6/15/25.
//

import XCTest
@testable import Pattern_Painter

class CanSolvePuzzleTestCase: TestCase {
    var puzzle: Puzzle
    var solver: Solver

    init(puzzle: Puzzle, file: StaticString = #file, line: UInt = #line) {
        self.puzzle = puzzle
        self.solver = Solver(
            rows: puzzle.rowIndices.map { puzzle.segmentRanges(forRow: $0).map { $0.length } },
            columns: puzzle.columnIndices.map { puzzle.segmentRanges(forColumn: $0).map { $0.length } }
        )
        super.init(file, line)
    }

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

    func testAttemptCompleteness() {
        let testCase = CanSolvePuzzleTestCase(
            5,
            0b11010,
            0b10001,
            0b11101,
            0b11011,
            0b11111
        )
        let tileIndex = testCase.puzzle.tileIndex(row: 0, column: 3)
        testCase.puzzle.tiles[testCase.puzzle.tileIndex(row: 0, column: 3)] = .filled
        testCase.solver.set(tileIndex, to: .filled)
        let attempt = testCase.solver.step()
        XCTAssertEqual(attempt?.minRanges, [0..<2, 3..<4])
        XCTAssertEqual(attempt?.maxRanges, [0..<2, 3..<4])
    }

    func testSolverPerformance() throws {
        let puzzle = makeSolvablePuzzle(width: 15, height: 15)
        let testCase = CanSolvePuzzleTestCase(puzzle: puzzle)
        measure {
            XCTAssertTrue(testCase.solver.canSolvePuzzle())
        }
    }
}
