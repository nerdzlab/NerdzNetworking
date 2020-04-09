//
//  CustomObjectMapper.swift
//  Networking
//
//  Created by new user on 05.04.2020.
//

import Foundation

public final class CustomObjectMapper<T: ResponseObject>: BaseObjectMapper<T> {
    private let jsonClosure: ((Any) -> T?)?
    private let dataClosure: ((Data) -> T?)?
    
    public init(jsonClosure: ((Any) -> T?)? = nil, dataClosure: ((Data) -> T?)? = nil) {
        self.jsonClosure = jsonClosure
        self.dataClosure = dataClosure
    }
    
    override public func mapJson(_ json: Any) -> T? {
        return jsonClosure?(json)
    }
    
    override public func mapData(_ data: Data) -> T? {
        return dataClosure?(data)
    }
}
