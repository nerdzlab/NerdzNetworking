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
    
    override public func mapJson(_ json: Any) -> T? {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
            return mapData(data)
        }
        else {
            return nil
        }
    }
    
    override public func mapData(_ data: Data) -> T? {
        return try? decoder.decode(T.self, from: data)
    }
}
