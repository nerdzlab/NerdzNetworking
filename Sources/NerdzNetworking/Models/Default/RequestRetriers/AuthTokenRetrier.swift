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
    private var pendingFinishContinuations: [CheckedContinuation<Bool, Never>] = []
    
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
        
        /// Handling rthe case when one request already started token refresh process. In this case all othher requests just need to wait untill token refresh process will finish instead of starting its own process
        let refreshHapenned = await waitUntilRefreshFinished()
        
        guard !refreshHapenned else {
            return request
        }
        
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
            
            /// After refrersh finish we call all pending continuations to specify that refresh finished and no new refresh need to be happenning
            for continuation in pendingFinishContinuations {
                continuation.resume(returning: true)
            }
            
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
    
    /// Retrurning true if process of refreshing is finished and not nedded to be performed
    private func waitUntilRefreshFinished() async -> Bool {
        return await withCheckedContinuation { [weak self] continuation in
            /// If we do not have pending refresh request we return false to specify that refresh need to be happenned
            if self?.pendingRefreshRequest == nil {
                continuation.resume(returning: false)
            }
            /// In onther case we save continuation to be used after refresh finish
            else {
                self?.pendingFinishContinuations.append(continuation)
            }
        }
    }
}
