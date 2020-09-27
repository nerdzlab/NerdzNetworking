//
//  NetworkingRequestExecuter.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public protocol RequestRetrier {
    @discardableResult
    func handle<T: Request>(_ error: ErrorResponse<T.ErrorType>, for request: T, completion: @escaping (T) -> Void) -> Bool
}

class RequestExecuter {
    
    let dispatcher: RequestDataDispatcher
    let observationManager: ObservationManager
    
    var requestRetries: [RequestRetrier] = []
    
    init(dispatcher: RequestDataDispatcher, observationManager: ObservationManager) {
        self.dispatcher = dispatcher
        self.observationManager = observationManager
    }
    
    @discardableResult
    func execure<T: Request>(_ request: T, with data: ResponseInfoBuilder<T>) throws -> RequestOperation {
        try execute(request, 
                    responseQueue: data.responseQueue, 
                    retryOnFail: data.retryOnFail, 
                    onSuccess: data.onSuccess, 
                    onError: data.onFail, 
                    onProgress: data.onProgress, 
                    onDebug: data.onDebug)
    }
    
    @discardableResult
    func execute<T: Request>(
        _ request: T, 
        responseQueue   : DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main, 
        retryOnFail     : Bool = true, 
        onSuccess       : ((T.ResponseObjectType) -> Void)? = nil, 
        onError         : ((ErrorResponse<T.ErrorType>) -> Void)? = nil,
        onProgress      : ((Double) -> Void)? = nil,
        onDebug         : ((DebugInfo) -> Void)? = nil,
        onStart         : ((RequestOperation) -> Void)? = nil) throws 
        
        -> RequestOperation 
    {
        let operation = try dispatcher.dispatch(request.data,
                                                
                                                onSuccess: { [weak self] (data, statusCode) in
                                                    guard let strongSelf = self else {
                                                        return
                                                    }
                                                    
                                                    do {
                                                        let statusCode = StatusCode(statusCode)
                                                    
                                                        if statusCode.isSuccessful {
                                                            let result = try T.ResponseObjectType.mapper.mapResponse(data, with: request.responseConverter)
                                                            
                                                            strongSelf.callSuccess(
                                                                for: request, 
                                                                on: responseQueue, 
                                                                with: result, 
                                                                onSuccess: onSuccess)
                                                        }
                                                        else {
                                                            let result = try T.ErrorType.mapper.mapResponse(data, with: request.errorConverter)
                                                            let error: ErrorResponse<T.ErrorType> = .server(result, statusCode: statusCode)
                                                            
                                                            if retryOnFail {
                                                                strongSelf.retry(
                                                                    with: error, 
                                                                    for: request, 
                                                                    responseQueue: responseQueue, 
                                                                    onSuccess: onSuccess, 
                                                                    onError: onError)
                                                            }
                                                            else {
                                                                strongSelf.callError(
                                                                    for: request, 
                                                                    on: responseQueue, 
                                                                    with: error, 
                                                                    onError: onError)
                                                            }
                                                        }
                                                    }
                                                    catch {
                                                        strongSelf.callError(
                                                            for: request, 
                                                            on: responseQueue, 
                                                            with: .system(error), 
                                                            onError: onError)
                                                    }
            },
                                                
                                                onError: { [weak self] in
                                                    
                                                    let error: ErrorResponse<T.ErrorType> = .system($0)
                                                    
                                                    if retryOnFail {
                                                        self?.retry(
                                                            with: error, 
                                                            for: request, 
                                                            responseQueue: responseQueue, 
                                                            onSuccess: onSuccess, 
                                                            onError: onError)
                                                    }
                                                    else {
                                                        self?.callError(
                                                            for: request, 
                                                            on: responseQueue, 
                                                            with: error, 
                                                            onError: onError)
                                                    }
            },
                                                onProgress: onProgress,
                                                onDebug: onDebug)
        
        
        onStart?(operation)
        return operation
    }
    
    private func callSuccess<T: Request>(for request: T, on responseQueue: DispatchQueue, with result: T.ResponseObjectType, onSuccess: ((T.ResponseObjectType) -> Void)?) {
        
        responseQueue.async { onSuccess?(result) }
        
        observationManager.sendResponseNotification(
            request: request, 
            result: result, 
            error: nil)
    }
    
    private func callError<T: Request>(for request: T, on responseQueue: DispatchQueue, with error: ErrorResponse<T.ErrorType>, onError: ((ErrorResponse<T.ErrorType>) -> Void)?) {
        
        responseQueue.async { onError?(error) }
        
        observationManager.sendResponseNotification(
            request: request, 
            result: nil, 
            error: error)
    }
    
    private func retry<T: Request>(with error: ErrorResponse<T.ErrorType>, for request: T, responseQueue: DispatchQueue, onSuccess: ((T.ResponseObjectType) -> Void)? = nil, onError: ((ErrorResponse<T.ErrorType>) -> Void)? = nil) {
        
        for retrier in requestRetries {
            let handled = retrier.handle(error, for: request) { [weak self] newRequest in
                let _ = try? self?.execute(newRequest, 
                                           responseQueue: responseQueue, 
                                           retryOnFail: false, 
                                           onSuccess: onSuccess, 
                                           onError: onError)
            }
            
            if handled {
                return
            }
        }
        
        callError(
            for: request, 
            on: responseQueue, 
            with: error, 
            onError: onError)
    }
}
