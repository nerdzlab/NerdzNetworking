//
//  File.swift
//  
//
//  Created by new user on 21.09.2022.
//

import Foundation

public class AuthTokenRetrier<RequestType: Request>: OnStatusCodesRequestRetrier where RequestType.ResponseObjectType: TokenContainer {
    
    public var codes: [StatusCode] {
        [.unauthorized, .forbidden]
    }
    
    public var onNeedRefreshRequest: RequestType?
    
    private var pendingRefreshRequest: RequestType?
    
    public init() {
        
    }
    
    public func canHandleError<T>(_ error: ErrorResponse<T.ErrorType>, for request: T) -> Bool where T : Request {
        let canBeExecutedByParrent = (self as OnStatusCodesRequestRetrier).canHandleError(error, for: request)
        
        return canBeExecutedByParrent && (pendingRefreshRequest as AnyObject) === (request as AnyObject)
    }
    
    public func handleError<T>(_ error: ErrorResponse<T.ErrorType>, for request: T, on endpoint: Endpoint) async -> T? where T : Request {
        guard let refreshRequest = onNeedRefreshRequest else {
            return nil
        }
        
        pendingRefreshRequest = refreshRequest
        
        if let response = try? await endpoint.asyncExecute(refreshRequest) {
            endpoint.setNewAuthToken(response)
            return request
        }
        else {
            return nil
        }
    }
}
