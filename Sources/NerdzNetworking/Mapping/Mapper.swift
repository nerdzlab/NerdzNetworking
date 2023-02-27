//
//  Mapper.swift
//  Networking
//
//  Created by new user on 10.10.2020.
//

import Foundation

class Mapper<T: Decodable> {
    
    let decoder: JSONDecoder
    let converter: ResponseJsonConverter?
    
    init(decoder: JSONDecoder, converter: ResponseJsonConverter? = nil) {
        self.decoder = decoder
        self.converter = converter
    }
    
    func map(from data: Data?) throws -> T {
        var returnResult: T?
        
        do {
            if let data = data, !data.isEmpty {
                var finalData = data
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    let finalJson = try converter?.convertedJson(from: json) ?? json
                
                    if let result = finalJson as? T {
                        returnResult = result
                    }
                    else {
                        finalData = try JSONSerialization.data(withJSONObject: finalJson, options: [])
                    }
                }
                
                if returnResult == nil {
                    if let result = (T.self as? DataMappable.Type)?.object(from: data) as? T {
                        returnResult = result
                    }
                    else {
                        returnResult = try decoder.decode(T.self, from: finalData)
                    }
                }
            }
            else if let result = (T.self as? NoDataMappable.Type)?.noDataObject() as? T {
                returnResult = result
            }
        }
        catch {
            throw DescriptiveDecodingError(error)
        }
        
        if let result = returnResult {
            return result
        }
        else {
            throw DescriptiveDecodingError.unableToMap(String(describing: T.self))
        }
    }
}
