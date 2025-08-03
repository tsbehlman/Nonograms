//
//  SettingsView.swift
//  Nonograms
//
//  Created by Trevor Behlman on 8/2/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("tileSize") var tileSize = NonogramsDefaults.tileSize

    var body: some View {
        NavigationView {
            List {
                Picker(selection: $tileSize, content: {
                    Text("Extra small").tag(38)
                    Text("Small").tag(42)
                    Text("Medium").tag(46)
                    Text("Large").tag(50)
                    Text("Extra large").tag(54)
                }, label: {
                    Text("Tile size")
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
