//
//  RequestType.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

fileprivate enum RequestInternalError: Error {
    case defaultEndpointIsNotInitialized

    var localizedDescription: String {
        switch self {
        case .defaultEndpointIsNotInitialized: 
            return "Default endpoint is not initialized"
        }
    }
}

public protocol Request: RequestData {
    associatedtype ResponseObjectType: ResponseObject
    associatedtype ErrorType: ServerError
    
    var responseConverter: ResponseJsonConverter? { get }
    var errorConverter: ResponseJsonConverter? { get } 
    
    var endpoint: Endpoint? { get }
}

public extension Request {
    var responseConverter: ResponseJsonConverter? { 
        return nil
    }
    
    var errorConverter: ResponseJsonConverter? { 
        return nil
    } 
    
    var endpoint: Endpoint? {
        return nil
    }
}

extension Request {
    public typealias ResponseSuccessCallback = (ResponseObjectType) -> Void
    public typealias ErrorCallback = (ErrorResponse<ErrorType>) -> Void

    var data: RequestData {
        return self
    }

    @discardableResult
    public func execute(on endpoint: Endpoint) -> ResponseInfoBuilder<Self> {
        endpoint.execute(self)
    }
    
    @discardableResult
    public func execute() -> ResponseInfoBuilder<Self> {
        if let endpoint = self.endpoint ?? Endpoint.default {
            return execute(on: endpoint)
        } 
        else {
            let mockedData = ResponseInfoBuilder<Self>()

            let queue = OperationQueue.current?.underlyingQueue ?? .main
            
            queue.async {
                mockedData.onFail?(.system(RequestInternalError.defaultEndpointIsNotInitialized))
            }
            
            return mockedData
        }
    }
}
