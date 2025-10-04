//
//  Color.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 8/4/25.
//

import SwiftUI

extension Color {
    func forScheme(_ colorScheme: ColorScheme) -> Color {
        var environmentValues = EnvironmentValues()
        environmentValues.colorScheme = colorScheme
        return Color(cgColor: self.resolve(in: environmentValues).cgColor)
    }
}
