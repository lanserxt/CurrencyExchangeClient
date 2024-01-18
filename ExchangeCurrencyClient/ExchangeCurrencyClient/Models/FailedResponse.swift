//
//  FailedResponse.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import Foundation

struct FailedResponse: Codable {
    let success: Bool?
    let error: ErroInfo?
}

struct ErroInfo: Codable {
    let code: String
    let message: String    
}
