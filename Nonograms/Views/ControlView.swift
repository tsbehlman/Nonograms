//
//  ControlView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 6/2/25.
//

import SwiftUI

struct ControlModeButton: View {
    @Binding var mode: InteractionMode
    let control: TileState
    let disabled: Bool

    var body: some View {
        ControlButton(active: mode.tileState == control, disabled: disabled, bordered: false) {
            Group {
                if control == .blocked {
                    BlockedTileIcon()
                        .padding(2)
                } else {
                    FilledTileIcon()
                }
            }
        }
            .onTapGesture {
                if !disabled {
                    mode = .fill(control)
                }
            }
    }
}

struct ControlView: View {
    @StateObject var keyboardObserver = KeyboardObserver()
    @Binding var gameState: GameState
    let fitsView: Bool
    @Binding var showSettings: Bool
    @Binding var showNewGame: Bool

    var body: some View {
        HStack(spacing: 12) {
            StaggeredStack(angle: .degrees(-45), spacing: 16) {
                ControlIconButton(icon: "gearshape")
                    .onTapGesture {
                        showSettings = true
                    }
                ControlIconButton(icon: "arrow.2.circlepath")
                    .when(gameState.isSolved) {
                        $0.background(RippleView())
                    }
                    .onTapGesture {
                        showNewGame = true
                    }
                ControlIconButton(icon: "questionmark")
                    .when(gameState.isEmpty) {
                        $0.background(RippleView())
                    }
                    .onTapGesture {
                        gameState.showHint()
                    }
            }
            Spacer()
            StaggeredStack(angle: .degrees(45), spacing: 16) {
                ControlModeButton(mode: $gameState.mode, control: .filled, disabled: false)
                ControlModeButton(mode: $gameState.mode, control: .blocked, disabled: false)
                ControlIconButton(icon: "arrow.up.and.down.and.arrow.left.and.right", active: !fitsView && gameState.mode.tileState == nil, disabled: fitsView, bordered: false)
                    .onTapGesture {
                        if !fitsView {
                            gameState.mode = .move
                        }
                    }
            }
                .traceBackground(padding: 7, curvature: 21) {
                    $0.stroke(Color.primary.opacity(0.375)).fill(Color.primary.opacity(0.25))
                }
                .overlay(alignment: .bottom) {
                    HStack {
                        ControlIconButton(icon: "arrow.uturn.left", disabled: !gameState.hasUndo, size: .small)
                            .onTapGesture {
                                gameState.undo()
                            }
                        Spacer()
                        ControlIconButton(icon: "arrow.uturn.right", disabled: !gameState.hasRedo, size: .small)
                            .onTapGesture {
                                gameState.redo()
                            }
                    }
                }
        }
        .onChange(of: keyboardObserver.modifiers.contains(.option)) { _, isOptionPressed in
            if isOptionPressed {
                gameState.mode = .fill(.blocked)
            } else {
                gameState.mode = .fill(.filled)
            }
        }
        .onChange(of: fitsView) { _, fitsView in
            if fitsView, case .move = gameState.mode {
                gameState.mode = .fill(.blocked)
            }
        }
    }
}

#Preview {
    @Previewable @State var gameState = GameState()
    @Previewable @State var showSettings = false
    @Previewable @State var showNewGame = false

    ControlView(gameState: $gameState, fitsView: false, showSettings: $showSettings, showNewGame: $showNewGame)
        .padding()
}
