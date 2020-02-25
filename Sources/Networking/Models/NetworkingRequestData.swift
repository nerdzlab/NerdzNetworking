//
//  RequestData.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public protocol NetworkingRequestData {
    var path: String { get }
    var method: NetworkingHTTPMethod { get }
    var queryParams: [(String, String)] { get }
    var bodyParams: [String: Any] { get }
    var headers: [NetworkingHeader] { get }
    var timeout: TimeInterval? { get }
}

public extension NetworkingRequestData {
    var queryParams: [(String, String)] { return [] }
    var bodyParams: [String: Any] { return [:] }
    var headers: [NetworkingHeader] { return [] }
    var timeout: TimeInterval? { return nil }
}
