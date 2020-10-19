//
//  OnStatusCodesRequestRetrier.swift
//  Networking
//
//  Created by new user on 12.10.2020.
//

import Foundation

public protocol OnStatusCodesRequestRetrier: RequestRetrier {
    var codes: [StatusCode] { get }
}

public extension OnStatusCodesRequestRetrier {
    func canHandleError<T: Request>(_ error: ErrorResponse<T.ErrorType>, for request: T) -> Bool {
        if case .server(_, let statusCode) = error {
            return codes.contains(statusCode)
        }
        else {
            return false
        }
    }
}
