//
//  CurrencyAPIService.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import UIKit

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
    
    private let timeout = 2.0
    
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
            throw NetworkError.parametersInvalid
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
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
