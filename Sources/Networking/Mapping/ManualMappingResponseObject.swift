//
//  ManualMappingOption.swift
//  Networking
//
//  Created by new user on 06.04.2020.
//

import Foundation

public protocol ManualMappingResponseObject: ResponseObject {
    init?(json: Any)
    init?(data: Data)
}

public extension ManualMappingResponseObject {
    static var mapper: BaseObjectMapper<Self> {
        return ManualObjectMapper<Self>()
    }
    
    init?(json: Any) {
        return nil
    }
    
    init?(data: Data) {
        return nil
    }
}

private class ManualObjectMapper<T>: BaseObjectMapper<T> where T: ManualMappingResponseObject {
    
    override func mapJson(_ json: Any) -> T? {
        return T(json: json)
    }
    
    override func mapData(_ data: Data) -> T? {
        return T(data: data)
    }
}
