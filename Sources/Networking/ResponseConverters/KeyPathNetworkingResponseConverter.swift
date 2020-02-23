//
//  KeyPathNetworkingResponseConverter.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class KeyPathNetworkingResponseConverter: NetworkingResponseJsonConverter {
    enum InternalError: Error {
        case invalidPath(_ path: String)
        
        var localizedDescription: String {
            switch self {
            case .invalidPath(let path): return "Invalid json convertation path: `\(path)`"
            }
        }
    }
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func convertedJson(from json: Any) throws -> Any {
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
