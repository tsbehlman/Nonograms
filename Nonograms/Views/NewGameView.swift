//
//  NewGameView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/20/25.
//

import SwiftUI

private let validSizes = 5...15

struct NewGameView: View {
    @Binding var gameState: GameState

    @Environment(\.dismiss) var dismiss

    @AppStorage("difficulty") var difficulty = NonogramsDefaults.difficulty
    @AppStorage("validate") var validate = NonogramsDefaults.validate
    @AppStorage("puzzleWidth") var puzzleWidth = NonogramsDefaults.puzzleWidth
    @AppStorage("puzzleHeight") var puzzleHeight = NonogramsDefaults.puzzleHeight
    @AppStorage("square") var square = NonogramsDefaults.square

    var body: some View {
        NavigationView {
            List {
                Section {
                    PuzzleSizeControl()
                        .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
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
    @AppStorage("puzzleWidth") var puzzleWidth = NonogramsDefaults.puzzleWidth
    @AppStorage("puzzleHeight") var puzzleHeight = NonogramsDefaults.puzzleHeight
    @AppStorage("square") var square = NonogramsDefaults.square

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
            Group {
                if square {
                    Picker(selection: $puzzleWidth, content: {
                        ForEach(validSizes, id: \.self) { size in
                            Text(verbatim: "\(size) \u{00D7} \(size)").tag(size)
                        }
                    }, label: {
                        Text("puzzleShapeSize")
                    })
                        .pickerStyle(.wheel)
                        .onChange(of: puzzleWidth) {
                            puzzleHeight = puzzleWidth
                        }
                } else {
                    HStack {
                        Picker(selection: $puzzleWidth, content: {
                            ForEach(validSizes, id: \.self) { size in
                                Text(verbatim: "\(size)").tag(size)
                            }
                        }, label: {
                            Text("puzzleShapeWidth")
                        })
                            .pickerStyle(.wheel)
                        Text(verbatim: "\u{00D7}")
                            .font(.title3)
                            .dynamicTypeSize(.large)
                        Picker(selection: $puzzleHeight, content: {
                            ForEach(validSizes, id: \.self) { size in
                                Text(verbatim: "\(size)").tag(size)
                            }
                        }, label: {
                            Text("puzzleShapeHeight")
                        })
                            .pickerStyle(.wheel)
                    }
                }
            }
                .frame(height: 128)
        }
    }
}

struct NewGameSheetView: View {
    @Binding var gameState: GameState
    @State var height: CGFloat = 0

    var body: some View {
        NewGameView(gameState: $gameState)
            .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentSize.height + geometry.contentInsets.top + geometry.contentInsets.bottom
            }) {
                height = $1
            }
            .presentationDetents([.height(height), .large])
    }
}

#Preview {
    @Previewable @State var gameState = GameState()

    NewGameView(gameState: $gameState)
}
