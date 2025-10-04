//
//  Text.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 7/3/25.
//

import SwiftUI

extension Text {
    func stroke(_ color: Color, width: CGFloat = 1.0) -> some View {
        modifier(StrokeModifier(color: color, width: width))
    }
}

struct StrokeModifier: ViewModifier {
    let color: Color
    let width: CGFloat
    let uuid = UUID()

    func body(content: Content) -> some View {
        content
            .padding(width)
            .background(outline(content))
    }

    private func outline(_ content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.0006, color: color))
            context.addFilter(.blur(radius: width))
            context.drawLayer { layer in
                guard let text = context.resolveSymbol(id: uuid) else { return }
                layer.draw(text, at: CGPoint(x: size.width / 2, y: size.height / 2))
            }
        } symbols: {
            content.tag(uuid)
        }
    }
}

#Preview {
    Text("1 3 5 10")
        .font(.system(size: 64.0, weight: .bold, design: .monospaced))
        .foregroundStyle(.red)
        .stroke(.blue, width: 1)
}
