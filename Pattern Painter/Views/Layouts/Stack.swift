//
//  Stack.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 8/15/25.
//

import SwiftUI

struct Stack<Content: View>: View {
    let axis: Axis
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        let layout = axis == .horizontal
            ? AnyLayout(HStackLayout(spacing: spacing))
            : AnyLayout(VStackLayout(spacing: spacing))
        layout.callAsFunction(content)
    }
}
