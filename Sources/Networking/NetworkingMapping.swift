//
//  Mapping.swift
//  Networking
//
//  Created by Vasyl Khmil on 22.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol NetworkingResponseObject {
    static func object(from json: Any) -> Self?
    static func object(from data: Data) -> Self? 
}

public protocol MappableNetworkingResponseObject: Mappable, NetworkingResponseObject { }

public protocol CodableNetworkingResponseObject: Codable, NetworkingResponseObject {
    static var decoder: JSONDecoder { get }
}

public extension NetworkingResponseObject {
    static func object(from json: Any) -> Self? {
        return nil
    }
    
    static func object(from data: Data) -> Self? {
        return nil
    }
    
    static func object(from data: Data?, jsonConverter: NetworkingResponseJsonConverter?) throws -> Self? {
        guard let data = data else {
            return Empty() as? Self
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            let convertedJson = try jsonConverter?.convertedJson(from: json) ?? json
            return object(from: convertedJson) ?? object(from: data)
        }
        else {
            return object(from: data)
        }
    }
}

public extension MappableNetworkingResponseObject {
    static func object(from json: Any) -> Self? {
        guard let singleObjectJson = json as? [String: Any] else {
            return nil
        }
        
        return Self.init(JSON: singleObjectJson)
    }
}

public extension CodableNetworkingResponseObject {
    static var decoder: JSONDecoder { 
        return JSONDecoder()
    }
    
     static func object(from json: Any) -> Self? {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
            return try? decoder.decode(Self.self, from: data)
        }
        else {
            return nil
        }
    }
}
