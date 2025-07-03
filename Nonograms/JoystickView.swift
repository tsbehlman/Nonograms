//
//  JoystickView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/28/25.
//

import SwiftUI

struct JoystickView: View {
    private static let radius: CGFloat = 24

    @Binding var translation: CGPoint
    @GestureState private var position: CGPoint = .zero

    var body: some View {
        let gesture = DragGesture()
            .updating($position) { value, state, _ in
                let angle = atan2(value.translation.height, value.translation.width)
                let length = min(hypot(value.translation.height, value.translation.width), JoystickView.radius)
                state = CGPoint(
                    x: length * cos(angle),
                    y: length * sin(angle)
                )
            }

        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.25))
            ZStack {
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 32, height: 32, alignment: .center)
                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                    .foregroundStyle(Color.white) // TODO invert primary
            }
            .position(
                x: position.x + JoystickView.radius,
                y: position.y + JoystickView.radius
            )
        }
            .frame(width: JoystickView.radius * 2, height: JoystickView.radius * 2, alignment: .center)
            .highPriorityGesture(gesture)
            .onChange(of: position) {
                translation = CGPoint(
                    x: $1.x / JoystickView.radius,
                    y: $1.y / JoystickView.radius,
                )
            }
    }
}

#Preview {
    @Previewable @State var translation: CGPoint = .zero
    VStack {
        JoystickView(translation: $translation)
        Text("\(translation.x) \(translation.y)")
    }
}
