//
//  ControlView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/2/25.
//

import SwiftUI

let controlSize: CGFloat = 48

struct ControlIconView: View {
    @Binding var state: TileState
    let control: TileState
    let icon: String

    var body: some View {
        ZStack {
            Circle()
                .fill(state == control ? Color.accentColor : Color(UIColor.systemBackground))
                .stroke(Color(UIColor.separator))
            Image(systemName: icon)
                .foregroundStyle(state == control ? Color(UIColor.label.onFill) : Color.primary)
        }
            .frame(width: 48, height: 48, alignment: .center)
            .onTapGesture {
                state = control
            }
    }
}

struct ControlView: View {
    @Binding var state: TileState

    var body: some View {
        HStack {
            ControlIconView(state: $state, control: .filled, icon: "square.fill")
            ControlIconView(state: $state, control: .blocked, icon: "xmark")
        }
    }
}

#Preview {
    @Previewable @State var state: TileState = .filled
    ControlView(state: $state)
}
