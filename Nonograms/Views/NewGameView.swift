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
                        Text("Show errors")
                    })
                    Picker(selection: $difficulty, content: {
                        Text("Easy").tag(PuzzleDifficulty.easy)
                        Text("Medium").tag(PuzzleDifficulty.medium)
                        Text("Hard").tag(PuzzleDifficulty.hard)
                    }, label: {
                        Text("Difficulty")
                    })
                }, footer: {
                    Text("Larger puzzles are more difficult by nature.")
                })
            }
                .listStyle(.insetGrouped)
                .listSectionSpacing(20)
                .contentMargins(.top, 10)
                .navigationTitle("New Game")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Close")
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            generateNewPuzzle()
                            dismiss()
                        }, label: {
                            Text("Play")
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
                Text("Square").tag(true)
                Text("Width \u{00D7} Height").tag(false)
            }, label: {
                Text("Puzzle shape")
            })
                .pickerStyle(.segmented)
                .labelsHidden()
            Group {
                if square {
                    Picker(selection: $puzzleWidth, content: {
                        ForEach(validSizes, id: \.self) { size in
                            Text("\(size) \u{00D7} \(size)").tag(size)
                        }
                    }, label: {
                        Text("Size")
                    })
                        .pickerStyle(.wheel)
                        .onChange(of: puzzleWidth) {
                            puzzleHeight = puzzleWidth
                        }
                } else {
                    HStack {
                        Picker(selection: $puzzleWidth, content: {
                            ForEach(validSizes, id: \.self) { size in
                                Text("\(size)").tag(size)
                            }
                        }, label: {
                            Text("Width")
                        })
                            .pickerStyle(.wheel)
                        Text("\u{00D7}")
                            .font(.title3)
                            .dynamicTypeSize(.large)
                        Picker(selection: $puzzleHeight, content: {
                            ForEach(validSizes, id: \.self) { size in
                                Text("\(size)").tag(size)
                            }
                        }, label: {
                            Text("Height")
                        })
                            .pickerStyle(.wheel)
                    }
                }
            }
                .frame(height: 128)
        }
    }
}

#Preview {
    @Previewable @State var gameState = GameState()

    NewGameView(gameState: $gameState)
}
