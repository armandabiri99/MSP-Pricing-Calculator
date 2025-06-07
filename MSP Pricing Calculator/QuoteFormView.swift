import SwiftUI

private let intFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .none
    return f
}()

struct QuoteFormView: View {
    @StateObject private var viewModel = QuoteViewModel()

    var body: some View {
        Form {
            // ── Device counts ─────────────────────────────────────────────
            Section(header: Text("Devices")) {

                Stepper(value: $viewModel.numServers, in: 0...100) {
                    HStack {
                        Text("Servers")
                        Spacer()
                        TextField("", value: $viewModel.numServers, formatter: intFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }

                Stepper(value: $viewModel.numWorkstations, in: 0...1000) {
                    HStack {
                        Text("Workstations")
                        Spacer()
                        TextField("", value: $viewModel.numWorkstations, formatter: intFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }

                Stepper(value: $viewModel.numEmailAccounts, in: 0...1000) {
                    HStack {
                        Text("Email Accounts")
                        Spacer()
                        TextField("", value: $viewModel.numEmailAccounts, formatter: intFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }
            }

            // ── Add-ons ───────────────────────────────────────────────────
            Section(header: Text("Add-ons")) {
                Toggle("Server Backup",       isOn: $viewModel.includeServerBackup)
                Toggle("Workstation Backup",  isOn: $viewModel.includeWSBackup)
                Toggle("Advanced Email Security", isOn: $viewModel.includeEmailSec)
            }

            // ── Total ─────────────────────────────────────────────────────
            Section {
                HStack {
                    Spacer()
                    Text("Total: \(viewModel.total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .bold()
                    Spacer()
                }
            }
        }
        .navigationTitle("Quote")
    }
}

#Preview {
    QuoteFormView()
}
