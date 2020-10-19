//
//  Dictionary.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

//extension Dictionary: ResponseObject where Key == String, Value: ResponseObject {
//    private enum DictionaryMappingError: Error {
//        case jsonIsNotAnArray
//        
//        var localizedDescription: String {
//            switch self {
//            case .jsonIsNotAnArray: 
//                return "The json provided for mapping is not an array"
//            }
//        }
//    }
//    
//    public static var mapper: BaseObjectMapper<Self> {
//        return CustomObjectMapper(
//            jsonClosure: { json throws -> Self in
//                try create(from: json)
//        }, 
//            dataClosure: { data throws -> Self in
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
//                return try create(from: json)
//        })
//        
//    }
//    
//    private static func create(from json: Any) throws -> Self {
//        guard let dictionary = json as? [String: Any] else {
//            throw DictionaryMappingError.jsonIsNotAnArray
//        }
//        
//        var result: Self = [:]
//        
//        for (key, value) in dictionary {
//            let mappedObject = try Value.mapper.mapJson(value)
//            result[key] = mappedObject
//        }
//        
//        return result
//    }
//}
