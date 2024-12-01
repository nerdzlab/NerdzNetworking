//
//  File.swift
//  
//
//  Created by new user on 21.09.2022.
//

import Foundation

public class AuthTokenRetrier<RequestType: Request>: OnStatusCodesRequestRetrier where RequestType.ResponseObjectType: TokenContainer {
    
    public enum Errors: LocalizedError {
        case noRequest
        case failedRefresh
        
        public var errorDescription: String {
            switch self {
            case .noRequest:
                return "No refresh request provided"
                
            case .failedRefresh:
                return "Failed to refresh token"
            }
        }
    }
    
    public typealias GetRefreshRequestAction = () -> RequestType?
    public typealias RefreshFailedAction = (ErrorResponse<RequestType.ErrorType>) -> Void
    
    public var codes: [StatusCode] {
        [.unauthorized, .forbidden]
    }
    
    public var onNeedRefreshRequest: GetRefreshRequestAction?
    public var onRefreshFailed: RefreshFailedAction?
    
    private var isRefreshing: SyncPropertyActor<Bool> = SyncPropertyActor(false)
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
        
        return canBeExecutedByParrent
    }
    
    public func handleError<T>(_ error: ErrorResponse<T.ErrorType>, for request: T, on endpoint: Endpoint) async -> T? where T : Request {
        guard let refreshRequest = onNeedRefreshRequest?() else {
            onRefreshFailed?(.system(Errors.noRequest))
            return nil
        }
        
        guard refreshRequest.path != request.path else {
            onRefreshFailed?(.system(Errors.failedRefresh))
            return nil
        }
        
        let isRefreshing = await isRefreshing.value
        
        if isRefreshing {
            let tokenSuccessfullyUpdated = await withCheckedContinuation { [weak self] continuation in
                self?.pendingFinishContinuations.append(continuation)
            }
            
            return tokenSuccessfullyUpdated ? request : nil
        }
        
        await self.isRefreshing.setNewValue(true)
        
        do {
            let response = try await endpoint.asyncExecute(refreshRequest)
            endpoint.headers.authToken = response.token
            
            
            await finishRefreshing(with: true)
            
            return request
        }
        catch ErrorResponse<RequestType.ErrorType>.server(let error, statusCode: let code) {
            onRefreshFailed?(.server(error, statusCode: code))
            
            await finishRefreshing(with: false)
        }
        catch ErrorResponse<RequestType.ErrorType>.system(let error) {
            onRefreshFailed?(.system(error))
            
            await finishRefreshing(with: false)
        }
        catch {
            onRefreshFailed?(.system(error))
            
            await finishRefreshing(with: false)
        }
        
        return nil
    }
    private func finishRefreshing(with status: Bool) async {
        for continuation in pendingFinishContinuations {
            continuation.resume(returning: status)
        }
        
        await self.isRefreshing.setNewValue(false)
        pendingFinishContinuations.removeAll()
    }
}
