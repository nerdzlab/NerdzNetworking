//
//  RequestExecutionWrapper.swift
//  Networking
//
//  Created by new user on 20.10.2020.
//

import Foundation

class RequestExecutionWrapper<T: Request> {
    
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
        operation.callOnSuccess(with: result) { [weak self] in
            self?.onFinish?(result, nil)
        }
    }
    
    private func callError(with error: ErrorResponse<T.ErrorType>) {
        operation.callOnFail(with: error) { [weak self] in
            self?.onFinish?(nil, error)
        }
    }
}
