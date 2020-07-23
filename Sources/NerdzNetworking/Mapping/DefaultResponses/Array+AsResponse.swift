//
//  Array.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Array: ResponseObject where Element: ResponseObject {
    private enum ArrayMappingError: Error {
        case jsonIsNotAnArray
        
        var localizedDescription: String {
            switch self {
            case .jsonIsNotAnArray: 
                return "The json provided for mapping is not an array"
            }
        }
    }
    
    public static var mapper: BaseObjectMapper<Self> { 
        return CustomObjectMapper<Self>(
            jsonClosure: { json throws -> Self in
                try create(from: json)
        }, 
            dataClosure: { data throws -> Self in
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return try create(from: json)
        })
    }
    
    private static func create(from json: Any) throws -> Self {
        guard let json = json as? [Any] else {
            throw ArrayMappingError.jsonIsNotAnArray
        }
        
        var result: Self = []
        
        for jsonObject in json {
            let element = try Element.mapper.mapJson(jsonObject)
            result.append(element)
        }
        
        return result
    }
}
