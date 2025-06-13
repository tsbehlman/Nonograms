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
}
