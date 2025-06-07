import Foundation

struct PricingConfig: Codable {
    var services: [Service]

    func price(for code: String) -> Double {
        services.first(where: { $0.code == code })?.unitPrice ?? 0
    }

    static func load() -> PricingConfig {
        guard let url = Bundle.main.url(forResource: "pricing", withExtension: "json") else {
            fatalError("pricing.json not found")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(PricingConfig.self, from: data)
        } catch {
            fatalError("Failed to load pricing.json: \(error)")
        }
    }
}
