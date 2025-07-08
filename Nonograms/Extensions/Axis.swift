//
//  Axis.swift
//  Nonograms
//
//  Created by Trevor Behlman on 7/8/25.
//

import SwiftUI

extension Axis {
    var opposing: Axis {
        switch self {
        case .vertical:
            return .horizontal
        case .horizontal:
            return .vertical
        }
    }
}
