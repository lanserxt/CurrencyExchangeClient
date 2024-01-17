//
//  ContentView.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 17.01.2024.
//

import SwiftUI

//rubles (RUB), US dollars (USD), euro (EUR), British pound (GBP), Swiss franc (CHF), Chinese yuan (CNY)
enum Currency: String, CaseIterable, Identifiable, Codable {
    case rub = "RUB", usd = "USD", euro = "EUR", pound = "GBP", franc = "CHF", yuan = "CNY"
    var id: Self { self }
}


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
    }
}

struct NumberFormatters {
    static var twoFractionDigits: Formatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

protocol APIServiceProtocol {
    func getCurrencyRates(from: Currency, to: [Currency]) async throws -> CurrencyRates
}

struct CurrencyRates: Codable {
    let success: Bool
    let timestamp: Double
    let base, date: String
    let rates: [String: Double]
    
    var rateDate: Date {
        Date(timeIntervalSince1970: timestamp)
    }
    
    func rateForCurrency(_ to: Currency) -> Double? {
        rates[to.rawValue.uppercased()]
    }
}

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}


struct FailedResponse: Codable {
    let success: Bool?
    let error: ErroInfo?
}

struct ErroInfo: Codable {
    let code: String
    let message: String
    
}

enum NetworkError: Error {
    case invalidUrl, parametesInvalid, invalidResponse, commonError(FailedResponse)
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl:
            String(localized: "Invalid URL")
        case .parametesInvalid:
            String(localized: "Invalid parameters")
        case .invalidResponse:
            String(localized: "Invalid response")
        case .commonError(let failedResponse):
            failedResponse.error?.message ?? String(localized: "Unknown error")
        }
    }
    
}

extension NetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidUrl:
            String(localized: "Invalid URL")
        case .parametesInvalid:
            String(localized: "Invalid parameters")
        case .invalidResponse:
            String(localized: "Invalid response")
        case .commonError(let failedResponse):
            failedResponse.error?.message ?? String(localized: "Unknown error")
        }
    }
}

final class CurrencyAPIService: APIServiceProtocol {
    
    enum Endpoint {
        case latetRateEndpoint
        
        var url: String {
            switch self {
            case .latetRateEndpoint:
                "http://api.exchangeratesapi.io/v1/latest"
            }
        }
    }
    
    enum Method: String {
        case get, post, put, patch, delete
    }
    
    
    func getCurrencyRates(from: Currency, to: [Currency]) async throws -> CurrencyRates {
        try await sendRequest(method: .get,
                              endpoint: .latetRateEndpoint,
                              endpointValues: [URLQueryItem(name: "base",
                                                            value: from.rawValue.uppercased()),
                                               URLQueryItem(name: "symbols",
                                                            value: to.compactMap({
            if $0 != from {
                return $0.rawValue.uppercased()
            } else {
                return nil
            }
        }).joined(separator: ",") )])
    }
    
    // Send request
    private func sendRequest<T: Codable>(method: Method, endpoint: Endpoint, endpointValues: [URLQueryItem]) async throws -> T {
        
        guard var urlComp = URLComponents(string: endpoint.url) else {
            throw NetworkError.invalidUrl
        }
        var queryItems = [URLQueryItem(name: "access_key", value: Constants.API.exchangeAPIKey)]
        queryItems.append(contentsOf: endpointValues)
        urlComp.queryItems = queryItems
        
        guard let url = urlComp.url else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        print(url.absoluteString)
        request.httpMethod = method.rawValue.uppercased()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        
        if [200].contains(httpResponse.statusCode) {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } else {
            let decodedResponse = try decoder.decode(FailedResponse.self, from: data)
            throw NetworkError.commonError(decodedResponse)
            
        }
    }
}

@propertyWrapper
public struct UserDefault<T: Codable> {
    public let key: String
    
    public var cachedObject: T?
    public init(_ key: String) {
        self.key = key
    }
    
