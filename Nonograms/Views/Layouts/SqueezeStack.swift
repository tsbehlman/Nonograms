//
//  SqueezeStack.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/3/25.
//

import SwiftUI

struct SqueezeStack: Layout {
    let axis: Axis
    let reversed: Bool
    let offset: CGFloat
    let spacing: CGFloat
    let minSpacing: CGFloat

    init(_ axis: Axis, reversed: Bool = false, offset: CGFloat, spacing: CGFloat, minSpacing: CGFloat? = nil) {
        self.axis = axis
        self.reversed = reversed
        self.offset = offset
        self.spacing = spacing
        self.minSpacing = minSpacing ?? spacing
    }

    struct Cache {
        let maxWidth: CGFloat
        let maxHeight: CGFloat
        let totalSize: CGFloat
        let sizes: [CGFloat]
    }

    func makeCache(subviews: Subviews) -> Cache {
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalSize: CGFloat = 0
        var sizes: [CGFloat] = []
        for subview in subviews {
            let sizeThatFits = subview.sizeThatFits(.unspecified)
            maxWidth = max(maxWidth, sizeThatFits.width)
            maxHeight = max(maxHeight, sizeThatFits.height)
            if axis == .horizontal {
                totalSize += sizeThatFits.width
                sizes.append(sizeThatFits.width)
            } else {
                totalSize += sizeThatFits.height
                sizes.append(sizeThatFits.height)
            }
        }
        return Cache(maxWidth: maxWidth, maxHeight: maxHeight, totalSize: totalSize, sizes: sizes)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let totalSpacing = spacing * CGFloat(max(0, subviews.count - 1))
        let size = cache.totalSize + totalSpacing

        if axis == .horizontal {
            return CGSize(width: max(proposal.width ?? 0, size), height: cache.maxHeight)
        } else {
            return CGSize(width: cache.maxWidth, height: max(proposal.height ?? 0, size))
        }
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let fullSize: CGFloat

        if axis == .horizontal {
            fullSize = bounds.width
        } else {
            fullSize = bounds.height
        }

        let indices: any Sequence<Int> = reversed
            ? subviews.indices.reversed()
            : subviews.indices

        let origin = CGPoint(x: bounds.minX, y: bounds.minY)
        var idealPosition: CGFloat = 0
        var forcedPosition: CGFloat = max(0, offset)
        let minimumSize = cache.totalSize + minSpacing * CGFloat(max(0, subviews.count - 1))
        var remainingSize = fullSize - minimumSize

        for index in indices {
            let size = cache.sizes[index]
            var position = min(max(idealPosition, forcedPosition), remainingSize)
            if reversed {
                position = fullSize - size - position
            }

            var point = origin
            var proposal = ProposedViewSize(width: cache.maxWidth, height: cache.maxHeight)
            if axis == .horizontal {
                point.x += position
                proposal.width = size
            } else {
                point.y += position
                proposal.height = size
            }
            subviews[index].place(at: point, anchor: .topLeading, proposal: proposal)

            idealPosition += size + spacing
            forcedPosition += size + minSpacing
            remainingSize += size + minSpacing
        }
    }
}

#Preview {
    @Previewable @State var scrollEnabled = true
    @Previewable @State var fitsView = false
    @Previewable @State var offset: CGPoint = .zero

    let spacing: CGFloat = 10
    let minSpacing: CGFloat = 2
    let gridSize: CGFloat = 128
    @ViewBuilder var horizontalItems: any View {
        Rectangle()
            .frame(width: 16, height: gridSize)
            .foregroundStyle(.primary)
        Rectangle()
            .frame(width: 16, height: gridSize)
            .foregroundStyle(.secondary)
        Rectangle()
            .frame(width: 16, height: gridSize)
            .foregroundStyle(.tertiary)
    }

    @ViewBuilder var verticalItems: any View {
        Rectangle()
            .frame(width: gridSize, height: 16)
            .foregroundStyle(.primary)
        Rectangle()
            .frame(width: gridSize, height: 16)
            .foregroundStyle(.secondary)
        Rectangle()
            .frame(width: gridSize, height: 16)
            .foregroundStyle(.tertiary)
    }

    VStack {
        HStack {
            Spacer()
            SqueezeStack(.vertical, reversed: true, offset: offset.y, spacing: spacing, minSpacing: minSpacing) {
                AnyView(verticalItems)
            }
                .border(.red, width: 2.0)
                .zIndex(1)
            Spacer()
        }
        HStack {
            SqueezeStack(.horizontal, reversed: true, offset: offset.x, spacing: spacing, minSpacing: minSpacing) {
                AnyView(horizontalItems)
            }
                .border(.red, width: 2.0)
                .zIndex(1)
            PannableView(scrollEnabled: scrollEnabled, fitsView: $fitsView, offset: $offset) {
                Rectangle()
                    .frame(width: gridSize, height: gridSize)
                    .foregroundStyle(ImagePaint.image(checkerboard(16)))
            }
                .border(.red, width: 2.0)
                .frame(width: gridSize, height: gridSize)
                .zIndex(0)
            SqueezeStack(.horizontal, reversed: false, offset: -offset.x, spacing: spacing, minSpacing: minSpacing) {
                AnyView(horizontalItems)
            }
                .border(.red, width: 2.0)
        }
        HStack {
            Spacer()
            SqueezeStack(.vertical, reversed: false, offset: -offset.y, spacing: spacing, minSpacing: minSpacing) {
                AnyView(verticalItems)
            }
                .border(.red, width: 2.0)
            Spacer()
        }
    }
}
