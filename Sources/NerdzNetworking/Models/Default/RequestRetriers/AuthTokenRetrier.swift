//
//  File.swift
//  
//
//  Created by new user on 21.09.2022.
//

import Foundation

public class AuthTokenRetrier<RequestType: Request>: OnStatusCodesRequestRetrier where RequestType.ResponseObjectType: TokenContainer {
    public typealias RefreshRequestAction = () -> RequestType?
    
    public var codes: [StatusCode] {
        [.unauthorized, .forbidden]
    }
    
    
    public var onNeedRefreshRequest: RefreshRequestAction?
    
    public func handleError<T>(_ error: ErrorResponse<T.ErrorType>, for request: T, on endpoint: Endpoint) async -> T? where T : Request {
        guard let refreshRequest = onNeedRefreshRequest?() else {
            return nil
        }
        
        if let response = try? await endpoint.asyncExecute(refreshRequest) {
            endpoint.setNewAuthToken(response.token)
            return request
        }
        else {
            return nil
        }
    }
}
