//
//  Stack.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/20/25.
//

import SwiftUI

struct Stack<Content>: View where Content: View {
    let axis: Axis
    let horizontalAlignment: HorizontalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    var verticalAlignment: VerticalAlignment {
        switch horizontalAlignment {
        case .leading:
            return .top
        case .trailing:
            return .bottom
        default:
            return .center
        }
    }

    public init(_ axis: Axis, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.axis = axis
        self.horizontalAlignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        if axis == .horizontal {
            HStack(alignment: verticalAlignment, spacing: spacing, content: content)
        } else {
            VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
        }
    }
}
