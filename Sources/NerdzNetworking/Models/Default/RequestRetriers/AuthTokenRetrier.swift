//
//  File.swift
//  
//
//  Created by new user on 21.09.2022.
//

import Foundation

public class AuthTokenRetrier<RequestType: Request>: OnStatusCodesRequestRetrier where RequestType.ResponseObjectType: TokenContainer {
    public typealias GetRefreshRequestAction = () -> RequestType?
    public typealias RefreshFailedAction = (ErrorResponse<RequestType.ErrorType>) -> Void
    
    public var codes: [StatusCode] {
        [.unauthorized, .forbidden]
    }
    
    public var onNeedRefreshRequest: GetRefreshRequestAction?
    public var onRefreshFailed: RefreshFailedAction?
    
    private var pendingRefreshRequest: RequestType?
    
    public init() {
        
    }
    
    public func canHandleError<T>(_ error: ErrorResponse<T.ErrorType>, for request: T) -> Bool where T : Request {
        let canBeExecutedByParrent: Bool
        
        if case .server(_, let statusCode) = error {
            canBeExecutedByParrent = codes.contains(statusCode)
        }
        else {
            canBeExecutedByParrent = false
        }
        
        return canBeExecutedByParrent && pendingRefreshRequest?.path != request.path
    }
    
    public func handleError<T>(_ error: ErrorResponse<T.ErrorType>, for request: T, on endpoint: Endpoint) async -> T? where T : Request {
        guard let refreshRequest = onNeedRefreshRequest?() else {
            return nil
        }
        
        pendingRefreshRequest = refreshRequest
        
        defer {
            pendingRefreshRequest = nil
        }
        
        do {
            let response = try await endpoint.asyncExecute(refreshRequest)
            endpoint.setNewAuthToken(response)
            return request
        }
        catch ErrorResponse<RequestType.ErrorType>.server(let error, statusCode: let code) {
            onRefreshFailed?(.server(error, statusCode: code))
        }
        catch ErrorResponse<RequestType.ErrorType>.system(let error) {
            onRefreshFailed?(.system(error))
        }
        catch {
            print(error)
        }
        
        return nil
    }
}
