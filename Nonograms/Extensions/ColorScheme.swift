//
//  ColorScheme.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/4/25.
//

import SwiftUI

extension ColorScheme {
    var inverted: ColorScheme {
        switch self {
        case .light:
            return .dark
        case .dark:
            return .light
        @unknown default:
            return self
        }
    }
}
