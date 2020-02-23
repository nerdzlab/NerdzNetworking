//
//  NetworkingErrors.swift
//  Networking
//
//  Created by Vasyl Khmil on 22.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

enum NetworkingError<T: NetworkingServerError> {
    case custom(_ error: T, statusCode: NetworkingStatusCode)
    case system(_ error: Error)

    var message: String {
        switch self {
        case .system(let error): return error.localizedDescription
        case .custom(let error, _): return error.message
        }
    }
}
