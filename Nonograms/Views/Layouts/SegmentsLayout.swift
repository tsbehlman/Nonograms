//
//  SegmentsLayout.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/15/25.
//

import SwiftUI

struct SegmentsLayout: Layout {
    let axis: Axis
    let inlineSize: CGFloat
    let blockSize: CGFloat
    let offset: CGPoint

    struct Cache {
        let size: CGSize
        let maxOffsets: [CGFloat]
    }

    func makeCache(subviews: Subviews) -> Cache {
        let maxOffsets = subviews.map { subview in
            let sizeThatFits = subview.sizeThatFits(.unspecified)
            if axis == .horizontal {
                return blockSize - sizeThatFits.height
            } else {
                return blockSize - sizeThatFits.width
            }
        }

        let totalInlineSize = CGFloat(subviews.count) * inlineSize
        let size: CGSize
        if axis == .horizontal {
            size = CGSize(width: totalInlineSize, height: blockSize)
        } else {
            size = CGSize(width: blockSize, height: totalInlineSize)
        }

        return Cache(size: size, maxOffsets: maxOffsets)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        cache.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let anchor: UnitPoint = axis == .horizontal
            ? .bottom
            : .trailing
        var point = axis == .horizontal
            ? CGPoint(x: bounds.minX - offset.x - inlineSize / 2, y: bounds.maxY)
            : CGPoint(x: bounds.maxX, y: bounds.minY - offset.y - inlineSize / 2)

        for index in subviews.indices {
            let maxOffset = cache.maxOffsets[index]
            if axis == .horizontal {
                point.x += inlineSize
                point.y = bounds.maxY - min(offset.y, maxOffset)
            } else {
                point.x = bounds.maxX - min(offset.x, maxOffset)
                point.y += inlineSize
            }
            subviews[index].place(at: point, anchor: anchor, proposal: .unspecified)
        }
    }
}
