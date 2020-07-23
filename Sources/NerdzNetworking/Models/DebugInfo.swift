//
//  NetworkingDebugInfo.swift
//  Networking
//
//  Created by new user on 25.02.2020.
//

import Foundation

public struct DebugInfo {
    let sessionConfiguration: URLSessionConfiguration
    let request: URLRequest
    let dataResponse: Data?
    let urlResponse: HTTPURLResponse?
    let errorResponse: Error?
    let requestDuration: TimeInterval
    
    var stringResponse: String? {
        dataResponse.flatMap({ String(data: $0, encoding: .utf8) })
    }
    
    var jsonResponse: Any? {
        dataResponse.flatMap({ try? JSONSerialization.jsonObject(with: $0, options: []) })
    }
}
