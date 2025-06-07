//
//  QuoteViewModel.swift
//  MSP Pricing Calculator
//

import Foundation
import SwiftUI
import UIKit          // UIImage for logo in PDF

/// View-model that holds the user’s selections and performs all pricing math.
final class QuoteViewModel: ObservableObject {

    // MARK: – Device counts
    @Published var numServers        = 0
    @Published var numWorkstations   = 0
    @Published var numEmailAccounts  = 0
    @Published var numCameras        = 0

    // MARK: – NVR
    @Published var selectedNvr       = 0           // 0:none, 1…4 = 8–64-port
    let nvrOptions = ["None", "8 Port", "16 Port", "32 Port", "64 Port"]

    // MARK: – Add-ons
    @Published var includeServerBackup = false
    @Published var includeWSBackup     = false
    @Published var includeEmailSec     = false
    @Published var includeHuntress     = false
    @Published var includeWebroot      = false

    // MARK: – Branding
    @Published var companyName  = ""
    @Published var customerName = ""
    @Published var logoImage: UIImage?

    // MARK: – Pricing source
    private let config: PricingConfig
    init(config: PricingConfig) { self.config = config }
    private func price(for code: String) -> Double { config.price(for: code) }

    // MARK: – Calculated total
    var total: Double {
        var value = 0.0

        value += Double(numServers)      * price(for: "base_server")
        value += Double(numWorkstations) * price(for: "base_ws")

        // add-ons
        if includeServerBackup { value += Double(numServers)      * price(for: "bkup_server") }
        if includeWSBackup     { value += Double(numWorkstations) * price(for: "bkup_ws")     }
        if includeEmailSec     { value += Double(numEmailAccounts) * price(for: "email_sec")  }
        if includeHuntress     { value += Double(numWorkstations + numServers) * price(for: "huntress") }
        if includeWebroot      { value += Double(numWorkstations + numServers) * price(for: "webroot")  }

        // cameras / NVR
        value += Double(numCameras) * price(for: "camera")
        switch selectedNvr {
        case 1: value += price(for: "nvr_8")
        case 2: value += price(for: "nvr_16")
        case 3: value += price(for: "nvr_32")
        case 4: value += price(for: "nvr_64")
        default: break
        }

        return value
    }

    // MARK: – PDF export
    func generatePDF() -> URL? {
        let bounds   = CGRect(x: 0, y: 0, width: 612, height: 792)   // US-Letter @ 72 dpi
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        let url      = FileManager.default.temporaryDirectory.appendingPathComponent("quote.pdf")

        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                var y: CGFloat = 40

                // logo
                if let logo = logoImage {
                    logo.draw(in: CGRect(x: 40, y: y, width: 80, height: 80))
                    y += 90
                }

                // title
                let title = companyName.isEmpty ? "(Name) Quote" : "\(companyName) Quote"
                (title as NSString).draw(at: CGPoint(x: 40, y: y),
                                         withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)])
                y += 40

                // metadata
                let df = DateFormatter()
                df.dateStyle = .medium; df.timeStyle = .short
                ("Generated: \(df.string(from: Date()))" as NSString)
                    .draw(at: CGPoint(x: 40, y: y),
                          withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                y += 20

                if !customerName.isEmpty {
                    ("Customer: \(customerName)" as NSString)
                        .draw(at: CGPoint(x: 40, y: y),
                              withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                    y += 20
                }

                func drawLine(_ text: String) {
                    (text as NSString).draw(at: CGPoint(x: 40, y: y),
                                            withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                    y += 20
                }

                // detail lines
                drawLine("Servers: \(numServers)")
                drawLine("Workstations: \(numWorkstations)")
                drawLine("Email Accounts: \(numEmailAccounts)")
                drawLine("Cameras: \(numCameras)")
                if selectedNvr > 0 { drawLine("NVR: \(nvrOptions[selectedNvr])") }
                if includeServerBackup { drawLine("Server Backup: Yes") }
                if includeWSBackup     { drawLine("Workstation Backup: Yes") }
                if includeEmailSec     { drawLine("Advanced Email Security: Yes") }
                if includeHuntress     { drawLine("Huntress Cybersecurity: Yes") }
                if includeWebroot      { drawLine("Webroot Cybersecurity: Yes") }

                y += 20
                let totalStr = String(format: "Total:  $%.2f", total)
                (totalStr as NSString)
                    .draw(at: CGPoint(x: 40, y: y),
                          withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            }
            return url
        } catch {
            return nil
        }
    }
}
