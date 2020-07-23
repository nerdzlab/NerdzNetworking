//
//  ManualMappingOption.swift
//  Networking
//
//  Created by new user on 06.04.2020.
//

import Foundation

public protocol ManualMappingResponseObject: ResponseObject {
    init(json: Any) throws
    init(data: Data) throws
}

public extension ManualMappingResponseObject {
    static var mapper: BaseObjectMapper<Self> {
        return ManualObjectMapper<Self>()
    }
    
    init(json: Any) throws {
        throw ManualMappingResponseObjectError.isNotMappableFromJson
    }
    
    init(data: Data) throws {
        throw ManualMappingResponseObjectError.isNotMappableFromJson
    }
}

fileprivate enum ManualMappingResponseObjectError: Error {
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

private class ManualObjectMapper<T>: BaseObjectMapper<T> where T: ManualMappingResponseObject {
    override func mapJson(_ json: Any) throws -> T {
        return try T(json: json)
    }
    
    override func mapData(_ data: Data) throws -> T {
        return try T(data: data)
    }
}
