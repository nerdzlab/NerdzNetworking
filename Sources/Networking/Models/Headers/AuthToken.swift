//
//  AuthToken.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public enum AuthToken: RequestHeader, Equatable {
    case bearer(_ token: String, key: String = "Authorization")
    case jwt(_ token: String, key: String = "Authorization")
    case custom(_ token: String, key: String = "Authorization")

    public var key: String {
        switch self {
        case .custom(_, let key), .jwt(_, let key), .bearer(_, let key):
            return key
        }
    }

    public var value: String {
        switch self {
        case .bearer(let token, _): return "Bearer \(token)"
        case .jwt(let token, _): return "JWT \(token)"
        case .custom(let token, _): return token
        }
    }

    var token: String {
        switch self {
        case .bearer(let token, _), .jwt(let token, _), .custom(let token, _): 
            return token
        }
    }

    public static func ==(left: AuthToken, right: AuthToken) -> Bool {
        return left.value == right.value
    }
}
