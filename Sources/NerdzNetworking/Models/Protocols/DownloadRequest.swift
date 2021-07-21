//
//  DownloadRequest.swift
//  Networking
//
//  Created by new user on 20.07.2021.
//

import Foundation

fileprivate enum DownloadRequestInternalError: Error {
    case endpointIsNotInitialized

    var localizedDescription: String {
        switch self {
        case .endpointIsNotInitialized: 
            return "Endpoint is not initialized, so downloading can not be started"
        }
    }
}

public protocol DownloadRequest: RequestData {
    associatedtype ErrorType: ServerError
    
    var endpoint: Endpoint? { get }
    var location: DownloadLocation { get }
}

public extension DownloadRequest {
    var endpoint: Endpoint? {
        .download
    }
}

public extension DownloadRequest {
    typealias ErrorCallback = (ErrorResponse<ErrorType>) -> Void

    var data: RequestData {
        self
    }

    @discardableResult
    func execute(on endpoint: Endpoint) -> DownloadExecutionOperation<Self> {
        endpoint.execute(self)
    }
    
    @discardableResult
    func execute() -> DownloadExecutionOperation<Self> {
        if let endpoint = self.endpoint ?? .download {
            return execute(on: endpoint)
        } 
        else {
            let operation = DownloadExecutionOperation<Self>(request: self)

            let queue = OperationQueue.current?.underlyingQueue ?? .main
            
            queue.async {
                operation.callOnFail(with: .system(DownloadRequestInternalError.endpointIsNotInitialized))
            }
            
            return operation
        }
    }
}
