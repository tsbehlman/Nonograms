//
//  ControlButton.swift
//  Nonograms
//
//  Created by Trevor Behlman on 7/2/25.
//

import SwiftUI

struct ControlButton: View {
    let icon: String
    let active: Bool
    let disabled: Bool
    let bordered: Bool
    let scale: Image.Scale

    var size: CGFloat {
        switch scale {
        case .small:
            return 32
        default:
            return 56
        }
    }

    init(icon: String, active: Bool = false, disabled: Bool = false, bordered: Bool = true, size: Image.Scale = .large) {
        self.icon = icon
        self.active = active
        self.disabled = disabled
        self.bordered = bordered
        self.scale = size
    }

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.gameState.puzzleColor) var puzzleColor

    var fillColor: Color {
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

    var iconColor: Color {
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
                .fill(fillColor)
                .when(bordered || active) { $0.strokeBorder(Color.primary.opacity(0.375)) }
            Image(systemName: icon)
                .fontWeight(.semibold)
                .foregroundStyle(iconColor)
                .imageScale(scale)
        }
            .frame(width: size, height: size, alignment: .center)
    }
}

#Preview {
    HStack {
        ControlButton(icon: "questionmark")
        ControlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", disabled: true)
        ControlButton(icon: "square.fill", active: true, disabled: true)
        ControlButton(icon: "xmark", active: true)
    }
}
