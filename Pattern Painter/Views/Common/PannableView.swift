//
//  PannableView.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 6/28/25.
//

import SwiftUI

struct PannableView<Content: View>: View {
    let scrollEnabled: Bool
    @Binding var fitsView: Bool
    @Binding var offset: CGPoint
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            content
        }
            .scrollDisabled(!scrollEnabled)
            .onScrollGeometryChange(for: Bool.self, of: { geometry in
                Int(geometry.contentSize.width) <= Int(geometry.containerSize.width) && Int(geometry.contentSize.height) <= Int(geometry.containerSize.height)
            }) {
                fitsView = $1
            }
            .onScrollGeometryChange(for: CGPoint.self, of: \.contentOffset) {
                offset = $1
            }
            .scrollClipDisabled()
    }
}

#if DEBUG

func checkerboard(_ size: CGFloat, color: Color = .gray) -> Image {
    Image(size: CGSizeMake(size * 2, size * 2)) { context in
        context.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: size, height: size), cornerRadius: 0), with: .color(color))
        context.fill(Path(roundedRect: CGRect(x: size, y: size, width: size, height: size), cornerRadius: 0), with: .color(color))
    }
}

#Preview {
    @Previewable @State var scrollEnabled = false
    @Previewable @State var fitsView = false
    @Previewable @State var offset: CGPoint = .zero

    VStack {
        PannableView(scrollEnabled: scrollEnabled, fitsView: $fitsView, offset: $offset) {
            Rectangle()
                .frame(width: 600, height: 600)
                .foregroundStyle(ImagePaint.image(checkerboard(16)))
        }
            .border(.separator, width: 2.0)
            .frame(width: 300, height: 300)
            .clipped()
            .onChange(of: fitsView) { _, newValue in
                if !newValue && scrollEnabled {
                    scrollEnabled = false
                }
            }
        ControlIconButton(icon: "arrow.up.and.down.and.arrow.left.and.right", active: !fitsView && scrollEnabled, disabled: fitsView)
            .onTapGesture {
                if !fitsView {
                    scrollEnabled = !scrollEnabled
                }
            }
    }
        .padding()
}

#endif
