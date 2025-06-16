//
//  TestCase.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/15/25.
//

import Foundation

typealias Message = () -> String
typealias SingleParameterAssert<T> = (@autoclosure () -> T, @autoclosure Message, StaticString, UInt) -> Void
typealias DoubleParameterAssert<T, U> = (@autoclosure () -> T, @autoclosure () -> U, @autoclosure Message, StaticString, UInt) -> Void

class TestCase {
    let file: StaticString
    let line: UInt

    init(_ file: StaticString, _ line: UInt) {
        self.file = file
        self.line = line
    }

    func assert<T>(_ assertFunction: SingleParameterAssert<T>, _ arg1: @escaping @autoclosure () -> T, message: @escaping @autoclosure Message = "") {
        assertFunction(arg1(), message(), file, line)
    }

    func assert<T, U>(_ assertFunction: DoubleParameterAssert<T, U>, _ arg1: @escaping @autoclosure () -> T, _ arg2: @escaping @autoclosure () -> U, message: @escaping @autoclosure Message = "") {
        assertFunction(arg1(), arg2(), message(), file, line)
    }
}
