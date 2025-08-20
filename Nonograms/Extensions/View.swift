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

extension View {
    func keyframeAnimation<Value: Equatable, Content: KeyframeTrackContent<Double>>(_ value: Value, @KeyframeTrackContentBuilder<Double> _ content: () -> Content) -> some View {
        animation(Animation(KeyframeAnimation(content: content)), value: value)
    }
}

extension AnyTransition {
    func keyframeAnimation<Content: KeyframeTrackContent<Double>>(@KeyframeTrackContentBuilder<Double> _ content: () -> Content) -> AnyTransition {
        animation(Animation(KeyframeAnimation(content: content)))
    }
}
