//
//  CurrencyViewModelTests.swift
//  CurrencyViewModelTests
//
//  Created by Anton Gubarenko on 17.01.2024.
//

import XCTest
@testable import ExchangeCurrencyClient

final class CurrencyViewModelTests: XCTestCase {

    private let viewModel = CurrencyViewModel()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSameCurrency() throws {
        XCTAssertFalse(viewModel.sameCurrencies)
        viewModel.fromCurrency = .euro
        viewModel.toCurrency = .euro
        XCTAssertTrue(viewModel.sameCurrencies)
    }

    func testZeroInput() throws {
        viewModel.fromValue = 0
        viewModel.fromCurrency = .euro
        viewModel.toCurrency = .usd
        XCTAssertTrue(viewModel.toValue ?? 0.0 < 0.01)
    }

}
