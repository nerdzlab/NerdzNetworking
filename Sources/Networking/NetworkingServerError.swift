//
//  ServerError.swift
//  Networking
//
//  Created by Vasyl Khmil on 05.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public protocol NetworkingServerError: NetworkingResponseObject {
    var message: String { get }
}

extension String: NetworkingServerError {
    public var message: String {
        return self
    }
}

extension Dictionary: NetworkingServerError where Key == String {
    public var message: String {
        return description
    }
}
