//
//  Signpost.swift
//  Nonograms
//
//  Created by Trevor Behlman on 9/1/25.
//

import os.log
import Foundation

class Signpost {
    private static let pointsOfInterest = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: .pointsOfInterest)

    static func begin(_ name: StaticString) {
        os_signpost(.begin, log: pointsOfInterest, name: name)
    }

    static func end(_ name: StaticString) {
        os_signpost(.end, log: pointsOfInterest, name: name)
    }
}
