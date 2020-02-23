//
//  NetworkingDefaultRequestType.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

struct NetworkingDefaultRequestType<Response: NetworkingResponseObject, Error: NetworkingServerError>: NetworkingRequestType {
    typealias ResponseObjectType = Response
    typealias ErrorType = Error
    
    var path: String
    var method: NetworkingHTTPMethod
    var queryParams: [(String, String)] = []
    var bodyParams: [String: Any] = [:]
    var headers: [NetworkingHeader] = []
    var timeout: TimeInterval?
    
    init(
        path: String, 
        method: NetworkingHTTPMethod, 
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
