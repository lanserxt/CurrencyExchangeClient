//
//  Currency.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

//rubles (RUB), US dollars (USD), euro (EUR), British pound (GBP), Swiss franc (CHF), Chinese yuan (CNY)
enum Currency: String, CaseIterable, Identifiable, Codable {
    case rub = "RUB", usd = "USD", euro = "EUR", pound = "GBP", franc = "CHF", yuan = "CNY"
    var id: Self { self }
}
