//
//  File.swift
//  
//
//  Created by new user on 14.09.2021.
//

import Foundation

public class DefaultRequestData: RequestData {
    public var path: String = ""
    public var method: HTTPMethod = .get
    public var queryParams: [(String, String)] = []
    public var body: RequestBody? 
    public var headers: [RequestHeaderKey: String] = [:]
    public var timeout: TimeInterval?  = nil
    public var shouldCache: Bool = false
    
    init(
        path        : String = "", 
        method      : HTTPMethod = .get, 
        queryParams : [(String, String)] = [], 
        body        : RequestBody? = nil, 
        timeout     : TimeInterval? = nil, 
        shouldCache : Bool = true
    ) {
        self.path = path
        self.method = method
        self.queryParams = queryParams
        self.body = body
        self.timeout = timeout
        self.shouldCache = shouldCache
    }
    
    convenience init(_ data: RequestData) {
        self.init(
            path: data.path, 
            method: data.method, 
            queryParams: data.queryParams, 
            body: data.body, 
            timeout: data.timeout, 
            shouldCache: data.shouldCache
        )
    }
}
