//
//  ControlButton.swift
//  Nonograms
//
//  Created by Trevor Behlman on 7/2/25.
//

import SwiftUI

let controlButtonSize: CGFloat = 56

struct ControlButton: View {
    let icon: String
    let active: Bool
    let disabled: Bool

    @Environment(\.puzzleColor) var puzzleColor

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
                .stroke(Color.primary.opacity(0.25))
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .imageScale(.large)
        }
            .frame(width: controlButtonSize, height: controlButtonSize, alignment: .center)
    }
}

#Preview {
    HStack {
        ControlButton(icon: "questionmark", active: false, disabled: false)
        ControlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", active: false, disabled: true)
        ControlButton(icon: "square.fill", active: true, disabled: true)
        ControlButton(icon: "xmark", active: true, disabled: false)
    }
}
