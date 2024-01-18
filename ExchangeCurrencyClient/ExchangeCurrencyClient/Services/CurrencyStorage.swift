//
//  CurrencyStorage.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

/// Rates storing service
final class CurrencyStorage: CurrencyStorageProtocol {
    
    @UserDefault(Constants.UserDefaults.rates)
    private var exchangeRates: [Currency: CurrencyRates]?
    
    /// API Service to fetch new ones or outdated
    private let apiService: APIServiceProtocol = CurrencyAPIService()
    
    func getExchangeRate(from: Currency, to: Currency) async throws -> Double? {
        if exchangeRates == nil {
            exchangeRates = [:]
        }
        if let rates = exchangeRates?[from], rates.rateDate.isToday {
            if let neededRate = rates.rateForCurrency(to) {
                return neededRate
            }
        }
        print("No rates for today. Loading")
        let rates = try await apiService.getCurrencyRates(from: from, to: Currency.allCases)
        exchangeRates?[from] = rates
        
        print("Rates for today is updated")
        if let neededRate = rates.rateForCurrency(to) {
            return neededRate
        }
        return nil
    }
}
