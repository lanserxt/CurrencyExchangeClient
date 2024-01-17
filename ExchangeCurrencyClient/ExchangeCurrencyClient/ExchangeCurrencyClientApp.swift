//
//  ExchangeCurrencyClientApp.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 17.01.2024.
//

import SwiftUI

@main
struct ExchangeCurrencyClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        setupDefaultValues()
    }
    
    /// Setting default conversion values
    private func setupDefaultValues() {
        if UserDefaults.standard.object(forKey: Constants.UserDefaults.fromCurrency) == nil {
            UserDefaults.standard.setValue(Currency.euro.rawValue, forKey: Constants.UserDefaults.fromCurrency)
        }
        if UserDefaults.standard.object(forKey: Constants.UserDefaults.toCurrency) == nil {
            UserDefaults.standard.setValue(Currency.rub.rawValue, forKey: Constants.UserDefaults.toCurrency)
        }
        if UserDefaults.standard.object(forKey: Constants.UserDefaults.fromValue) == nil {
            UserDefaults.standard.setValue(1.0, forKey: Constants.UserDefaults.fromValue)
        }
    }
}
