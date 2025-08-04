//
//  SettingsView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/2/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("difficulty") var difficulty = NonogramsDefaults.difficulty
    @AppStorage("tileSize") var tileSize = NonogramsDefaults.tileSize
    @AppStorage("validate") var validate = NonogramsDefaults.validate

    var body: some View {
        NavigationView {
            List {
                Section(content: {
                    Picker(selection: $difficulty, content: {
                        Text("Easy").tag(PuzzleDifficulty.easy)
                        Text("Medium").tag(PuzzleDifficulty.medium)
                        Text("Hard").tag(PuzzleDifficulty.hard)
                    }, label: {
                        Text("Difficulty")
                    })
                }, footer: {
                    Text("Applies to future puzzles. Larger puzzles are more difficult by nature.")
                })
                Section("Grid size", content: {
                    Slider(value: $tileSize, in: 38...54, step: 2, label: {
                        Text("Tile size")
                    }, minimumValueLabel: {
                        Image(systemName: "square.grid.2x2").imageScale(.small)
                    }, maximumValueLabel: {
                        Image(systemName: "square.grid.2x2").imageScale(.large)
                    })
                })
                Toggle(isOn: $validate, label: {
                    Text("Show errors")
                })
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Close")
                })
            }
        }
    }
}

#Preview {
    SettingsView()
}
