//
//  Dictionary.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Dictionary: ResponseObject {
    public static var mapper: BaseObjectMapper<Self> {
        return CustomObjectMapper(
            jsonClosure: { json -> Self? in
                return json as? Dictionary<Key, Value>
        }, 
            dataClosure: { data -> Self? in
                return (try? JSONSerialization.jsonObject(with: data, options: [])) as? Self
        })
    }
}

extension Dictionary where Key == String, Value: ResponseObject {
    public static var mapper: BaseObjectMapper<Self> {
        return CustomObjectMapper(
            jsonClosure: { json -> Self? in
                return create(from: json)
        }, 
            dataClosure: { data -> Self? in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    return create(from: json)
                }
                else {
                    return nil
                }
        })
        
    }
    
    private static func create(from json: Any) -> Self? {
        guard let dictionary = json as? [String: Any] else {
            return nil
        }
        
        var result: Self = [:]
        
        for (key, value) in dictionary {
            if let mappedObject = Value.mapper.mapJson(value) {
                result[key] = mappedObject
            }
        }
        
        return result
    }
}
