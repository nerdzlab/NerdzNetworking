//
//  ClosureNetworkingResponseConverter.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public class ClosureResponseConverter: ResponseJsonConverter {
    public typealias Closure = (Any) -> Any?
    
    private enum ClosureResponseConverterError: LocalizedError {
        case unableToConvert
        
        var errorDescription: String? {
            switch self {
            case .unableToConvert: 
                return "Unable to convert response json by closure"
            }
        }
    }
    
    private let closure: Closure
    
    public init(closure: @escaping Closure) {
        self.closure = closure
    }
    
    public func convertedJson(from json: Any) throws -> Any {
        if let result = closure(json) {
            return result
        }
        else {
            throw ClosureResponseConverterError.unableToConvert
        }
    }
}
