//
//  File.swift
//  
//
//  Created by new user on 19.04.2021.
//

import Foundation

extension URLRequest {
    
    var cURL: String {
        let method = "--request \(self.httpMethod ?? "GET") \\\n"
        let url: String = "--url \'\(self.url?.absoluteString ?? "")\' \\\n"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += "--header \'\(key): \(value)\' \\\n"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
