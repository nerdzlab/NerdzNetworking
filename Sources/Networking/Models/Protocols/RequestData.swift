//
//  RequestData.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public protocol RequestData {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParams: [(String, String)] { get }
    var bodyParams: [String: Any] { get }
    var headers: [NetworkingHeader] { get }
    var timeout: TimeInterval? { get }
}

public extension RequestData {
    var queryParams: [(String, String)] { return [] }
    var bodyParams: [String: Any] { return [:] }
    var headers: [NetworkingHeader] { return [] }
    var timeout: TimeInterval? { return nil }
}
