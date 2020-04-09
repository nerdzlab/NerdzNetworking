//
//  NetworkingDefaultRequestType.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct DefaultRequest<Response: ResponseObject, Error: ServerError>: Request {
    public typealias ResponseObjectType = Response
    public typealias ErrorType = Error
    
    public var path: String
    public var method: HTTPMethod
    public var queryParams: [(String, String)] = []
    public var bodyParams: [String: Any] = [:]
    public var headers: [NetworkingHeader] = []
    public var timeout: TimeInterval?
    
    public init(
        path: String, 
        method: HTTPMethod, 
        queryParams: [(String, String)] = [], 
        bodyParams: [String: Any] = [:], 
        headers: [NetworkingHeader] = [], 
        timeout: TimeInterval? = nil)
    {
        self.path = path
        self.method = method
        self.queryParams = queryParams
        self.bodyParams = bodyParams
        self.headers = headers
        self.timeout = timeout
    }
}
