//
//  MSP_Pricing_CalculatorApp.swift
//  MSP Pricing Calculator
//
//  Created by Arman Dabiri on 6/6/25.
//

import SwiftUI

@main
struct MSP_Pricing_CalculatorApp: App {
    @StateObject private var store = PricingStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    QuoteFormView(store: store)
                }
                .tabItem { Label("Quote", systemImage: "doc.plaintext") }

                NavigationStack {
                    SettingsView(store: store)
                }
                .tabItem { Label("Settings", systemImage: "gear") }
            }
        }
    }
}
