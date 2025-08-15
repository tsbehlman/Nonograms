//
//  EqualStack.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/4/25.
//

import SwiftUI

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

    struct Cache {
        let maxWidth: CGFloat
        let maxHeight: CGFloat
        let totalWidth: CGFloat
        let totalHeight: CGFloat
        let sizes: [CGFloat]
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

    func makeCache(subviews: Subviews) -> Cache {
        let totalSpacing = spacing * CGFloat(max(0, subviews.count - 1))
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalWidth: CGFloat = totalSpacing
        var totalHeight: CGFloat = totalSpacing
        var sizes: [CGFloat] = []
        for subview in subviews {
            let sizeThatFits = subview.sizeThatFits(.unspecified)
            let size = CGSize(
                width: itemWidth.apply(to: sizeThatFits.width),
                height: itemHeight.apply(to: sizeThatFits.height)
            )
            maxWidth = max(maxWidth, size.width)
            maxHeight = max(maxHeight, size.height)
            totalWidth += size.width
            totalHeight += size.height
            if axis == .horizontal {
                sizes.append(size.width)
            } else {
                sizes.append(size.height)
            }
        }
        return Cache(maxWidth: maxWidth, maxHeight: maxHeight, totalWidth: totalWidth, totalHeight: totalHeight, sizes: sizes)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        if axis == .horizontal {
            return CGSize(width: cache.totalWidth, height: cache.maxHeight)
        } else {
            return CGSize(width: cache.maxWidth, height: cache.totalHeight)
        }
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var point = axis == .horizontal ?
            CGPoint(x: bounds.minX, y: bounds.maxY) :
            CGPoint(x: bounds.maxX, y: bounds.minY)

        for index in subviews.indices {
            let size = cache.sizes[index]
            let proposal: ProposedViewSize
            if axis == .horizontal {
                point.x += size + spacing
                proposal = ProposedViewSize(
                    width: size,
                    height: cache.maxHeight
                )
            } else {
                point.y += size + spacing
                proposal = ProposedViewSize(
                    width: cache.maxWidth,
                    height: size
                )
            }
            subviews[index].place(at: point, anchor: .bottomTrailing, proposal: proposal)
        }
    }
}
