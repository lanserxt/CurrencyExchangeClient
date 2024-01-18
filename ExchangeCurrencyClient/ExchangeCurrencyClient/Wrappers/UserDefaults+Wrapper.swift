//
//  UserDefaults+Wrapper.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 18.01.2024.
//

import UIKit

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
