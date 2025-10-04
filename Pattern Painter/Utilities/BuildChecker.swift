//
//  BuildChecker.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 6/17/25.
//

import Foundation

#if DEBUG
struct BuildChecker {
    static func areTestsRunning() -> Bool {
        NSClassFromString("XCTest") != nil
    }

    static func arePreviewsRunning() -> Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
}
#endif
