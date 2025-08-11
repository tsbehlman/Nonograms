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

struct StaggeredStackLayout: Layout {
    let angle: Angle
    let spacing: CGFloat

    init(angle: Angle = .degrees(60), spacing: CGFloat = 0) {
        self.angle = angle
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
        let theta = abs(angle.radians)
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
        var isLower = angle.radians < 0

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

struct StaggeredStack<Content: View>: View {
    let angle: Angle
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(angle: Angle = .degrees(60), spacing: CGFloat = 0, @ViewBuilder content: @escaping () -> Content) {
        self.angle = angle
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        StaggeredStackLayout(angle: angle, spacing: spacing).callAsFunction(content)
    }

    func traceBackground(padding: CGFloat, curvature: CGFloat, color: Color) -> some View {
        self.background {
            StaggeredStackBackground(angle: angle, spacing: spacing, padding: padding, curvature: curvature)
                .fill(color)
        }
    }
}

private struct StaggeredStackBackground: Shape {
    let angle: Angle
    let spacing: CGFloat
    let padding: CGFloat
    let curvature: CGFloat

    func path(in rect: CGRect) -> Path {
        let delta: Angle = .radians(abs(angle.radians))
        let itemSize: CGFloat = (rect.height - spacing * sin(delta.radians)) / (1 + sin(delta.radians))
        let itemRadius = itemSize / 2
        let itemDistance = itemSize + spacing
        let xOffset = itemDistance * cos(delta.radians)
        let yOffset = itemDistance * sin(delta.radians)
        let radius = itemRadius + padding
        let cutoutRadius = curvature
        let cutoutDistance = radius + cutoutRadius
        let isBridged = xOffset < cutoutDistance
        let cutoutAngle: Angle = .radians(CoreGraphics.acos(itemDistance / 2 / cutoutDistance))
        let cutoutStartAngle: Angle = cutoutAngle - delta
        let outerCutoutAngle: Angle = cutoutAngle + delta
        let innerCutoutAngle: Angle = isBridged
            ? .radians(CoreGraphics.acos(xOffset / cutoutDistance))
            : cutoutAngle - delta
        let outerCutoutX = cutoutDistance * cos(outerCutoutAngle.radians)
        let outerCutoutY = -cutoutDistance * sin(outerCutoutAngle.radians)
        let innerCutoutX = cutoutDistance * cos(innerCutoutAngle.radians)
        let innerCutoutY = -cutoutDistance * sin(innerCutoutAngle.radians)
        let numItems = Int(((rect.width - itemSize) / xOffset).rounded()) + 1

        var path = Path()

        var center = CGPoint(x: itemSize / 2, y: 0)
        var isLower = true

        for index in 0..<numItems {
            if isLower {
                center.y = itemSize / 2 + yOffset
            } else {
                center.y = itemSize / 2
            }
            if isLower {
                path.addSubpath(transform: CGAffineTransform(translationX: center.x, y: center.y).scaledBy(x: index == 0 ? 1 : -1, y: 1)) { subpath in
                    subpath.addArc(center: CGPoint(x: outerCutoutX, y: outerCutoutY), radius: cutoutRadius, startAngle: cutoutStartAngle, endAngle: .degrees(180) - outerCutoutAngle, clockwise: false)
                    subpath.addArc(center: CGPoint(x: innerCutoutX, y: -innerCutoutY), radius: cutoutRadius, startAngle: .degrees(180) + innerCutoutAngle, endAngle: max(-outerCutoutAngle, .degrees(-90)), clockwise: false)
                    subpath.addLine(to: CGPoint(x: xOffset, y: -yOffset))
                }
            }
            path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            isLower = !isLower
            center.x += xOffset
        }

        if angle.radians > 0 {
            return path.applying(CGAffineTransform(translationX: 0, y: rect.height).scaledBy(x: 1, y: -1))
        } else {
            return path
        }
    }
}

extension Path {
    mutating func addSubpath(transform: CGAffineTransform, _ builder: (_: inout Path) -> ()) {
        var subpath = Path()
        builder(&subpath)
        self = union(subpath.applying(transform), eoFill: false)
        closeSubpath()
    }
}

#Preview {
    @ViewBuilder var items: any View {
        ControlButton(icon: "square.fill", active: false, disabled: false)
        ControlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", active: false, disabled: false)
        ControlButton(icon: "xmark", active: false, disabled: false)
    }

    VStack(spacing: 32) {
        StaggeredStack(angle: .degrees(60), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 8, curvature: 14, color: Color.primary.opacity(0.2))
        StaggeredStack(angle: .degrees(45), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 8, curvature: 14, color: Color.primary.opacity(0.2))
        StaggeredStack(angle: .degrees(0), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 8, curvature: 14, color: Color.primary.opacity(0.2))
        StaggeredStack(angle: .degrees(-45), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 4, curvature: 64, color: Color.primary.opacity(0.2))
        StaggeredStack(angle: .degrees(-60), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 16, curvature: 4, color: Color.primary.opacity(0.2))
    }
}
