//
//  OutlinedText.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 7/3/25.
//

import SwiftUI
import UIKit

struct StrokeTextLabel: UIViewRepresentable {
    let string: String
    let font: UIFont
    let color: UIColor
    let strokeWidth: CGFloat
    let strokeColor: UIColor

    init(_ string: String, font: UIFont = .systemFont(ofSize: UIFont.systemFontSize), color: UIColor = .label, strokeWidth: CGFloat, strokeColor: UIColor) {
        self.string = string
        self.font = font
        self.color = color
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
    }

    func makeUIView(context: Context) -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = .center
        let attributedString = NSAttributedString(
            string: string,
            attributes: [
                .paragraphStyle: attributedStringParagraphStyle,
                .strokeWidth: -strokeWidth,
                .foregroundColor: color,
                .strokeColor: strokeColor,
                .font: font,
            ]
        )

        let strokeLabel = UILabel(frame: CGRect.zero)
        strokeLabel.attributedText = attributedString
        strokeLabel.backgroundColor = UIColor.clear
        return strokeLabel
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}

#Preview {
    HStack {
        StrokeTextLabel("1 3 8 10", font: UIFont(descriptor: UIFontDescriptor(name: "Menlo-Bold", size: 64.0), size: 64.0), color: .red, strokeWidth: 4.0, strokeColor: .black)
            .fixedSize()
            .border(Color.red, width: 2.0)
    }
}
