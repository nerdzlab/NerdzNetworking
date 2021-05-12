//
//  File.swift
//  
//
//  Created by new user on 12.05.2021.
//

import Foundation

public enum RequestBody {
    case raw(_ value: Data)
    case string(_ value: String)
    case params(_ value: [String: Any])
    
    public func generateBodyData() throws -> Data {
        switch self {
        case .raw(let value):
            return value
            
        case .string(let value):
            return Data(value.utf8)
            
        case .params(let value):
            return try JSONSerialization.data(withJSONObject: value, options: [])
        }
    }
}
