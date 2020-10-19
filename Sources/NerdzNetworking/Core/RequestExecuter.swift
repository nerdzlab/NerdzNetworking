//
//  NetworkingRequestExecuter.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

fileprivate class RequestExecutionWrapper<T: Request> {
    
    var onNeedRetrier: ((_ error: ErrorResponse<T.ErrorType>) -> RequestRetrier?)?
    var onFinish: ((_ result: T.ResponseObjectType?, _ error: ErrorResponse<T.ErrorType>?) -> Void)?
    
    let operation: ExecutionOperation<T>
    let dispatcher: RequestDataDispatcher
    
    init(operation: ExecutionOperation<T>, dispatcher: RequestDataDispatcher) {
        self.operation = operation
        self.dispatcher = dispatcher
    }
    
    func execute() {
        do {
            let dispatchOperation = try dispatcher.dispatch(
                operation.request.data,
                onSuccess: { [weak self] (data, statusCode) in
                    self?.handleDispatchingSuccess(with: data, statusCode)
                },
                
                onError: { [weak self] in
                    self?.handleDispatchingError(with: $0)
                },
                
                onProgress: { [weak self] in
                    self?.operation.callOnProgress(with: $0)
                },
                
                onDebug:  { [weak self] in
                    self?.operation.callOnDebug(with: $0)
                })
            
            operation.dispatchOperation = dispatchOperation
            operation.callOnStart()
        }
        catch {
            operation.callOnFail(with: .system(error))
        }
    }
    
    private func handleDispatchingSuccess(with response: Data?, _ statusCode: Int) {
        do {
            let statusCode = StatusCode(statusCode)
        
            if statusCode.isSuccessful {
                let result = try Mapper<T.ResponseObjectType>(decoder: self.operation.decoder).map(from: response)
                self.callSuccess(with: result)
            }
            else {
                let result = try Mapper<T.ErrorType>(decoder: self.operation.decoder).map(from: response)
                let error: ErrorResponse<T.ErrorType> = .server(result, statusCode: statusCode)
                retryIfNeededOrCall(for: error)
            }
        }
        catch {
            self.callError(with: .system(error))
        }
    }
    
    private func handleDispatchingError(with error: Error) {
        let error: ErrorResponse<T.ErrorType> = .system(error)
        retryIfNeededOrCall(for: error)
    }
    
    private func retryIfNeededOrCall(for error: ErrorResponse<T.ErrorType>) {
        if let retrier = onNeedRetrier?(error), operation.retryOnFail {
            retrier.handleError(error, for: operation.request) { [weak self] newRequest in
                self?.operation.request = newRequest
                self?.execute()
            }
        }
        else {
            callError(with: error)
        }
    }
    
    private func callSuccess(with result: T.ResponseObjectType) {
        operation.callOnSuccess(with: result)
        onFinish?(result, nil)
    }
    
    private func callError(with error: ErrorResponse<T.ErrorType>) {
        operation.callOnFail(with: error)
        onFinish?(nil, error)
    }
}

class RequestExecuter {
    
    let dispatcher: RequestDataDispatcher
    let observationManager: ObservationManager
    
    let requestRetryingManager: RequestRetryingManager
    
    private(set) var wrappers: [String: Any] = [:]
    
    init(dispatcher: RequestDataDispatcher, observationManager: ObservationManager, requestRetryingManager: RequestRetryingManager) {
        self.dispatcher = dispatcher
        self.observationManager = observationManager
        self.requestRetryingManager = requestRetryingManager
    }
    
    func execureOperation<T: Request>(_ operation: ExecutionOperation<T>) {
        let wrapper = RequestExecutionWrapper(operation: operation, dispatcher: dispatcher)
        let key = UUID().uuidString
        
        wrapper.onFinish = { [weak self, weak wrapper] result, error in
            guard let wrapper = wrapper else {
                return
            }
            
            self?.wrappers.removeValue(forKey: key)
            self?.observationManager.sendResponseNotification(request: wrapper.operation.request, result: result, error: error)
        }
        
        wrapper.onNeedRetrier = { [weak self, weak wrapper] error in
            guard let wrapper = wrapper else {
                return nil
            }
            
            return self?.requestRetryingManager.retrier(for: error, from: wrapper.operation.request)
        }
        
        wrappers[key] = wrapper
        wrapper.execute()
    }
}
