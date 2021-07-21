//
//  RequestRetrier.swift
//  Networking
//
//  Created by new user on 12.10.2020.
//

import Foundation

public protocol RequestRetrier: AnyObject {
    
    func canHandleError<T: Request>(_ error: ErrorResponse<T.ErrorType>, for request: T) -> Bool
    
    func handleError<T: Request>(_ error: ErrorResponse<T.ErrorType>, for request: T, completion: @escaping (T?) -> Void)
}
