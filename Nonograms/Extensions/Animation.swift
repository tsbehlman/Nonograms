//
//  Animation.swift
//  Nonograms
//
//  Created by Trevor Behlman on 9/23/25.
//

import SwiftUI

extension Animation {
    /// Skips the first frame of the animation. Can improve the apparent latency of an opacity transition
    func instant() -> Animation {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let maximumFramesPerSecond = scene?.windows.first?.screen.maximumFramesPerSecond ?? 60
        let frameInterval = TimeInterval(1.0 / TimeInterval(maximumFramesPerSecond))
        return self.delay(-frameInterval)
    }
}
