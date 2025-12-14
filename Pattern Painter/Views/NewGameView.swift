//
//  NewGameView.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 8/20/25.
//

import SwiftUI

private let validSizes = 5...15

struct NewGameView: View {
    @Binding var gameState: GameState

    @Environment(\.dismiss) var dismiss

    @AppStorage("difficulty") var difficulty = AppDefaults.difficulty
    @AppStorage("validate") var validate = AppDefaults.validate
    @AppStorage("puzzleWidth") var puzzleWidth = AppDefaults.puzzleWidth
    @AppStorage("puzzleHeight") var puzzleHeight = AppDefaults.puzzleHeight
    @AppStorage("square") var square = AppDefaults.square

    var body: some View {
        NavigationView {
            List {
                Section {
                    PuzzleSizeControl()
                        .listRowInsets(EdgeInsets(.zero))
                }
                Section(content: {
                    Toggle(isOn: $validate, label: {
                        Text("validateSetting")
                    })
                    Picker(selection: $difficulty, content: {
                        Text("difficultyOptionEasy").tag(PuzzleDifficulty.easy)
                        Text("difficultyOptionMedium").tag(PuzzleDifficulty.medium)
                        Text("difficultyOptionHard").tag(PuzzleDifficulty.hard)
                    }, label: {
                        Text("difficultySetting")
                    })
                }, footer: {
                    Text("difficultySettingInfo")
                })
            }
                .listStyle(.insetGrouped)
                .listSectionSpacing(20)
                .contentMargins(.top, 10)
                .navigationTitle("newGameDialogTitle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("closeDialog")
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            generateNewPuzzle()
                            dismiss()
                        }, label: {
                            Text("startGame")
                        })
                    }
                }
        }
    }

    func generateNewPuzzle() {
        gameState = gameState.newGame(width: puzzleWidth, height: puzzleHeight, difficulty: difficulty, validate: validate)
    }
}

struct PuzzleSizeControl: View {
    @AppStorage("puzzleWidth") var puzzleWidth = AppDefaults.puzzleWidth
    @AppStorage("puzzleHeight") var puzzleHeight = AppDefaults.puzzleHeight
    @AppStorage("square") var square = AppDefaults.square

    var body: some View {
        VStack(spacing: 2) {
            Picker(selection: $square, content: {
                Text("puzzleShapeSquare").tag(true)
                Text("puzzleShapeRectangular").tag(false)
            }, label: {
                Text("puzzleShapeSetting")
            })
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding([.horizontal, .top], 9)
            Group {
                if square {
                    WheelPicker(selection: $puzzleWidth, items: validSizes.map { size in
                        PickerItem(title: "\(size) \u{00D7} \(size)", value: size)
                    })
                        .onChange(of: puzzleWidth, initial: true) {
                            puzzleHeight = puzzleWidth
                        }
                } else {
                    HStack {
                        WheelPicker(selection: $puzzleWidth, items: validSizes.map { size in
                            PickerItem(title: "\(size)", value: size)
                        })
                        Text(verbatim: "\u{00D7}")
                            .font(.title3)
                        WheelPicker(selection: $puzzleHeight, items: validSizes.map { size in
                            PickerItem(title: "\(size)", value: size)
                        })
                    }
                }
            }
                .frame(height: 150)
                .dynamicTypeSize(.large)
        }
    }
}

struct NewGameSheetView: View {
    @Binding var gameState: GameState
    @State var detents: Set<PresentationDetent> = [.large]
    @State private var selectedDetent: PresentationDetent = .large

    var body: some View {
        NewGameView(gameState: $gameState)
            .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                (geometry.contentSize.height + geometry.contentInsets.top).rounded()
            }, action: {
                selectedDetent = .height($1)
                detents = [.large, selectedDetent]
            })
            .presentationDetents(detents, selection: $selectedDetent)
    }
}

#Preview {
    @Previewable @State var gameState = GameState()

    NewGameView(gameState: $gameState)
}
