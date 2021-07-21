//
//  RequestType.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

fileprivate enum RequestInternalError: Error {
    case endpointIsNotInitialized

    var localizedDescription: String {
        switch self {
        case .endpointIsNotInitialized: 
            return "Default endpoint is not initialized"
        }
    }
}

public protocol Request: RequestData {
    associatedtype ResponseObjectType: Decodable
    associatedtype ErrorType: ServerError
    
    var responseConverter: ResponseJsonConverter? { get }
    var errorConverter: ResponseJsonConverter? { get } 
    
    var endpoint: Endpoint? { get }
    
    var decoder: JSONDecoder? { get }
}

public extension Request {
    var responseConverter: ResponseJsonConverter? { 
        nil
    }
    
    var errorConverter: ResponseJsonConverter? { 
        nil
    } 
    
    var endpoint: Endpoint? {
        nil
    }
    
    var decoder: JSONDecoder?  {
        nil
    }
}

public extension Request {
    typealias ResponseSuccessCallback = (ResponseObjectType) -> Void
    typealias ErrorCallback = (ErrorResponse<ErrorType>) -> Void

    var data: RequestData {
        self
    }

    @discardableResult
    func execute(on endpoint: Endpoint) -> RequestExecutionOperation<Self> {
        endpoint.execute(self)
    }
    
    @discardableResult
    func execute() -> RequestExecutionOperation<Self> {
        if let endpoint = self.endpoint ?? Endpoint.default {
            return execute(on: endpoint)
        } 
        else {
            let operation = RequestExecutionOperation<Self>(request: self)

            let queue = OperationQueue.current?.underlyingQueue ?? .main
            
            queue.async {
                operation.callOnFail(with: .system(RequestInternalError.endpointIsNotInitialized))
            }
            
            return operation
        }
    }
}
