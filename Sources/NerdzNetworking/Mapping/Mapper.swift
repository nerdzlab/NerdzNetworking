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
    let converter: ResponseJsonConverter?
    
    init(decoder: JSONDecoder, converter: ResponseJsonConverter? = nil) {
        self.decoder = decoder
        self.converter = converter
    }
    
    func map(from data: Data?) throws -> T {
        var finalData = data
        
        if let converter = converter, let data = data {
            finalData = try converter.convertedData(from: data)
        }
        
        if let data = finalData, !data.isEmpty {
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
