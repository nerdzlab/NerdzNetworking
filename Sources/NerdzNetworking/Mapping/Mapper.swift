//
//  Mapper.swift
//  Networking
//
//  Created by new user on 10.10.2020.
//

import Foundation

class Mapper<T: Decodable> {
    enum Errors: Error {
        case unableToMap(_ type: String)
        
        var localizedDescription: String {
            switch self {
            case .unableToMap(let type): 
                return "Unable to map \(type)"
            }
        }
    }
    
    let decoder: JSONDecoder
    
    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    func map(from data: Data?) throws -> T {
        if let data = data {
            return try decoder.decode(T.self, from: data)
        }
        else if let result = Empty() as? T {
            return result
        }
        else {
            throw Errors.unableToMap(String(describing: T.self))
        }
    }
}
