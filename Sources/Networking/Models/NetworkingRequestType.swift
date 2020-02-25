//
//  RequestType.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

enum RequestTypeInternalError: Error {
    case stackNotInitialized

    var localizedDescription: String {
        switch self {
        case .stackNotInitialized: return "Networking stack is not initialized"
        }
    }
}

public protocol NetworkingRequestType: NetworkingRequestData {
    associatedtype ResponseObjectType: NetworkingResponseObject
    associatedtype ErrorType: NetworkingServerError
    
    var responseConverter: NetworkingResponseJsonConverter? { get }
    var errorConverter: NetworkingResponseJsonConverter? { get } 
}

public extension NetworkingRequestType {
    var responseConverter: NetworkingResponseJsonConverter? { 
        return nil
    }
    
    var errorConverter: NetworkingResponseJsonConverter? { 
        return nil
    } 
}

public protocol MultipartFormDataRequestType: NetworkingRequestType, NetworkingMultipartRequestData { }

extension NetworkingRequestType {
    public typealias ResponseSuccessCallback = (ResponseObjectType) -> Void
    public typealias ErrorCallback = (NetworkingError<ErrorType>) -> Void

    typealias EmptyResponseSuccessCallback = () -> Void
    typealias EmptyErrorCallback = () -> Void

    var data: NetworkingRequestData {
        return self
    }

    @discardableResult
    public func execute(
        responseQueue   : DispatchQueue = .main, 
        retryOnFail     : Bool = true, 
        onSuccess       : ResponseSuccessCallback? = nil, 
        onError         : ErrorCallback? = nil,
        onProgress      : ((Double) -> Void)? = nil,
        onDebug         : ((NetworkingDebugInfo) -> Void)? = nil) 
        
        -> NetworkingRequestOperation? 
    {
        guard let stack = NetworkingStack.instance else {
            onError?(.system(RequestTypeInternalError.stackNotInitialized))
            return nil
        }
        do {
            return try stack.requestExecuter.execute(self, 
            responseQueue: responseQueue, 
            retryOnFail: retryOnFail, 
            onSuccess: onSuccess, 
            onError: onError,
            onProgress: onProgress,
            onDebug: onDebug)
        }
        catch {
            onError?(.system(error))
            return nil
        }
    }
}
