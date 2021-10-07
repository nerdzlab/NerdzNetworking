//
//  File.swift
//  
//
//  Created by new user on 07.10.2021.
//

import Foundation

// We are using this wrapping internal class inside the library to be able to modify some properties later on.
// For example, to modify timeout after user cnaging it via execution operation
class InternalRequestData: DefaultRequestData {
    
    let wrappedData: RequestData?
    
    init(_ data: RequestData) {
        self.wrappedData = data
        
        super.init(
            path        : data.path, 
            method      : data.method, 
            queryParams : data.queryParams, 
            body        : data.body, 
            headers     : data.headers, 
            timeout     : data.timeout, 
            shouldCache : data.shouldCache
        )
    }
}
