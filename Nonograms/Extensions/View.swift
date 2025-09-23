//
//  View.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/7/25.
//

import SwiftUI

extension View {
    func when(_ condition: Bool, @ViewBuilder body: (Self) -> some View) -> some View {
        if condition {
            return AnyView(body(self))
        } else {
            return AnyView(self)
        }
    }
}
