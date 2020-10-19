//
//  OnErrorRequestRetrier.swift
//  Networking
//
//  Created by new user on 12.10.2020.
//

import Foundation

public protocol OnServerErrorRequestRetrier: RequestRetrier {
    associatedtype ObservableError: ServerError
    
}

extension OnServerErrorRequestRetrier {
    
    func canHandleError<T: Request>(_ error: ErrorResponse<T.ErrorType>, for request: T) -> Bool {
        if case .server(let error, _) = error {
            return type(of: error) == ObservableError.self
        }
        else {
            return false
        }
    }
}
