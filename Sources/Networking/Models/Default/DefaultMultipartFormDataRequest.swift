//
//  DefaultMultipartFormDataRequest.swift
//  Networking
//
//  Created by new user on 24.05.2020.
//

import Foundation

public struct DefaultMultipartFormDataRequest<Response: ResponseObject, Error: ServerError>: MultipartFormDataRequest {
    public typealias ResponseObjectType = Response
    public typealias ErrorType = Error
    
    public var path: String
    public var method: HTTPMethod
    public var queryParams: [(String, String)] = []
    public var bodyParams: [String: Any] = [:]
    public var headers: [RequestHeader] = []
    public var timeout: TimeInterval?
    public var endpoint: Endpoint?
    public var files: [MultipartFile] = []
    
    public init(
        path: String, 
        method: HTTPMethod, 
        queryParams: [(String, String)] = [], 
        bodyParams: [String: Any] = [:], 
        headers: [RequestHeader] = [], 
        timeout: TimeInterval? = nil,
        endpoint: Endpoint? = nil,
        files: [MultipartFile] = [])
    {
        self.path = path
        self.method = method
        self.queryParams = queryParams
        self.bodyParams = bodyParams
        self.headers = headers
        self.timeout = timeout
        self.endpoint = endpoint
    }
}
