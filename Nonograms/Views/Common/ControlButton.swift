//
//  ControlButton.swift
//  Nonograms
//
//  Created by Trevor Behlman on 7/2/25.
//

import SwiftUI

struct ControlIconButton: View {
    let icon: String
    let active: Bool
    let disabled: Bool
    let bordered: Bool
    let scale: Image.Scale

    init(icon: String, active: Bool = false, disabled: Bool = false, bordered: Bool = true, size: Image.Scale = .large) {
        self.icon = icon
        self.active = active
        self.disabled = disabled
        self.bordered = bordered
        self.scale = size
    }

    var body: some View {
        ControlButton(active: active, disabled: disabled, bordered: bordered, size: scale) {
            Image(systemName: icon)
                .fontWeight(.semibold)
                .imageScale(scale)
                .dynamicTypeSize(.large)
        }
    }
}

struct ControlButton<Content: View>: View {
    let active: Bool
    let disabled: Bool
    let bordered: Bool
    let scale: Image.Scale
    let content: () -> Content

    var size: CGFloat {
        switch scale {
        case .small:
            return 32
        default:
            return 56
        }
    }

    init(active: Bool = false, disabled: Bool = false, bordered: Bool = true, size: Image.Scale = .large, _ content: @escaping () -> Content) {
        self.active = active
        self.disabled = disabled
        self.bordered = bordered
        self.scale = size
        self.content = content
    }

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.gameState.puzzleColor) var puzzleColor

    var backgroundColor: Color {
        if active {
            if disabled {
                return Color.primary.opacity(0.5)
            } else {
                return puzzleColor
            }
        } else {
            return Color(UIColor.systemBackground)
        }
    }

    var fillColor: Color {
        if active {
            return Color.primary.forScheme(.dark)
        } else if disabled {
            return Color.primary.opacity(0.25)
        } else {
            return Color.primary
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .when(bordered || active) { $0.strokeBorder(Color.primary.opacity(0.375)) }
            content()
                .foregroundStyle(fillColor)
                .frame(maxWidth: size * 0.375, maxHeight: size * 0.375)
        }
            .frame(width: size, height: size, alignment: .center)
    }
}

#Preview {
    HStack {
        ControlIconButton(icon: "questionmark")
        ControlIconButton(icon: "arrow.up.and.down.and.arrow.left.and.right", disabled: true)
        ControlButton(active: true, disabled: true) {
            FilledTileIcon()
        }
        ControlButton(active: true) {
            BlockedTileIcon()
                .padding(2)
        }
    }
}
