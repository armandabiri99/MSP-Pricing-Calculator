import Foundation

class PricingStore: ObservableObject {
    @Published var config: PricingConfig

    init() {
        self.config = PricingConfig.load()
    }

    func save() {
        config.save()
    }

    func reload() {
        config = PricingConfig.load()
    }
}
