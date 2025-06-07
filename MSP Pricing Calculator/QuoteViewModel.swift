import Foundation
import Combine

class QuoteViewModel: ObservableObject {
    @Published var numServers: Int = 0
    @Published var numWorkstations: Int = 0
    @Published var numEmailAccounts: Int = 0
    @Published var includeServerBackup: Bool = false
    @Published var includeWSBackup: Bool = false
    @Published var includeEmailSec: Bool = false

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

        return value
    }
}
