//
//  SettingsView.swift
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: PricingStore
    @State private var jsonText: String = ""

    var body: some View {
        Form {
            Section(header: Text("Raw pricing.json")) {
                TextEditor(text: $jsonText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 300)
                Button("Save to app bundle") {
                    store.updateConfig(from: jsonText)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear { jsonText = store.prettyJSON() }
        .navigationTitle("Pricing Settings")
    }
}

#Preview {
    SettingsView(store: PricingStore())
}