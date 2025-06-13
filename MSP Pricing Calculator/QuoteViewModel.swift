//
//  QuoteViewModel.swift
//  MSP Pricing Calculator
//

import Foundation
import SwiftUI
import UIKit               // for UIImage in PDF export

/// View-model that holds the user’s selections *and* produces the PDF.
/// Most views bind directly to these `@Published` properties.
@MainActor
final class QuoteViewModel: ObservableObject {

    // ─────────────────────────  MSP branding  ────────────────────────────
    @Published var companyName      = ""
    @Published var companyAddress   = ""
    @Published var logoImage: UIImage?

    // ─────────────────────────  Bill-to section  ─────────────────────────
    @Published var customerName     = ""
    @Published var customerAddress  = ""

    // ─────────────────────────  Quote metadata  ──────────────────────────
    @Published var quoteNumber      = ""
    @Published var quoteDate        = Date()
    @Published var dueDate          = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    @Published var taxRate: Double  = 0.0            // 8.5 %  →  0.085

    // ─────────────────────────  Devices  ────────────────────────────────
    @Published var numServers       = 0
    @Published var numWorkstations  = 0
    @Published var numEmailAccounts = 0
    @Published var numCameras       = 0

    // NVR
    let nvrOptions = ["None","8 Port","16 Port","32 Port","64 Port"]
    @Published var selectedNvr      = 0              // index into `nvrOptions`

    // ─────────────────────────  Add-ons  ────────────────────────────────
    @Published var includeServerBackup = false
    @Published var includeWSBackup     = false
    @Published var includeEmailSec     = false
    @Published var includeHuntress     = false
    @Published var includeWebroot      = false

    // ─────────────────────────  Terms  ──────────────────────────────────
    @Published var terms = "Payment is due in 14 days.\nChecks payable to: Your Company Inc."

    // ─────────────────────────  Pricing  ────────────────────────────────
    private let config: PricingConfig
    init(config: PricingConfig = .load()) { self.config = config }

    private func price(for code: String) -> Double { config.price(for: code) }

    /// Sub-total before any taxes.
    var subTotal: Double {
        var v = 0.0
        v += Double(numServers)      * price(for: "base_server")
        v += Double(numWorkstations) * price(for: "base_ws")

        // add-ons
        if includeServerBackup { v += Double(numServers)      * price(for: "bkup_server") }
        if includeWSBackup     { v += Double(numWorkstations) * price(for: "bkup_ws")     }
        if includeEmailSec     { v += Double(numEmailAccounts) * price(for: "email_sec")  }
        if includeHuntress     { v += Double(numWorkstations + numServers) * price(for: "huntress") }
        if includeWebroot      { v += Double(numWorkstations + numServers) * price(for: "webroot")  }

        // cameras / NVR
        v += Double(numCameras) * price(for: "camera")
        switch selectedNvr {
        case 1: v += price(for: "nvr_8")
        case 2: v += price(for: "nvr_16")
        case 3: v += price(for: "nvr_32")
        case 4: v += price(for: "nvr_64")
        default: break
        }
        return v
    }

    /// Final amount including tax.
    var grandTotal: Double { subTotal * (1.0 + taxRate) }

    // MARK: – PDF export (kept simple for brevity)
    func generatePDF() -> URL? {
        let page   = CGRect(x: 0, y: 0, width: 612, height: 792) // US-Letter at 72 dpi
        let url    = FileManager.default.temporaryDirectory
                        .appendingPathComponent("quote.pdf")

        let pdf = UIGraphicsPDFRenderer(bounds: page).pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 40

            // logo
            if let img = logoImage {
                img.draw(in: CGRect(x: 40, y: y, width: 80, height: 80))
            }

            // header
            let header = companyName.isEmpty ? "Quote" : "\(companyName) – Quote"
            (header as NSString).draw(at: CGPoint(x: 140, y: y+25),
                                      withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)])

            y += 100
            ("Customer: \(customerName)" as NSString)
                .draw(at: CGPoint(x: 40, y: y),
                      withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            y += 20
            ("Quote #: \(quoteNumber)   Date: \(quoteDate.formatted(date: .abbreviated, time: .omitted))"
             as NSString)
                .draw(at: CGPoint(x: 40, y: y),
                      withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            y += 40

            // line items – very compact representation
            func item(_ label: String, qty: Int, each: Double) {
                guard qty > 0 else { return }
                (label as NSString).draw(at: CGPoint(x: 40, y: y),
                                         withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                let amount = Double(qty) * each
                let str = String(format: "$%.2f", amount)
                (str as NSString).draw(at: CGPoint(x: 500, y: y),
                                       withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                y += 18
            }

            item("Servers ×\(numServers)",          qty: numServers,      each: price(for:"base_server"))
            item("Workstations ×\(numWorkstations)",qty: numWorkstations, each: price(for:"base_ws"))
            item("Email Accounts ×\(numEmailAccounts)",qty: numEmailAccounts, each: price(for:"email_sec"))
            item("Cameras ×\(numCameras)",          qty: numCameras,      each: price(for:"camera"))
            if selectedNvr > 0 {
                item("NVR \(nvrOptions[selectedNvr])", qty: 1,
                     each: price(for:"nvr_\( [8,16,32,64][selectedNvr-1])"))
            }
            if includeServerBackup { item("Server Backup", qty: numServers, each: price(for:"bkup_server")) }
            if includeWSBackup     { item("Workstation Backup", qty: numWorkstations, each: price(for:"bkup_ws")) }
            if includeHuntress     { item("Huntress", qty: numServers+numWorkstations, each: price(for:"huntress")) }
            if includeWebroot      { item("Webroot",  qty: numServers+numWorkstations, each: price(for:"webroot")) }

            y += 10
            ("Subtotal:  \(String(format: "$%.2f", subTotal))" as NSString)
                .draw(at: CGPoint(x: 380, y: y),
                      withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            y += 18
            ("Tax (\(Int(taxRate*100)) %): \(String(format:"$%.2f", subTotal*taxRate))" as NSString)
                .draw(at: CGPoint(x: 380, y: y),
                      withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            y += 18
            ("TOTAL: \(String(format:"$%.2f", grandTotal))" as NSString)
                .draw(at: CGPoint(x: 380, y: y),
                      withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])

            y += 40
            (terms as NSString)
                .draw(in: CGRect(x: 40, y: y, width: 500, height: 200),
                      withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
        }

        do { try pdf.write(to: url); return url } catch { return nil }
    }
}
