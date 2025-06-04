//
//  BidirectionalZippedIterator.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/3/25.
//

struct BidirectionalZippedIterator<LeftElement, RightElement, LeftCollection: RandomAccessCollection<LeftElement>, RightCollection: RandomAccessCollection<RightElement>>: IteratorProtocol {
    let left: LeftCollection
    let right: RightCollection
    var leftStartIndex: LeftCollection.Index
    var rightStartIndex: RightCollection.Index
    var leftEndIndex: LeftCollection.Index
    var rightEndIndex: RightCollection.Index
    var isAdvancing = true
    private var isStopped = false

    init(_ left: LeftCollection, _ right: RightCollection) {
        self.left = left
        self.right = right
        leftStartIndex = left.startIndex
        rightStartIndex = right.startIndex
        leftEndIndex = left.index(before: left.endIndex)
        rightEndIndex = right.index(before: right.endIndex)
    }

    mutating func flip() {
        if isAdvancing && leftStartIndex > left.startIndex {
            leftStartIndex = left.index(before: leftStartIndex)
            rightStartIndex = right.index(before: rightStartIndex)
        } else if !isAdvancing && leftEndIndex < left.index(before: left.endIndex) {
            leftEndIndex = left.index(after: leftEndIndex)
            rightEndIndex = right.index(after: rightEndIndex)
        }
        isAdvancing = !isAdvancing
    }

    mutating func next() -> (LeftElement, RightElement)? {
        if isStopped || leftStartIndex > leftEndIndex || rightStartIndex > rightEndIndex {
            return nil
        }
        if isAdvancing {
            let value = (left[leftStartIndex], right[rightStartIndex])
            leftStartIndex = left.index(after: leftStartIndex)
            rightStartIndex = right.index(after: rightStartIndex)
            return value
        } else {
            let value = (left[leftEndIndex], right[rightEndIndex])
            if leftEndIndex == left.startIndex || rightEndIndex == right.startIndex {
                // index(before) crashes when the first index is passed, so there's no way for the index to record if we're underflowing
                isStopped = true
            } else {
                leftEndIndex = left.index(before: leftEndIndex)
                rightEndIndex = right.index(before: rightEndIndex)
            }
            return value
        }
    }
}
