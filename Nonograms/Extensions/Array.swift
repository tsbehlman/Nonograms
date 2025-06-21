//
//  Array.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/8/25.
//

extension Array {
    var only: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }

    func onlyIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        if let firstIndex = try self.firstIndex(where: predicate), let lastIndex = try lastIndex(where: predicate), firstIndex == lastIndex {
            return firstIndex
        }
        return nil
    }

    func gridIndices(forRow rowIndex: Int, width: Int) -> some Sequence<Int> {
        let startIndex = rowIndex * width
        return stride(from: startIndex, to: startIndex + width, by: 1)
    }

    func gridIndices(forColumn columnIndex: Int, width: Int) -> some Sequence<Int> {
        return stride(from: columnIndex, to: count, by: width)
    }
}
