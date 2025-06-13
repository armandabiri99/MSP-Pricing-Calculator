//
//  QuoteFormView.swift
//  MSP Pricing Calculator
//

import SwiftUI
import PhotosUI

// MARK: – Formatters
private let intFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .none
    return f
}()

private let percentFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 2
    return f
}()

// MARK: – View
struct QuoteFormView: View {
    // Live pricing comes from the shared store
    @ObservedObject var store: PricingStore
    @StateObject private var viewModel: QuoteViewModel

    // Logo-picker state
    @State private var logoItem: PhotosPickerItem?

    // ---- init so we can inject the PricingStore into the VM ------------
    init(store: PricingStore) {
        self.store = store
        _viewModel = StateObject(
            wrappedValue: QuoteViewModel(config: store.config)
        )
    }

    var body: some View {
        Form {

            // ── MSP info ────────────────────────────────────────────────
            Section(header: Text("MSP")) {
                TextField("Company Name",    text: $viewModel.companyName)
                TextField("Company Address", text: $viewModel.companyAddress)

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
                            await MainActor.run {
                                viewModel.logoImage = uiImg
                            }
                        }
                    }
                }
            }

            // ── Bill-to ────────────────────────────────────────────────
            Section(header: Text("Bill To")) {
                TextField("Customer Name",    text: $viewModel.customerName)
                TextField("Customer Address", text: $viewModel.customerAddress)
            }

            // ── Quote meta data ────────────────────────────────────────
            Section(header: Text("Quote Details")) {
                TextField("Quote #", text: $viewModel.quoteNumber)
                    .keyboardType(.numbersAndPunctuation)

                DatePicker("Quote Date", selection: $viewModel.quoteDate,
                           displayedComponents: .date)
                DatePicker("Due Date",   selection: $viewModel.dueDate,
                           displayedComponents: .date)

                HStack {
                    Text("Tax Rate (%)")
                    Spacer()
                    TextField("0", value: Binding(
                        get: { viewModel.taxRate * 100 },
                        set: { viewModel.taxRate = $0 / 100 }),
                        formatter: percentFormatter)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 70)
                }
            }

            // ── Terms & notes ──────────────────────────────────────────
            Section(header: Text("Terms & Notes")) {
                TextEditor(text: $viewModel.terms)
                    .frame(minHeight: 80)
            }

            // ── Device counts ──────────────────────────────────────────
            Section(header: Text("Devices")) {
                stepper("Servers",        $viewModel.numServers)
                stepper("Workstations",   $viewModel.numWorkstations)
                stepper("Email Accounts", $viewModel.numEmailAccounts)
                stepper("Cameras",        $viewModel.numCameras)

                Picker("NVR", selection: $viewModel.selectedNvr) {
                    ForEach(0 ..< viewModel.nvrOptions.count, id: \.self) { idx in
                        Text(viewModel.nvrOptions[idx]).tag(idx)
                    }
                }
            }

            // ── Add-ons ────────────────────────────────────────────────
            Section(header: Text("Add-ons")) {
                Toggle("Server Backup",           isOn: $viewModel.includeServerBackup)
                Toggle("Workstation Backup",      isOn: $viewModel.includeWSBackup)
                Toggle("Advanced Email Security", isOn: $viewModel.includeEmailSec)
                Toggle("Huntress Cybersecurity",  isOn: $viewModel.includeHuntress)
                Toggle("Webroot Cybersecurity",   isOn: $viewModel.includeWebroot)
            }

            // ── Totals & PDF download ─────────────────────────────────────
            Section {
                HStack {
                    Spacer()
                    Text("Total: \(viewModel.grandTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .bold()
                    Spacer()
                }
                
                if let pdf = viewModel.generatePDF() {
                    ShareLink("Download Quote", item: pdf)
                }
            }
        }
        .navigationTitle("Quote")
    }

    // MARK: helper
    @ViewBuilder
    private func stepper(_ label: String, _ value: Binding<Int>) -> some View {
        Stepper(value: value, in: 0 ... 1000) {
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

// MARK: – Preview
#Preview {
    NavigationStack {
        QuoteFormView(store: PricingStore())
    }
}
