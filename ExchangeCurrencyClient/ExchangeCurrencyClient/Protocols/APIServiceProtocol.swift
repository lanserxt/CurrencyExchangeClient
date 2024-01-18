//
//  APIServiceProtocol.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

/// Interface for fetching rates from external API
protocol APIServiceProtocol {
    
    /// Get rates for currencies
    /// - Parameters:
    ///   - from: source currency
    ///   - to: target currencies list
    /// - Returns: rate multipliers
    func getCurrencyRates(from: Currency, to: [Currency]) async throws -> CurrencyRates
}
