//
//  MSP_Pricing_CalculatorApp.swift
//  MSP Pricing Calculator
//

import SwiftUI

@main
struct MSP_Pricing_CalculatorApp: App {
    /// Shared store that owns the PricingConfig and publishes changes.
    @StateObject private var store = PricingStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {                     // ── Quote tab
                    QuoteFormView(store: store)
                }
                .tabItem { Label("Quote", systemImage: "doc.plaintext") }

                NavigationStack {                     // ── Settings tab
                    SettingsView(store: store)
                }
                .tabItem { Label("Settings", systemImage: "gear") }
            }
        }
    }
}