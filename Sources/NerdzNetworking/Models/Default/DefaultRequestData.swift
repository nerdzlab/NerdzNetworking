//
//  File.swift
//  
//
//  Created by new user on 14.09.2021.
//

import Foundation

public class DefaultRequestData: RequestData {
    public var path: String
    public var method: HTTPMethod
    public var queryParams: [(String, String)]
    public var body: RequestBody? 
    public var headers: [RequestHeaderKey: String]
    public var timeout: TimeInterval?
    public var shouldCache: Bool
    
    public init(
        path        : String = "", 
        method      : HTTPMethod = .get, 
        queryParams : [(String, String)] = [], 
        body        : RequestBody? = nil, 
        headers     : [RequestHeaderKey: String] = [:],
        timeout     : TimeInterval? = nil, 
        shouldCache : Bool = true
    ) {
        self.path = path
        self.method = method
        self.queryParams = queryParams
        self.body = body
        self.headers = headers
        self.timeout = timeout
        self.shouldCache = shouldCache
    }
}