    public var wrappedValue: T? {
        mutating get {
            if let cachedObject = cachedObject {
                return cachedObject
            }
            guard let arrayData = UserDefaults.standard.object(forKey: key) as? Data else {return nil}
            guard let value = try? JSONDecoder().decode(T.self, from: arrayData) else {return nil}
            self.cachedObject = value
            return value
        }
        set {
            cachedObject = newValue
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

protocol CurrencyStorageProtocol {
    func getExchangeRate(from: Currency, to: Currency) async throws -> Double?
}

final class CurrencyStorage: CurrencyStorageProtocol {
    
    @UserDefault(Constants.UserDefaults.rates)
    private var exchangeRates: [Currency: CurrencyRates]?
    
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



final class CurrencyViewModel: ObservableObject {
    
    private let currencyStorage = CurrencyStorage()
    
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
            UserDefaults.standard.setValue(fromValue, forKey: Constants.UserDefaults.fromValue)
            self.exchange()
        }
    }
    
    @Published
    var toValue: Double?
    
    @Published
    var networkError: NetworkError?
    private var loadingTask: Task<(), Never>?
    
    //MARK: - Error handling
    @Published
    var exchangeError: String?
    
    @Published
    var showingAlert: Bool = false
    
    func exchange() {
        print("TRY exc \(fromValue) \(fromCurrency)-\(toCurrency)")
        guard fromCurrency != toCurrency else {
            toValue = fromValue
            sameCurrencies = true
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
                if let rate = try await currencyStorage.getExchangeRate(from: fromCurrency, to: toCurrency) {
                    toValue = fromValue * rate
                    exchangeError = nil
                    showingAlert = false
                } else {
                    toValue = nil
                    exchangeError = "Conversion failed"
                    showingAlert = true
                }
                await MainActor.run {
                    isLoading = false
                }
            }
            catch {
                exchangeError = "\(error)"
                showingAlert = true
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    @Published
    private(set) var sameCurrencies: Bool = false
    
    @Published
    private(set) var isLoading: Bool = false
    
    init() {
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
    }
    
}

struct ContentView: View {
    
    @StateObject
    private var viewModel = CurrencyViewModel()
    
    @FocusState
    private var fromNumberInFocus: Bool
    
    @FocusState
    private var toNumberInFocus: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("From") {
                        HStack {
                            TextField("", value: $viewModel.fromValue, formatter: NumberFormatters.twoFractionDigits)
                                .keyboardType(.decimalPad)
                                .focused($fromNumberInFocus)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        if fromNumberInFocus {
                                            Button("Done") {
                                                fromNumberInFocus = false
                                            }
                                        }
                                    }
                                }
                            Picker("", selection: $viewModel.fromCurrency) {
                                ForEach(Currency.allCases, id: \.self) {
                                    Text($0.rawValue)
                                        .tag(Optional($0))
                                }
                            }
                        }
                    }
                    Section {
                        HStack {
                            TextField("", value: $viewModel.toValue, formatter: NumberFormatters.twoFractionDigits)
                                .disabled(true)
                            Picker("", selection: $viewModel.toCurrency) {
                                ForEach(Currency.allCases, id: \.self) {
                                    Text($0.rawValue)
                                        .tag(Optional($0))
                                }
                            }
                        }
                    } header: {
                        Text("To")
                    } footer: {
                        VStack {
                            if viewModel.sameCurrencies {
                                Text("Same destination currency")
                                    .foregroundStyle(Color.red)
                                    .bold()
                            }
                        }
                    }
                    
                }
                .disabled(viewModel.isLoading)
                .overlay {
                    if viewModel.isLoading {
                        VStack(spacing: 16.0) {
                            ProgressView()
                            Text("Loading rates...")
                        }
                    }
                }
                
                HStack {
                    Text("Rates by")
                    Link("exchangerates", destination: URL(string: "https://exchangeratesapi.io")!)
                }
            }.navigationBarTitle("Exchange Currency")
        }
        .onAppear {
            viewModel.exchange()
        }
        .alert(viewModel.exchangeError ?? String(localized: "Error"),
               isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    ContentView()
}
