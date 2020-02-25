//
//  NetworkingDebugInfo.swift
//  Networking
//
//  Created by new user on 25.02.2020.
//

import Foundation

public struct NetworkingDebugInfo {
    let sessionConfiguration: URLSessionConfiguration
    let request: URLRequest
    let dataResponse: Data?
    let urlResponse: HTTPURLResponse?
    let errorResponse: Error?
    let requestDuration: TimeInterval
}
