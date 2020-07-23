//
//  String.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension String: ResponseObject {
    private enum StringMappingError: Error {
        case canNotMapFromData
    }
    
    public static var mapper: BaseObjectMapper<Self> {
        return CustomObjectMapper(
            jsonClosure: { json throws -> Self in
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                return try create(from: data)
        }, 
            dataClosure: { data throws -> Self in
                try create(from: data)
        })
    }
    
    private static func create(from data: Data) throws -> Self {
        if let result = String(data: data, encoding: .utf8) {
            return result
        }
        else {
            throw StringMappingError.canNotMapFromData
        }
    }
}
