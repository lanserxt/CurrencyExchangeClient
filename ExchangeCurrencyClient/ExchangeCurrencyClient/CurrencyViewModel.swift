//
//  CurrencyViewModel.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import UIKit
import SwiftUI

/// Main View model
final class CurrencyViewModel: ObservableObject {
    
    let currencyStorage: CurrencyStorageProtocol
        
    init(currencyStorage: CurrencyStorageProtocol = CurrencyStorage()) {
        //Setting default values
        if let fromDefsKey = UserDefaults.standard.string(forKey: Constants.UserDefaults.fromCurrency),
           let currency = Currency(rawValue: fromDefsKey) {
            fromCurrency = currency
        } else {
            fromCurrency = .euro
        }
        
        if let fromDefsKey = UserDefaults.standard.string(forKey: Constants.UserDefaults.toCurrency),
           let currency = Currency(rawValue: fromDefsKey) {
            toCurrency = currency
        } else {
            toCurrency = .rub
        }
        
        let fromDefsKey = UserDefaults.standard.float(forKey: Constants.UserDefaults.fromValue)
        fromValue = Double(fromDefsKey)
        self.currencyStorage = currencyStorage
    }
        
    
    //No AppStorage
    @Published
    var fromCurrency: Currency {
        didSet {
            UserDefaults.standard.setValue(fromCurrency.rawValue, forKey: Constants.UserDefaults.fromCurrency)
            self.exchange()
        }
    }
    
    @Published
    var toCurrency: Currency {
        didSet {
            UserDefaults.standard.setValue(toCurrency.rawValue, forKey: Constants.UserDefaults.toCurrency)
            self.exchange()
        }
    }
    
    @Published
    var fromValue: Double {
        didSet {
            print("Set \(fromValue)")
            UserDefaults.standard.setValue(fromValue, forKey: Constants.UserDefaults.fromValue)
            self.exchange()
        }
    }
    
    @Published
    var toValue: Double?
    
    //MARK: - Networking
    @Published
    var networkError: NetworkError?
    private var loadingTask: Task<(), Never>?
    
    //MARK: - Error handling
    @Published
    var exchangeError: String?
    
    @Published
    var showingAlert: Bool = false
    
    //MARK: - Main Methods
    
    /// Try to exchange current values
    func exchange() {
        //Same currencies are just same )
        guard fromCurrency != toCurrency else {
            toValue = fromValue
            sameCurrencies = true
            return
        }
        
        //No extra calls for 0
        guard fromValue > 0.0 else {
            toValue = 0
            return
        }
        sameCurrencies = false
        
        //Convert currencies
        isLoading = true
        loadingTask?.cancel()
        loadingTask = Task(priority: .background) {
            if Task.isCancelled {
                return
            }
            do {
                //Calling service to get rate
                if let rate = try await currencyStorage.getExchangeRate(from: fromCurrency, to: toCurrency) {
                    await MainActor.run {
                        toValue = fromValue * rate
                        exchangeError = nil
                        showingAlert = false
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        toValue = nil
                        exchangeError = String(localized: "Conversion failed")
                        showingAlert = true
                        isLoading = false
                    }
                }
            }
            catch {
                await MainActor.run {
                    exchangeError = "\(error.localizedDescription)"
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
    
    @Published
    private(set) var sameCurrencies: Bool = false
    
    @Published
    private(set) var isLoading: Bool = false
    
    
    
}
