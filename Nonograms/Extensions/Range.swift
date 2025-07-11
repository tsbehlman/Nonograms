//
//  Range.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/9/25.
//

extension Range {
    func intersection(with other: Range<Bound>) -> Range<Bound>? {
        let newLowerBound = Swift.max(lowerBound, other.lowerBound)
        let newUpperBound = Swift.min(upperBound, other.upperBound)
        if newLowerBound < newUpperBound {
            return newLowerBound..<newUpperBound
        } else {
            return nil
        }
    }

    func contains(_ other: Range<Bound>) -> Bool {
        return lowerBound <= other.lowerBound && upperBound >= other.upperBound
    }
}

extension Range where Bound: Numeric {
    var length: Bound {
        upperBound - lowerBound
    }

    func moving(toAtLeast minIndex: Bound) -> Self {
        let newLowerBound = Swift.min(lowerBound, minIndex)
        return newLowerBound..<(newLowerBound + length)
    }

    func moving(toAtMost maxIndex: Bound) -> Self {
        let newUpperBound = Swift.max(upperBound, maxIndex)
        return (newUpperBound - length)..<newUpperBound
    }
}
