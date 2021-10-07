//
//  File.swift
//  
//
//  Created by new user on 07.10.2021.
//

import Foundation

public class DefaultMultipartRequestData: DefaultRequestData, MultipartRequestData {
    
    public var files: [MultipartFile]
    
    public init(
        files       : [MultipartFile] = [],
        path        : String = "", 
        method      : HTTPMethod = .get, 
        queryParams : [(String, String)] = [], 
        body        : RequestBody? = nil, 
        headers     : [RequestHeaderKey: String] = [:],
        timeout     : TimeInterval? = nil, 
        shouldCache : Bool = true
    ) {
        self.files = files
        
        super.init(
            path: path, 
            method: method, 
            queryParams: queryParams, 
            body: body, 
            headers: headers, 
            timeout: timeout, 
            shouldCache: shouldCache
        )
    }
}
