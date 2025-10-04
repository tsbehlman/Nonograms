//
//  StaggeredStack.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 8/7/25.
//

import SwiftUI

struct StaggeredStackLayout: Layout {
    let angle: Angle
    let spacing: CGFloat

    init(angle: Angle = .degrees(60), spacing: CGFloat = 0) {
        self.angle = angle
        self.spacing = spacing
    }

    struct Cache {
        let radius: CGFloat
        let xOffset: CGFloat
        let yOffset: CGFloat
        let size: CGSize
    }

    func makeCache(subviews: Subviews) -> Cache {
        var diameter: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            diameter = max(diameter, size.width, size.height)
        }
        let distance = diameter + spacing
        let theta = abs(angle.radians)
        let xOffset = distance * cos(theta)
        let yOffset = distance * sin(theta)
        let totalWidth = diameter + xOffset * CGFloat(max(0, subviews.count - 1))
        let totalHeight = diameter + yOffset * CGFloat(min(1, subviews.count - 1))
        return Cache(
            radius: diameter / 2,
            xOffset: xOffset,
            yOffset: yOffset,
            size: CGSize(width: totalWidth, height: totalHeight)
        )
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        cache.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var point = CGPoint(x: bounds.minX + cache.radius, y: 0)
        var isLower = angle.radians < 0
        let minY = bounds.maxY - cache.radius
        let maxY = bounds.minY + cache.radius

        for index in subviews.indices {
            if isLower {
                point.y = minY
            } else {
                point.y = maxY
            }
            isLower = !isLower
            subviews[index].place(at: point, anchor: .center, proposal: .unspecified)
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

    func traceBackground(padding: CGFloat, curvature: CGFloat, content: (StaggeredStackBackground) -> some View) -> some View {
        self.background {
            content(StaggeredStackBackground(angle: angle, spacing: spacing, padding: padding, curvature: curvature))
                .allowsHitTesting(false)
        }
    }
}

struct StaggeredStackBackground: InsettableShape {
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
            : cutoutStartAngle
        let outerCutoutX = cutoutDistance * cos(outerCutoutAngle.radians)
        let outerCutoutY = -cutoutDistance * sin(outerCutoutAngle.radians)
        let innerCutoutX = cutoutDistance * cos(innerCutoutAngle.radians)
        let innerCutoutY = -cutoutDistance * sin(innerCutoutAngle.radians)
        let numItems = Int(((rect.width - itemSize) / xOffset).rounded()) + 1

        var path = Path()

        var center = CGPoint(x: itemRadius, y: 0)
        var isLower = true

        for index in 0..<numItems {
            if isLower {
                center.y = itemRadius + yOffset
            } else {
                center.y = itemRadius
            }
            if isLower {
                path.addSubpath(transform: CGAffineTransform(translationX: center.x, y: center.y).scaledBy(x: index == 0 ? 1 : -1, y: 1)) { subpath in
                    subpath.addArc(center: CGPoint(x: outerCutoutX, y: outerCutoutY), radius: cutoutRadius, startAngle: cutoutStartAngle, endAngle: .degrees(180) - outerCutoutAngle, clockwise: false)
                    subpath.addArc(center: CGPoint(x: innerCutoutX, y: -innerCutoutY), radius: cutoutRadius, startAngle: .degrees(180) + innerCutoutAngle, endAngle: max(-outerCutoutAngle, .degrees(-90)), clockwise: false)
                    subpath.addLine(to: CGPoint(x: xOffset + 1, y: -yOffset))
                }
            }
            path.addSubpath { subpath in
                subpath.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            }
            isLower = !isLower
            center.x += xOffset
        }

        if angle.radians > 0 {
            return path.applying(CGAffineTransform(translationX: 0, y: rect.height).scaledBy(x: 1, y: -1))
        } else {
            return path
        }
    }

    func inset(by amount: CGFloat) -> StaggeredStackBackground {
        StaggeredStackBackground(angle: angle, spacing: spacing, padding: padding - amount, curvature: curvature + amount)
    }
}

extension Path {
    mutating func addSubpath(_ builder: (_: inout Path) -> ()) {
        var subpath = Path()
        builder(&subpath)
        self = union(subpath, eoFill: false)
        closeSubpath()
    }

    mutating func addSubpath(transform: CGAffineTransform, _ builder: (_: inout Path) -> ()) {
        var subpath = Path()
        builder(&subpath)
        self = union(subpath.applying(transform), eoFill: false)
        closeSubpath()
    }
}

#Preview {
    @ViewBuilder var items: any View {
        ControlIconButton(icon: "square.fill")
        ControlIconButton(icon: "arrow.up.and.down.and.arrow.left.and.right")
        ControlIconButton(icon: "xmark")
    }

    VStack(spacing: 32) {
        StaggeredStack(angle: .degrees(60), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 8, curvature: 14) {
                $0.fill(Color.primary.opacity(0.2))
            }
        StaggeredStack(angle: .degrees(45), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 8, curvature: 14) {
                $0.fill(Color.primary.opacity(0.2))
            }
        StaggeredStack(angle: .degrees(0), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 8, curvature: 14) {
                $0.fill(Color.primary.opacity(0.2))
            }
        StaggeredStack(angle: .degrees(-45), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 4, curvature: 64) {
                $0.fill(Color.primary.opacity(0.2))
            }
        StaggeredStack(angle: .degrees(-60), spacing: 16) {
            AnyView(items)
        }
            .traceBackground(padding: 16, curvature: 4) {
                $0.fill(Color.primary.opacity(0.2))
            }
    }
}
