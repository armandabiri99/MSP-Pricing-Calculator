//
//  PricingConfig.swift
//  MSP Pricing Calculator
//

import Foundation

// MARK: - Model

/// Top-level JSON structure stored in *pricing.json*.
struct PricingConfig: Codable {

    // MARK: Stored data
    var services: [Service]

    // MARK: Pricing look-up
    /// Returns the unit price for an internal service code, or 0 if missing.
    func price(for code: String) -> Double {
        services.first(where: { $0.code == code })?.unitPrice ?? 0
    }

    // MARK: Persistence helpers
    /// Documents-directory URL for the user-editable pricing file.
    private static var documentURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("pricing.json")
    }

    /// Loads from **Documents/pricing.json** if present; otherwise falls back to
    /// the bundled *pricing.json* shipped inside the app.
    static func load() -> PricingConfig {
        let decoder = JSONDecoder()

        // 1. Try user-modified copy
        if let url = documentURL,
           let data = try? Data(contentsOf: url),
           let cfg  = try? decoder.decode(PricingConfig.self, from: data) {
            return cfg
        }

        // 2. Fall back to bundle copy
        guard let url = Bundle.main.url(forResource: "pricing", withExtension: "json") else {
            fatalError("pricing.json not found in app bundle")
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(PricingConfig.self, from: data)
        } catch {
            fatalError("Failed to decode bundled pricing.json: \(error)")
        }
    }

    /// Saves a user-edited configuration into Documents/pricing.json.
    func save() {
        guard let url = Self.documentURL else { return }
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url, options: .atomic)
        } catch {
            print("⚠️ Could not save pricing.json: \(error)")
        }
    }
}

// MARK: - Utilities

extension PricingConfig {
    /// Returns the configuration as a pretty-printed, sorted JSON string —
    /// handy for the Settings text editor.
    var prettyPrinted: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(self),
              let str  = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }
}
