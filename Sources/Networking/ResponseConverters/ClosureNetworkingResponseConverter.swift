//
//  ClosureNetworkingResponseConverter.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class ClosureNetworkingResponseConverter: NetworkingResponseJsonConverter {
    typealias Closure = (Any) -> Any?
    
    enum InternalError: Error {
        case unableToConvert
        
        var localizedDescription: String {
            switch self {
            case .unableToConvert: return "Unable to convert response json by closure"
            }
        }
    }
    
    private let closure: Closure
    
    init(closure: @escaping Closure) {
        self.closure = closure
    }
    
    func convertedJson(from json: Any) throws -> Any {
        if let result = closure(json) {
            return result
        }
        else {
            throw InternalError.unableToConvert
        }
    }
}
