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

                Stepper(value: $viewModel.numCameras, in: 0...1000) {
                    HStack {
                        Text("Cameras")
                        Spacer()
                        TextField("", value: $viewModel.numCameras, formatter: intFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }

                Picker("NVR", selection: $viewModel.selectedNvr) {
                    ForEach(0..<viewModel.nvrOptions.count, id: \.self) { idx in
                        Text(viewModel.nvrOptions[idx]).tag(idx)
                    }
                }
            }

            // ── Add-ons ───────────────────────────────────────────────────
            Section(header: Text("Add-ons")) {
                Toggle("Server Backup",       isOn: $viewModel.includeServerBackup)
                Toggle("Workstation Backup",  isOn: $viewModel.includeWSBackup)
                Toggle("Advanced Email Security", isOn: $viewModel.includeEmailSec)
                Toggle("Huntress Cybersecurity", isOn: $viewModel.includeHuntress)
                Toggle("Webroot Cybersecurity",  isOn: $viewModel.includeWebroot)
            }

            // ── Total ─────────────────────────────────────────────────────
            Section {
                HStack {
                    Spacer()
                    Text("Total: \(viewModel.total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .bold()
                    Spacer()
                }
                if let pdfURL = viewModel.generatePDF() {
                    ShareLink("Download Quote", item: pdfURL)
                }
            }
        }
        .navigationTitle("Quote")
    }
}

#Preview {
    QuoteFormView()
}
