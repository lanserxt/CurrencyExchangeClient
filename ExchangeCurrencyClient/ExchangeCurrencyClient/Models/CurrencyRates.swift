//
//  CurrencyRates.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

struct CurrencyRates: Codable {
    let success: Bool
    let timestamp: Double
    let base, date: String
    let rates: [String: Double]
    
    /// Converted date
    var rateDate: Date {
        Date(timeIntervalSince1970: timestamp)
    }
    
    /// Try to get rate multiplier for currency
    /// - Parameter to: target currency
    /// - Returns: rate if exists
    func rateForCurrency(_ to: Currency) -> Double? {
        rates[to.rawValue.uppercased()]
    }
}
