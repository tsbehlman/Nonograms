//
//  OffsetView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 7/7/25.
//

import SwiftUI

struct OffsetView<Content: View>: View {
    var axis: Axis
    @Binding var offset: CGPoint
    @ViewBuilder var content: Content

    var body: some View {
        GeometryReader { _ in
            content.offset(CGSize(
                width: axis == .horizontal ? -offset.x : 0,
                height: axis == .vertical ? -offset.y : 0,
            ))
        }
            .clipped()
    }
}
