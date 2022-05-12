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
        if let data = data, !data.isEmpty {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                let finalJson = try converter?.convertedJson(from: json) ?? json
            
                if let result = finalJson as? T {
                    return result
                }
                else {
                    let finalData = try JSONSerialization.data(withJSONObject: finalJson, options: [])
                    return try decoder.decode(T.self, from: finalData)
                }
            }
            else if let result = (T.self as? DataMappable.Type)?.object(from: data) as? T {
                return result
            }
        }
        else if let result = (T.self as? NoDataMappable.Type)?.noDataObject() as? T {
            return result
        }
        
        throw Errors.unableToMap(String(describing: T.self))
    }
}
