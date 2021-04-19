//
//  NetworkingDebugInfo.swift
//  Networking
//
//  Created by new user on 25.02.2020.
//

import Foundation

public struct DebugInfo {
    public let sessionConfiguration: URLSessionConfiguration
    public let request: URLRequest
    public let dataResponse: Data?
    public let urlResponse: HTTPURLResponse?
    public let errorResponse: Error?
    public let requestDuration: TimeInterval
    public let cURL: String?
    
    public var stringResponse: String? {
        dataResponse.flatMap({ String(data: $0, encoding: .utf8) })
    }
    
    public var jsonResponse: Any? {
        dataResponse.flatMap({ try? JSONSerialization.jsonObject(with: $0, options: []) })
    }
}
