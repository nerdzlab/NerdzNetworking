//
//  ObjectMapper.swift
//  Networking
//
//  Created by new user on 05.04.2020.
//

import Foundation

public class BaseObjectMapper<T> where T: ResponseObject {
    private enum BaseObjectMapperError: Error {
        case baseClassUsed
        case responseDataEmpty
        
        var localizedDescription: String {
            switch self {
            case .baseClassUsed:
                return "You should use only inherited classes from BaseObjectMapper class"
                
            case .responseDataEmpty:
                return "Response was empty but expected to contain data"
            }
        }
    }
    
    init() { } 
    
    public func mapJson(_ json: Any) throws -> T {
        throw BaseObjectMapperError.baseClassUsed
    }
    
    public func mapData(_ data: Data) throws -> T {
        throw BaseObjectMapperError.baseClassUsed
    }
    
    func mapResponse(_ response: Data?, with jsonConverter: ResponseJsonConverter? = nil) throws -> T {
        /// In case no data was returned - we can succed only if Self is Empty
        guard let data = response else {
            if let result = Empty() as? T {
                return result
            }
            else {
                throw BaseObjectMapperError.responseDataEmpty
            }
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            let convertedJson = try jsonConverter?.convertedJson(from: json) ?? json
            
            do {
                return try mapJson(convertedJson)
            }
            catch {
                if let dataResponse = try? mapData(data) {
                    return dataResponse
                }
                else {
                    throw error
                }
            }
        }
        else {
            return try mapData(data)
        }
    }
}
