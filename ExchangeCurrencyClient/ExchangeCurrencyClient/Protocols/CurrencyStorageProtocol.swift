//
//  CurrencyStorageProtocol.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

/// Interface for rates fetching
protocol CurrencyStorageProtocol {
    
    /// Get rates for currencies
    /// - Parameters:
    ///   - from: source currency
    ///   - to: target currency
    /// - Returns: rate multiplier if exists
    func getExchangeRate(from: Currency, to: Currency) async throws -> Double?
}
