import SwiftUI

private let priceFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 2
    return f
}()

struct SettingsView: View {
    @ObservedObject var store: PricingStore

    var body: some View {
        Form {
            Section(header: Text("Pricing")) {
                ForEach(store.config.services.indices, id: \.self) { idx in
                    HStack {
                        Text(store.config.services[idx].name)
                        Spacer()
                        TextField("", value: $store.config.services[idx].unitPrice, formatter: priceFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            Button("Save") {
                store.save()
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView(store: PricingStore())
}
