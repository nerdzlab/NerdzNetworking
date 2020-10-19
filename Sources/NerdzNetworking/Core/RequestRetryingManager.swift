//
//  RequestRetruingManager.swift
//  Networking
//
//  Created by new user on 13.10.2020.
//

import Foundation

public class RequestRetryingManager {
    private var retriers: [RequestRetrier] = []
    
    public func registerRetrier(_ retrier: RequestRetrier) {
        retriers.append(retrier)
    }
    
    public func unregisterRetrier(_ retrier: RequestRetrier) {
        if let index = retriers.firstIndex(where: { $0 === retrier }) {
            retriers.remove(at: index)
        }
    }
    
    public  func retrier<T: Request>(for error: ErrorResponse<T.ErrorType>, from request: T) -> RequestRetrier? {
        return retriers.first(where: { $0.canHandleError(error, for: request) })
    }
}

