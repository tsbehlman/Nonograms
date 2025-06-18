//
//  NonogramsApp.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/1/25.
//

import SwiftUI

struct NonogramsApp: App {
    var body: some Scene {
        WindowGroup {
            PuzzleSolveView()
        }
    }
}

@main
struct NonogramsMain {
    static func main() {
#if DEBUG
        guard !(BuildChecker.areTestsRunning() || BuildChecker.arePreviewsRunning()) else {
            return TestApp.main()
        }
#endif
        NonogramsApp.main()
    }
}

#if DEBUG
struct TestApp: App {
    var body: some Scene {
        WindowGroup {}
    }
}
#endif
