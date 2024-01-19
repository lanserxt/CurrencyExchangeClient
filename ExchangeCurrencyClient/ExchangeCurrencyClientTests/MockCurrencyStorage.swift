//
//  MockCurrencyStorage.swift
//  ExchangeCurrencyClientTests
//
//  Created by Anton Gubarenko on 19.01.2024.
//

import Foundation

final class MockCurrencyStorage: CurrencyStorageProtocol {
    func getExchangeRate(from: Currency, to: Currency) async throws -> Double? {
        return 1.5
    }
}
