//
//  RequestExecutionWrapper.swift
//  Networking
//
//  Created by new user on 20.10.2020.
//

import Foundation

class RequestExecutionWrapper<RequestType: Request> {
    
    var onNeedRetrier: ((_ error: ErrorResponse<RequestType.ErrorType>) -> RequestRetrier?)?
    var onFinish: ((_ result: RequestType.ResponseObjectType?, _ error: ErrorResponse<RequestType.ErrorType>?) -> Void)?
    
    let operation: ExecutionOperation<RequestType>
    let dispatcher: RequestDataDispatcher
    
    init(operation: ExecutionOperation<RequestType>, dispatcher: RequestDataDispatcher) {
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
    
    private func handleDispatchingSuccess( with response: Data?, _ statusCode: Int) {
        do {
            let statusCode = StatusCode(statusCode)
        
            if statusCode.isSuccessful {
                let result = try Mapper<RequestType.ResponseObjectType>(
                    decoder: self.operation.decoder, 
                    converter: self.operation.request.responseConverter)
                    .map(from: response)
                
                self.callSuccess(with: result)
            }
            else {
                let result = try Mapper<RequestType.ErrorType>(
                    decoder: self.operation.decoder, 
                    converter: self.operation.request.errorConverter)
                    .map(from: response)
                
                let error: ErrorResponse<RequestType.ErrorType> = .server(result, statusCode: statusCode)
                retryIfNeededOrCall(for: error)
            }
        }
        catch {
            self.callError(with: .system(error))
        }
    }
    
    private func handleDispatchingError(with error: Error) {
        let error: ErrorResponse<RequestType.ErrorType> = .system(error)
        retryIfNeededOrCall(for: error)
    }
    
    private func retryIfNeededOrCall(for error: ErrorResponse<RequestType.ErrorType>) {
        if let retrier = onNeedRetrier?(error), operation.willRetryOnFail {
            operation.handleRetryOnFailActionMade()
            
            retrier.handleError(error, for: operation.request) { [weak self] newRequest in
                if let request = newRequest {
                    self?.operation.request = request
                    self?.execute()
                }
                else {
                    self?.retryIfNeededOrCall(for: error)
                }
            }
        }
        else {
            callError(with: error)
        }
    }
    
    private func callSuccess(with result: RequestType.ResponseObjectType) {
        operation.callOnSuccess(with: result) { [weak self] in
            self?.onFinish?(result, nil)
        }
    }
    
    private func callError(with error: ErrorResponse<RequestType.ErrorType>) {
        operation.callOnFail(with: error) { [weak self] in
            self?.onFinish?(nil, error)
        }
    }
}
