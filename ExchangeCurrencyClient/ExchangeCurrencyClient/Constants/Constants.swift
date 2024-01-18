//
//  Constants.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

struct Constants {
    struct UserDefaults {
        static let fromCurrency = "fromCurrency"
        static let toCurrency = "toCurrency"
        
        static let fromValue = "fromValue"
        static let toValue = "toValue"
        
        static let rates = "toValue"
    }
    
    struct API {
        static let exchangeAPIKey = "b5a7fd3be6e454fb595a5f003e29d62a"
        static let infoURL = "https://exchangeratesapi.io"
    }
}
