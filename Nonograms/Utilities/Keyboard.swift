//
//  Keyboard.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/20/25.
//

import GameController
import SwiftUICore

class KeyboardObserver: ObservableObject {
    @Published var keyboard: GCKeyboard?
    @Published var modifiers: EventModifiers = []

    var observer: Any? = nil

    init() {
        observer = NotificationCenter.default.addObserver(
            forName: .GCKeyboardDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }

            let keyboard = notification.object as? GCKeyboard
            keyboard?.keyboardInput?.keyChangedHandler = { keyboardInput, _, keyCode, pressed in
                var modifier: EventModifiers = []
                if keyCode == .leftAlt || keyCode == .rightAlt {
                    modifier = .option
                }

                if pressed {
                    self.modifiers.insert(modifier)
                } else {
                    self.modifiers.remove(modifier)
                }
            }
            self.keyboard = keyboard
        }
    }
}
