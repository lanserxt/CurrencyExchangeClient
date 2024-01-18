//
//  NumberFormatters.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

struct NumberFormatters {
    
    /// Formatter for input string
    static var inputDigits: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter
    }
    
    /// Formatter for output value
    static var twoFractionDigits: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter
    }
}
