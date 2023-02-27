//
//  RequestRetruingManager.swift
//  Networking
//
//  Created by new user on 13.10.2020.
//

import Foundation

public class RequestRetryingManager {
    
    weak var endpoint: Endpoint?
    
    private var retriers: [RequestRetrier] = []
    
    public func registerRetrier(_ retrier: RequestRetrier) {
        retriers.append(retrier)
    }
    
    public func unregisterRetrier(_ retrier: RequestRetrier) {
        if let index = retriers.firstIndex(where: { $0 === retrier }) {
            retriers.remove(at: index)
        }
    }
    
    public func retrier<T: Request>(for error: ErrorResponse<T.ErrorType>, from request: T) -> RequestRetrier? {
        return retriers.first(where: { $0.canHandleError(error, for: request) })
    }
    
    public func retriers<T: Request>(for error: ErrorResponse<T.ErrorType>, from request: T) -> [RequestRetrier] {
        return retriers.filter({ $0.canHandleError(error, for: request) })
    } 
    
    public func retries<T: Request>(for error: ErrorResponse<T.ErrorType>, from request: T) async -> T? {
        guard let endpoint = endpoint else {
            return nil
        }
        
        let retriers = retriers(for: error, from: request)
        
        for retrier in retriers {
            guard let newRequest = await retrier.handleError(error, for: request, on: endpoint) else {
                continue
            }
            
            return newRequest
        }
        
        return nil
    }
}

