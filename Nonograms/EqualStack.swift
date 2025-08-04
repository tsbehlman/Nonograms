//
//  EqualStack.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

struct EqualStackCache {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let sizes: [CGSize]
}

struct EqualStack: Layout {
    let axis: Axis
    let spacing: CGFloat
    let itemWidth: Sizing
    let itemHeight: Sizing

    init(axis: Axis, spacing: CGFloat = 0.0, itemWidth: Sizing = .flexible, itemHeight: Sizing = .flexible) {
        self.axis = axis
        self.spacing = spacing
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
    }

    enum Sizing {
        case fixed(CGFloat)
        case flexible

        func apply(to size: CGFloat) -> CGFloat {
            switch self {
            case .fixed(let fixedSize):
                return fixedSize
            case .flexible:
                return size
            }
        }
    }

    func makeCache(subviews: Subviews) -> EqualStackCache {
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        var sizes: [CGSize] = []
        for subview in subviews {
            let sizeThatFits = subview.sizeThatFits(.unspecified)
            let size = CGSize(
                width: itemWidth.apply(to: sizeThatFits.width),
                height: itemHeight.apply(to: sizeThatFits.height)
            )
            maxWidth = max(maxWidth, size.width)
            maxHeight = max(maxHeight, size.height)
            sizes.append(size)
        }
        return EqualStackCache(maxWidth: maxWidth, maxHeight: maxHeight, sizes: sizes)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout EqualStackCache) -> CGSize {
        let totalSpacing = spacing * CGFloat(subviews.count - 1)

        if axis == .horizontal {
            let totalWidth = cache.sizes.reduce(0.0) { $0 + $1.width }
            return CGSize(width: totalWidth + totalSpacing, height: cache.maxHeight)
        } else {
            let totalHeight = cache.sizes.reduce(0.0) { $0 + $1.height }
            return CGSize(width: cache.maxWidth, height: totalHeight + totalSpacing)
        }
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout EqualStackCache) {
        var point = axis == .horizontal ?
            CGPoint(x: bounds.minX, y: bounds.maxY) :
            CGPoint(x: bounds.maxX, y: bounds.minY)

        for index in subviews.indices {
            let size = cache.sizes[index]
            let proposal: ProposedViewSize
            if axis == .horizontal {
                point.x += size.width + spacing
                proposal = ProposedViewSize(
                    width: size.width,
                    height: cache.maxHeight
                )
            } else {
                point.y += size.height + spacing
                proposal = ProposedViewSize(
                    width: cache.maxWidth,
                    height: size.height
                )
            }
            subviews[index].place(at: point, anchor: .bottomTrailing, proposal: proposal)
        }
    }
}
