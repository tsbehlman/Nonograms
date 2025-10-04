//
//  TileStateIcons.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 9/1/25.
//

import SwiftUI

struct FilledTileIcon: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
    }
}

struct BlockedTileIcon: View {
    var body: some View {
        XMarkShape()
            .stroke(style: StrokeStyle(lineWidth: 3.0, lineCap: .round))
    }
}
