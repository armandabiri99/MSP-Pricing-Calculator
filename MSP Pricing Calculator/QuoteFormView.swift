import SwiftUI
import PhotosUI

private let intFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .none
    return f
}()

struct QuoteFormView: View {
    @StateObject private var viewModel = QuoteViewModel()
    @State private var logoItem: PhotosPickerItem?

    var body: some View {
        Form {
            // ── Company / Customer ─────────────────────────────────────
            Section(header: Text("Info")) {
                TextField("Company Name", text: $viewModel.companyName)
                TextField("Customer Name", text: $viewModel.customerName)

                PhotosPicker(selection: $logoItem, matching: .images) {
                    if let image = viewModel.logoImage {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Text("Select Logo")
                    }
                }
                .onChange(of: logoItem) { newItem in
                    guard let newItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let img = UIImage(data: data) {
                            viewModel.logoImage = img
                        }
                    }
                }
            }

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
