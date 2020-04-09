//
//  ResponseObject.swift
//  Networking
//
//  Created by new user on 05.04.2020.
//

import Foundation

public protocol ResponseObject {
    static var mapper: BaseObjectMapper<Self> { get }
}

public extension ResponseObject {
    static var mapper: BaseObjectMapper<Self> {
        return BaseObjectMapper<Self>()
    }
}
