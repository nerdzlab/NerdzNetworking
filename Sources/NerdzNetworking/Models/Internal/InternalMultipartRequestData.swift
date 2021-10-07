//
//  File.swift
//  
//
//  Created by new user on 07.10.2021.
//

import Foundation

// We are using this wrapping internal class inside the library to be able to modify some properties later on.
// For example, to modify timeout after user cnaging it via execution operation
class InternalMultipartRequestData: DefaultMultipartRequestData {
    
    let wrappedData: MultipartRequestData?
    
    init(_ data: MultipartRequestData) {
        self.wrappedData = data
        
        super.init(
            files       : data.files, 
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
