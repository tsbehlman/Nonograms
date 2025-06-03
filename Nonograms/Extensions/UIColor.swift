//
//  UIColor.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/2/25.
//

import UIKit

extension UIColor {
    var onFill: UIColor {
        resolvedColor(with: .init(userInterfaceStyle: .dark)).withAlphaComponent(1)
    }
}
