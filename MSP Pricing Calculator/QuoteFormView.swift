//
//  QuoteFormView.swift
//  MSP Pricing Calculator
//

import SwiftUI
import PhotosUI

private let intFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .none
    return f
}()

struct QuoteFormView: View {
    // Live pricing comes from the shared store
    @ObservedObject var store: PricingStore
    @StateObject private var viewModel: QuoteViewModel

    // logo picker UI state
    @State private var logoItem: PhotosPickerItem?

    // --- init so we can pass the store into the ViewModel -------------
    init(store: PricingStore) {
        self.store      = store
        _viewModel      = StateObject(wrappedValue: QuoteViewModel(config: store.config))
    }

    var body: some View {
        Form {

            // ── MSP info ───────────────────────────────────────────────
            Section(header: Text("MSP")) {
                TextField("Company Name", text: $viewModel.companyName)

                PhotosPicker(selection: $logoItem, matching: .images) {
                    if let img = viewModel.logoImage {
                        Image(uiImage: img)
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
                           let uiImg = UIImage(data: data) {
                            viewModel.logoImage = uiImg
                        }
                    }
                }
            }

            // ── Customer info ─────────────────────────────────────────
            Section(header: Text("Customer")) {
                TextField("Customer Name", text: $viewModel.customerName)
            }

            // ── Device counts ────────────────────────────────────────
            Section(header: Text("Devices")) {
                deviceStepper("Servers",       value: $viewModel.numServers)
                deviceStepper("Workstations",  value: $viewModel.numWorkstations)
                deviceStepper("Email Accounts",value: $viewModel.numEmailAccounts)
                deviceStepper("Cameras",       value: $viewModel.numCameras)

                Picker("NVR", selection: $viewModel.selectedNvr) {
                    ForEach(0..<viewModel.nvrOptions.count, id: \.self) { idx in
                        Text(viewModel.nvrOptions[idx]).tag(idx)
                    }
                }
            }

            // ── Add-ons ───────────────────────────────────────────────
            Section(header: Text("Add-ons")) {
                Toggle("Server Backup",       isOn: $viewModel.includeServerBackup)
                Toggle("Workstation Backup",  isOn: $viewModel.includeWSBackup)
                Toggle("Advanced Email Security", isOn: $viewModel.includeEmailSec)
                Toggle("Huntress Cybersecurity",  isOn: $viewModel.includeHuntress)
                Toggle("Webroot Cybersecurity",   isOn: $viewModel.includeWebroot)
            }

            // ── Total & PDF ───────────────────────────────────────────
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

    // MARK: helper
    @ViewBuilder
    private func deviceStepper(_ label: String, value: Binding<Int>) -> some View {
        Stepper(value: value, in: 0...1000) {
            HStack {
                Text(label)
                Spacer()
                TextField("", value: value, formatter: intFormatter)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }
        }
    }
}

#Preview {
    QuoteFormView(store: PricingStore())
}