//
//  DecodableResponseMapper.swift
//  Networking
//
//  Created by new user on 05.04.2020.
//

import Foundation

public final class DecodableObjectMapper<T>: BaseObjectMapper<T> where T: Decodable, T: ResponseObject {
    private let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        super.init()
    }
    
    override public func mapJson(_ json: Any) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try mapData(data)
    }
    
    override public func mapData(_ data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
}
