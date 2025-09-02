//
//  SettingsView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/2/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var gameState: GameState
    @Environment(\.dismiss) var dismiss
    @AppStorage("difficulty") var difficulty = NonogramsDefaults.difficulty
    @AppStorage("tileSize") var tileSize = NonogramsDefaults.tileSize
    @AppStorage("validate") var validate = NonogramsDefaults.validate
    @AppStorage("autofill") var autofill = NonogramsDefaults.autofill

    var body: some View {
        NavigationView {
            List {
                Section("puzzleTileSizeSetting", content: {
                    Slider(value: $tileSize, in: 38...54, step: 2, label: {
                        Text("puzzleTileSizeSetting")
                    }, minimumValueLabel: {
                        Image(systemName: "squareshape.split.3x3").imageScale(.medium)
                    }, maximumValueLabel: {
                        Image(systemName: "squareshape.split.2x2").imageScale(.large)
                    })
                })
                Toggle(isOn: $autofill, label: {
                    Text("autofillSetting")
                })
                    .onChange(of: autofill) {
                        gameState.autofill = autofill
                    }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("settingsDialogTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("closeDialog")
                })
            }
        }
    }
}

#Preview {
    @Previewable @State var gameState = GameState()

    SettingsView(gameState: $gameState)
}
