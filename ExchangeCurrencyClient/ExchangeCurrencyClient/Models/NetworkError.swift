//
//  NetworkError.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidUrl, parametersInvalid, invalidResponse, commonError(FailedResponse), noInternet
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl:
            String(localized: "Invalid URL")
        case .parametersInvalid:
            String(localized: "Invalid parameters")
        case .invalidResponse:
            String(localized: "Invalid response")
        case .noInternet:
            String(localized: "No connection")
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
        case .parametersInvalid:
            String(localized: "Invalid parameters")
        case .invalidResponse:
            String(localized: "Invalid response")
        case .noInternet:
            String(localized: "No connection")
        case .commonError(let failedResponse):
            failedResponse.error?.message ?? String(localized: "Unknown error")
        }
    }
}
