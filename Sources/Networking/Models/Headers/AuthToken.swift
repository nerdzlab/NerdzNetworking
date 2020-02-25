//
//  AuthToken.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public enum AuthToken: NetworkingHeader, Equatable {
    case bearer(_ token: String)
    case jwt(_ token: String)
    case custom(_ token: String)

    public var key: String {
        return "Authorization"
    }

    public var value: String {
        switch self {
        case .bearer(let token): return "Bearer \(token)"
        case .jwt(let token): return "JWT \(token)"
        case .custom(let token): return token
        }
    }

    var token: String {
        switch self {
        case .bearer(let token), .jwt(let token), .custom(let token): return token
        }
    }

    public static func ==(left: AuthToken, right: AuthToken) -> Bool {
        return left.value == right.value
    }
}
