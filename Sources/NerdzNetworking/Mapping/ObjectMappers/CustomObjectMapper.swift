//
//  CustomObjectMapper.swift
//  Networking
//
//  Created by new user on 05.04.2020.
//

import Foundation

public final class CustomObjectMapper<T: ResponseObject>: BaseObjectMapper<T> {
    private enum CustomObjectMapperError: Error {
        case isNotMappableFromJson
        case isNotMappableFromData
        
        var localizedDescription: String {
            switch self {
            case .isNotMappableFromJson: 
                return "Expected result can not be mapped from JSON"
                
            case .isNotMappableFromData:
                return "Expected result can not be mapped from Data"
            }
        }
    }
    
    private let jsonClosure: ((Any) throws -> T)?
    private let dataClosure: ((Data) throws -> T)?
    
    public init(jsonClosure: ((Any) throws -> T)? = nil, dataClosure: ((Data) throws -> T)? = nil) {
        self.jsonClosure = jsonClosure
        self.dataClosure = dataClosure
    }
    
    override public func mapJson(_ json: Any) throws -> T {
        if let closure = jsonClosure {
            return try closure(json)
        }
        else {
            throw CustomObjectMapperError.isNotMappableFromJson
        }
    }
    
    override public func mapData(_ data: Data) throws -> T {
        if let closure = dataClosure {
            return try closure(data)
        }
        else {
            throw CustomObjectMapperError.isNotMappableFromData
        }
    }
}
