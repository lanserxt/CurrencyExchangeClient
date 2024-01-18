//
//  Date+Today.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

extension Date {
    
    /// Is current date
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

