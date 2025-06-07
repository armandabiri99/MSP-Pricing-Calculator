//
//  PricingSettingsView.swift
//

import SwiftUI

private let priceFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal          // 25   or   19.99
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 2
    return f
}()

struct PricingSettingsView: View {
    @ObservedObject var store: PricingStore

    /// Work on a local copy so edits don’t affect live prices until “Save”.
    @State private var workingConfig: PricingConfig = .load()

    var body: some View {
        Form {
            Section(header: Text("Unit Prices")) {
                ForEach($workingConfig.services.indices, id: \.self) { idx in
                    HStack {
                        Text(workingConfig.services[idx].name)
                        Spacer()
                        TextField("Price",
                                  value: $workingConfig.services[idx].unitPrice,
                                  formatter: priceFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                    }
                }
            }

            Button("Save") {
                store.updateConfig(from: workingConfig)   // see note below
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear { workingConfig = store.config }        // pull current prices
        .navigationTitle("Pricing Settings")
    }
}

#Preview { PricingSettingsView(store: PricingStore()) }
