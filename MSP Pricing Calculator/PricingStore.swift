//
//  PricingStore.swift
//  MSP Pricing Calculator
//

import Foundation
import Combine

/// Observable wrapper around `PricingConfig` so multiple views stay in sync.
final class PricingStore: ObservableObject {

    // MARK: – Published state
    @Published private(set) var config: PricingConfig

    // MARK: – Init
    init(config: PricingConfig = .load()) {
        self.config = config
    }

    // MARK: – Helpers
    /// A pretty-printed JSON string (handy for exporting or debugging).
    var prettyJSON: String { config.prettyPrinted }

    // MARK: – Update methods
    /// Overwrite prices using **raw JSON** text (old Settings view).
    func updateConfig(from raw: String) {
        guard let data = raw.data(using: .utf8),
              let newConfig = try? JSONDecoder().decode(PricingConfig.self, from: data)
        else { return }

        config = newConfig
        config.save()
    }

    /// Overwrite prices with a **fully-formed `PricingConfig`**
    /// (used by the field-based Settings view).
    func updateConfig(from newConfig: PricingConfig) {
        config = newConfig
        config.save()
    }
}
