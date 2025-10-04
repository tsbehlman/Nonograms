//
//  Animation.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 9/23/25.
//

import SwiftUI

extension Animation {
    static func keyframes<Content: KeyframeTrackContent<Double>>(@KeyframeTrackContentBuilder<Double> _ content: () -> Content) -> Animation {
        Animation(KeyframeAnimation(content: content))
    }

    /// Skips the first frame of the animation. Can improve the apparent latency of an opacity transition
    func instant() -> Animation {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let maximumFramesPerSecond = scene?.windows.first?.screen.maximumFramesPerSecond ?? 60
        let frameInterval = TimeInterval(1.0 / TimeInterval(maximumFramesPerSecond))
        return self.delay(-frameInterval)
    }
}

class KeyframeAnimation<Content>: CustomAnimation where Content: KeyframeTrackContent<Double> {
    let trackContent: Content

    lazy var timeline: KeyframeTimeline<Double> = {
        KeyframeTimeline(initialValue: 0.0) {
            KeyframeTrack {
                trackContent
            }
        }
    }()

    init(@KeyframeTrackContentBuilder<Double> content: () -> Content) {
        trackContent = content()
    }

    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        guard time < timeline.duration else { return nil }
        return value.scaled(by: timeline.value(time: time))
    }

    static func == (lhs: KeyframeAnimation, rhs: KeyframeAnimation) -> Bool {
        return false
    }

    func hash(into hasher: inout Hasher) {}
}
