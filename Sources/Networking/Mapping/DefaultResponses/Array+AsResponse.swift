//
//  Array.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Array: ResponseObject where Element: ResponseObject {
    public static var mapper: BaseObjectMapper<Self> { 
        return CustomObjectMapper<Self>(
            jsonClosure: { json -> Self? in
                create(from: json)
        }, 
            dataClosure: { data -> Self? in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    return nil
                }
                
                return create(from: json)
        })
    }
    
    private static func create(from json: Any) -> Self? {
        guard let json = json as? [Any] else {
            return nil
        }
        
        var result: Self = []
        
        for jsonObject in json {
            if let element = Element.mapper.mapJson(jsonObject) {
                result.append(element)
            }
        }
        
        return result
    }
}
