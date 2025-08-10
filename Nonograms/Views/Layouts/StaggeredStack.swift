//
//  StaggeredStack.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/7/25.
//

import SwiftUI

struct StaggeredStackCache {
    let center: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    let sizes: [CGSize]
}

struct StaggeredStack: Layout {
    let angle: Angle
    let order: Order
    let spacing: CGFloat

    enum Order {
        case even
        case odd
    }

    init(angle: Angle = .degrees(60), order: Order = .odd, spacing: CGFloat = 0) {
        self.angle = angle
        self.order = order
        self.spacing = spacing
    }

    func makeCache(subviews: Subviews) -> StaggeredStackCache {
        var maxSize: CGFloat = 0
        var sizes: [CGSize] = []
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            maxSize = max(maxSize, size.width, size.height)
            sizes.append(size)
        }
        let radius = maxSize + spacing
        let theta = angle.radians
        let xOffset = radius * cos(theta)
        let yOffset = radius * sin(theta)
        return StaggeredStackCache(
            center: maxSize / 2,
            xOffset: xOffset,
            yOffset: yOffset,
            totalWidth: maxSize + xOffset * CGFloat(max(0, subviews.count - 1)),
            totalHeight: maxSize + yOffset * CGFloat(min(1, subviews.count - 1)),
            sizes: sizes
        )
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout StaggeredStackCache) -> CGSize {
        CGSize(width: cache.totalWidth, height: cache.totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout StaggeredStackCache) {
        var point = CGPoint(x: bounds.minX + cache.center, y: 0)
        var isLower = order == .even

        for index in subviews.indices {
            if isLower {
                point.y = bounds.maxY - cache.center
            } else {
                point.y = bounds.minY + cache.center
            }
            isLower = !isLower
            let size = cache.sizes[index]
            let proposal = ProposedViewSize(
                width: size.width,
                height: size.height
            )
            subviews[index].place(at: point, anchor: .center, proposal: proposal)
            point.x += cache.xOffset
        }
    }
}

#Preview {
    @ViewBuilder var items: any View {
        ControlButton(icon: "square.fill", active: false, disabled: false)
        ControlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", active: false, disabled: false)
        ControlButton(icon: "xmark", active: false, disabled: false)
    }

    VStack(spacing: 32) {
        StaggeredStack(angle: .degrees(45), order: .odd, spacing: 16) {
            AnyView(items)
        }
        StaggeredStack(angle: .degrees(60), order: .even, spacing: 16) {
            AnyView(items)
        }
    }
}
