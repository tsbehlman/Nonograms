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
}
