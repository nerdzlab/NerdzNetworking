//
//  Decodable+Mapping.swift
//  Networking
//
//  Created by new user on 05.04.2020.
//

import Foundation

public extension Decodable where Self: ResponseObject {
    static var mapper: BaseObjectMapper<Self> {
        return DecodableObjectMapper<Self>()
    }
}

public protocol DecodableResponseObject: Codable, ResponseObject {
    static var decoder: JSONDecoder { get }
}

public extension DecodableResponseObject {
    static var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    static var mapper: BaseObjectMapper<Self> {
        return DecodableObjectMapper<Self>(decoder: decoder)
    }
}
