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
    var body: RequestBody? { get }
    var headers: [RequestHeaderKey: String] { get }
    var timeout: TimeInterval? { get }
    var shouldCache: Bool { get }
}

public extension RequestData {
    var queryParams: [(String, String)] { [] }
    var body: RequestBody? { nil }
    var headers: [RequestHeaderKey: String] { [:] }
    var timeout: TimeInterval? { nil }
    var shouldCache: Bool { false }
}
