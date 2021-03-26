//
//  ServerError.swift
//  Networking
//
//  Created by Vasyl Khmil on 05.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public protocol ServerError: Decodable {
    var message: String { get }
}

extension String: ServerError {
    public var message: String {
        return self
    }
}

extension Optional: ServerError where Wrapped: ServerError {
    public var message: String {
        switch self {
        case .some(let error): return error.message
        case .none: return "Empty response"
        }
    }
}
