//
//  CGRect.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/5/25.
//

import CoreGraphics

extension CGRect {
    func expanding(by amount: CGFloat) -> CGRect {
        CGRect(x: minX - amount, y: minY - amount, width: width + amount * 2, height: height + amount * 2)
    }
}
