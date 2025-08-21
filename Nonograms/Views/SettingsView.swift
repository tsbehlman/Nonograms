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
                Section("Grid size", content: {
                    Slider(value: $tileSize, in: 38...54, step: 2, label: {
                        Text("Tile size")
                    }, minimumValueLabel: {
                        Image(systemName: "squareshape.split.3x3").imageScale(.medium)
                    }, maximumValueLabel: {
                        Image(systemName: "squareshape.split.2x2").imageScale(.large)
                    })
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
