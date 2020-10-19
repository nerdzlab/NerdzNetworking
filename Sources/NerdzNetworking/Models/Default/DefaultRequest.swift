//
//  NetworkingDefaultRequestType.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct DefaultRequest<Response: Decodable, Error: ServerError>: Request {
    public typealias ResponseObjectType = Response
    public typealias ErrorType = Error
    
    public var path: String
    public var method: HTTPMethod
    public var queryParams: [(String, String)] = []
    public var bodyParams: [String: Any] = [:]
    public var headers: [RequestHeaderKey: String] = [:]
    public var timeout: TimeInterval?
    public var endpoint: Endpoint?
    public var responseConverter: ResponseJsonConverter?
    public var errorConverter: ResponseJsonConverter?
    
    public init(
        path: String, 
        method: HTTPMethod, 
        queryParams: [(String, String)] = [], 
        bodyParams: [String: Any] = [:], 
        headers: [RequestHeaderKey: String] = [:], 
        timeout: TimeInterval? = nil,
        responseConverter: ResponseJsonConverter? = nil,
        errorConverter: ResponseJsonConverter? = nil,
        endpoint: Endpoint? = nil)
    {
        self.path = path
        self.method = method
        self.queryParams = queryParams
        self.bodyParams = bodyParams
        self.headers = headers
        self.timeout = timeout
        self.responseConverter = responseConverter
        self.errorConverter = errorConverter
        self.endpoint = endpoint
    }
}
