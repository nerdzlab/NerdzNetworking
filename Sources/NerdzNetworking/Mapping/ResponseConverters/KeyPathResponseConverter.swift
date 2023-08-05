//
//  KeyPathNetworkingResponseConverter.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public class KeyPathResponseConverter: ResponseJsonConverter {
    enum InternalError: LocalizedError {
        case invalidPath(_ path: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidPath(let path): 
                return "Invalid json convertation path: `\(path)`"
            }
        }
    }
    
    private let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    public func convertedJson(from json: Any) throws -> Any {
        let components = path.split(separator: "/").map({ String($0) })
        
        var result = json
        
        for component in components {
            if let dictionaryJson = result as? [String: Any], let newResult = dictionaryJson[component] {
                result = newResult
            }
            else {
                throw InternalError.invalidPath(path)
            }
        }
        
        return result
    }
}
