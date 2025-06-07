import Foundation

struct PricingConfig: Codable {
    var services: [Service]

    func price(for code: String) -> Double {
        services.first(where: { $0.code == code })?.unitPrice ?? 0
    }

    private static var documentURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("pricing.json")
    }

    static func load() -> PricingConfig {
        let decoder = JSONDecoder()
        if let docURL = documentURL, let data = try? Data(contentsOf: docURL) {
            if let cfg = try? decoder.decode(PricingConfig.self, from: data) {
                return cfg
            }
        }
        guard let url = Bundle.main.url(forResource: "pricing", withExtension: "json") else {
            fatalError("pricing.json not found")
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(PricingConfig.self, from: data)
        } catch {
            fatalError("Failed to load pricing.json: \(error)")
        }
    }

    func save() {
        guard let url = PricingConfig.documentURL else { return }
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: url)
        }
    }
}
