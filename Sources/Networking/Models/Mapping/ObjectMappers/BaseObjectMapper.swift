//
//  ObjectMapper.swift
//  Networking
//
//  Created by new user on 05.04.2020.
//

import Foundation

public class BaseObjectMapper<T> where T: ResponseObject {
    init() { } 
    
    public func mapJson(_ json: Any) -> T? {
        return nil
    }
    
    public func mapData(_ data: Data) -> T? {
        return nil
    }
    
    func mapResponse(_ response: Data?, with jsonConverter: ResponseJsonConverter? = nil) throws -> T? {
        /// In case no data was returned - we can succed only if Self is Empty
        guard let data = response else {
            return Empty() as? T
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            let convertedJson = try jsonConverter?.convertedJson(from: json) ?? json
            return mapJson(convertedJson)
        }
        else {
            return mapData(data)
        }
    }
}
