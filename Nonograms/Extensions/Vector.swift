//
//  Vector.swift
//  Nonograms
//
//  Created by Trevor Behlman on 9/22/25.
//

import CoreGraphics
import simd
import SwiftUI

typealias Vec2 = SIMD2<CGFloat.NativeType>

extension Vec2 {
    init<Number: BinaryInteger>(_ x: Number, _ y: Number) {
        self.init(CGFloat(x), CGFloat(y))
    }

    init(_ cgPoint: CGPoint) {
        self.init(cgPoint.x, cgPoint.y)
    }
}
