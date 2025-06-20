//
//  Sequence.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/20/25.
//

extension Sequence {
    func concat<Other: Sequence>(_ other: Other) -> ConcatenatedSequence<Self, Other> where Other.Element == Element {
        ConcatenatedSequence(self, other)
    }
}

struct ConcatenatedSequence<First: Sequence, Last: Sequence>: Sequence where First.Element == Last.Element {
    let first: First
    let last: Last

    init(_ first: First, _ last: Last) {
        self.first = first
        self.last = last
    }

    func makeIterator() -> Iterator {
        return Iterator(first, last)
    }

    struct Iterator: IteratorProtocol {
        var first: First.Iterator
        var last: Last.Iterator

        init(_ first: First, _ last: Last) {
            self.first = first.makeIterator()
            self.last = last.makeIterator()
        }

        mutating func next() -> First.Element? {
            return first.next() ?? last.next()
        }
    }
}
