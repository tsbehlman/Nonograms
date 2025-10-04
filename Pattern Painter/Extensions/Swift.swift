//
//  Swift.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 6/5/25.
//

func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
    Swift.max(min, Swift.min(value, max))
}
