import Foundation
import Combine
import UIKit
import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var numServers: Int = 0
    @Published var numWorkstations: Int = 0
    @Published var numEmailAccounts: Int = 0
    @Published var numCameras: Int = 0
    @Published var selectedNvr: Int = 0 // 0:none,1:8,2:16,3:32,4:64
    @Published var includeServerBackup: Bool = false
    @Published var includeWSBackup: Bool = false
    @Published var includeEmailSec: Bool = false
    @Published var includeHuntress: Bool = false
    @Published var includeWebroot: Bool = false

    // Branding
    @Published var companyName: String = ""
    @Published var customerName: String = ""
    @Published var logoImage: UIImage?

    let nvrOptions = ["None", "8 Port", "16 Port", "32 Port", "64 Port"]

    private let config: PricingConfig

    init(config: PricingConfig = PricingConfig.load()) {
        self.config = config
    }

    private func price(for code: String) -> Double {
        config.price(for: code)
    }

    var total: Double {
        var value: Double = 0
        value += Double(numServers) * price(for: "base_server")
        value += Double(numWorkstations) * price(for: "base_ws")

        if includeServerBackup {
            value += Double(numServers) * price(for: "bkup_server")
        }
        if includeWSBackup {
            value += Double(numWorkstations) * price(for: "bkup_ws")
        }
        if includeEmailSec {
            value += Double(numEmailAccounts) * price(for: "email_sec")
        }

        if includeHuntress {
            value += Double(numWorkstations) * price(for: "huntress")
        }
        if includeWebroot {
            value += Double(numWorkstations) * price(for: "webroot")
        }

        switch selectedNvr {
        case 1: value += price(for: "nvr_8")
        case 2: value += price(for: "nvr_16")
        case 3: value += price(for: "nvr_32")
        case 4: value += price(for: "nvr_64")
        default: break
        }

        value += Double(numCameras) * price(for: "camera")

        return value
    }

    func generatePDF() -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("quote.pdf")
        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                let name = companyName.isEmpty ? "My Company" : companyName
                let title = "\(name) Quote"
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .paragraphStyle: paragraphStyle
                ]
                var top: CGFloat = 40
                if let logo = logoImage {
                    logo.draw(in: CGRect(x: 40, y: 20, width: 80, height: 80))
                    top = 110
                }
                title.draw(in: CGRect(x: 0, y: top, width: 612, height: 30), withAttributes: attrs)

                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                let dateStr = formatter.string(from: Date())
                var currentY = top + 40
                ("Generated: \(dateStr)" as NSString).draw(at: CGPoint(x: 40, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                currentY += 20
                if !customerName.isEmpty {
                    ("Customer: \(customerName)" as NSString).draw(at: CGPoint(x: 40, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                }

                var y = Double(currentY + 40)
                func draw(_ text: String) {
                    (text as NSString).draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                    y += 20
                }

                draw("Servers: \(numServers)")
                draw("Workstations: \(numWorkstations)")
                draw("Email Accounts: \(numEmailAccounts)")
                draw("Cameras: \(numCameras)")
                if selectedNvr > 0 { draw("NVR: \(nvrOptions[selectedNvr])") }
                if includeServerBackup { draw("Server Backup: Yes") }
                if includeWSBackup { draw("Workstation Backup: Yes") }
                if includeEmailSec { draw("Advanced Email Security: Yes") }
                if includeHuntress { draw("Huntress Cybersecurity: Yes") }
                if includeWebroot { draw("Webroot Cybersecurity: Yes") }

                y += 20
                let totalStr = String(format: "Total: $%.2f", total)
                (totalStr as NSString).draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            }
            return url
        } catch {
            return nil
        }
    }
}
