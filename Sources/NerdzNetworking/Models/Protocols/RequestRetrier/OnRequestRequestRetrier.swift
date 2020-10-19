//
//  OnRequestRequestRetrier.swift
//  Networking
//
//  Created by new user on 12.10.2020.
//

import Foundation

public protocol OnRequestRequestRetrier: RequestRetrier {
    associatedtype ObservableRequest: Request
    
    var detailRequest: ObservableRequest? { get }
}

public extension OnRequestRequestRetrier {
    func canHandleError<T: Request>(_ error: ErrorResponse<T.ErrorType>, for request: T) -> Bool {
        T.self == ObservableRequest.self
    }
}
