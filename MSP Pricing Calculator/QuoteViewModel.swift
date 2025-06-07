//
//  QuoteViewModel.swift
//  MSP Pricing Calculator
//

import Foundation
import Combine
import SwiftUI              // needed for @Published & ObservableObject
import UIKit                // UIImage is used in PDF generation

/// View-model that holds the user’s selections and does all pricing math.
final class QuoteViewModel: ObservableObject {

    // MARK: – Device counts
    @Published var numServers:        Int = 0
    @Published var numWorkstations:   Int = 0
    @Published var numEmailAccounts:  Int = 0
    @Published var numCameras:        Int = 0               // new feature

    // NVR selection (index into `nvrOptions`)
    @Published var selectedNvr:       Int = 0               // 0:none,1:8,2:16,3:32,4:64
    let nvrOptions = ["None", "8 Port", "16 Port", "32 Port", "64 Port"]

    // MARK: – Add-ons
    @Published var includeServerBackup:   Bool = false
    @Published var includeWSBackup:       Bool = false
    @Published var includeEmailSec:       Bool = false
    @Published var includeHuntress:       Bool = false      // ← new
    @Published var includeWebroot:        Bool = false      // ← new

    // MARK: – Branding (optional)
    @Published var companyName:       String = ""
    @Published var customerName:      String = ""
    @Published var logoImage:         UIImage? = nil

    // MARK: – Pricing data
    private let config: PricingConfig
    init(config: PricingConfig = PricingConfig.load()) {
        self.config = config
    }

    // convenience
    private func price(for code: String) -> Double {
        config.price(for: code)
    }

    // MARK: – Calculated total
    var total: Double {
        var value: Double = 0

        value += Double(numServers)       * price(for: "base_server")
        value += Double(numWorkstations)  * price(for: "base_ws")

        // add-ons
        if includeServerBackup  { value += Double(numServers)      * price(for: "bkup_server") }
        if includeWSBackup      { value += Double(numWorkstations) * price(for: "bkup_ws")     }
        if includeEmailSec      { value += Double(numEmailAccounts)* price(for: "email_sec")   }
        if includeHuntress      { value += Double(numWorkstations + numServers)
                                                * price(for: "huntress") }
        if includeWebroot       { value += Double(numWorkstations + numServers)
                                                * price(for: "webroot")  }

        // cameras / NVR
        value += Double(numCameras) * price(for: "camera")
        switch selectedNvr {
        case 1:  value += price(for: "nvr_8")
        case 2:  value += price(for: "nvr_16")
        case 3:  value += price(for: "nvr_32")
        case 4:  value += price(for: "nvr_64")
        default: break
        }

        return value
    }

    // MARK: – PDF quote generator
    /// Creates a one-page PDF with an optional logo and customer/company header.
    func generatePDF() -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0,
                                                            width: 612, height: 792))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("quote.pdf")

        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()

                var top: CGFloat = 40

                // --- logo --------------------------------------------------
                if let logo = logoImage {
                    logo.draw(in: CGRect(x: 40, y: top, width: 80, height: 80))
                    top += 90
                }

                // --- title -------------------------------------------------
                let title = companyName.isEmpty ? "(Name) Quote" : "\(companyName) Quote"
                let attrs: [NSAttributedString.Key : Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24)
                ]
                (title as NSString).draw(at: CGPoint(x: 40, y: top), withAttributes: attrs)
                top += 40

                // --- metadata ---------------------------------------------
                let formatter  = DateFormatter()
                formatter.dateStyle  = .medium
                formatter.timeStyle  = .short
                let dateStr = formatter.string(from: Date())

                ("Generated: \(dateStr)" as NSString)
                    .draw(at: CGPoint(x: 40, y: top),
                          withAttributes: [.font : UIFont.systemFont(ofSize: 14)])
                top += 20

                if !customerName.isEmpty {
                    ("Customer: \(customerName)" as NSString)
                        .draw(at: CGPoint(x: 40, y: top),
                              withAttributes: [.font : UIFont.systemFont(ofSize: 14)])
                    top += 20
                }

                var currentY = top

                func draw(_ text: String) {
                    (text as NSString).draw(at: CGPoint(x: 40, y: currentY),
                                            withAttributes: [.font : UIFont.systemFont(ofSize: 14)])
                    currentY += 20
                }

                // detail lines
                draw("Servers: \(numServers)")
                draw("Workstations: \(numWorkstations)")
                draw("Email Accounts: \(numEmailAccounts)")
                draw("Cameras: \(numCameras)")
                if selectedNvr > 0 { draw("NVR: \(nvrOptions[selectedNvr])") }
                if includeServerBackup { draw("Server Backup: Yes") }
                if includeWSBackup     { draw("Workstation Backup: Yes") }
                if includeEmailSec     { draw("Advanced Email Security: Yes") }
                if includeHuntress     { draw("Huntress Cybersecurity: Yes") }
                if includeWebroot      { draw("Webroot Cybersecurity: Yes") }

                currentY += 20
                let totalStr = String(format: "Total:  $%.2f", total)
                (totalStr as NSString)
                    .draw(at: CGPoint(x: 40, y: currentY),
                          withAttributes: [.font : UIFont.boldSystemFont(ofSize: 16)])
            }
            return url
        } catch {
            return nil
        }
    }
}