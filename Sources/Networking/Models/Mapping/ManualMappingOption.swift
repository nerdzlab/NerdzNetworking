//
//  ManualMappingOption.swift
//  Networking
//
//  Created by new user on 06.04.2020.
//

import Foundation

public protocol ManualMappingObject: ResponseObject {
    init?(json: Any)
    init?(data: Data)
}

public extension ManualMappingObject {
    static var mapper: BaseObjectMapper<Self> {
        return CustomObjectMapper<Self>(
            jsonClosure: { json -> Self? in
                return Self.init(json: json)
        }, 
            dataClosure: { data -> Self? in
                return Self.init(data: data)
        })
    }
    
    init?(json: Any) {
        return nil
    }
    
    init?(data: Data) {
        return nil
    }
}
