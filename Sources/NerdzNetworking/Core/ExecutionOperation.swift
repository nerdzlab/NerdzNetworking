//
//  RequestExecutionData.swift
//  Networking
//
//  Created by new user on 28.03.2020.
//

import Foundation

public class ExecutionOperation<T: Request>: DispatchOperation {
    public typealias ResponseSuccessCallback = (T.ResponseObjectType) -> Void
    public typealias FailCallback = (ErrorResponse<T.ErrorType>) -> Void
    public typealias ProgressCallback = (Double) -> Void
    public typealias DebugCallback = (DebugInfo) -> Void
    public typealias StartCallback = () -> Void
    
    internal(set) public var request: T
    
    var dispatchOperation: DispatchOperation?
    
    private(set) var responseQueue: DispatchQueue
    private(set) var decoder: JSONDecoder
    private(set) var retryOnFail: Bool
    
    private(set) var onSuccess: [ResponseSuccessCallback] = []
    private(set) var onFail: [FailCallback] = []
    private(set) var onProgress: [ProgressCallback] = []
    private(set) var onDebug: [DebugCallback] = []
    private(set) var onStart: [StartCallback] = []
    
    private(set) var isValid: Bool = true
    
    init(request: T, decoder: JSONDecoder = JSONDecoder(), responseQueue: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main, retryOnFail: Bool = true) {
        self.request = request
        self.decoder = decoder
        self.responseQueue = responseQueue
        self.retryOnFail = retryOnFail
    }
    
    // MARK: - Setup
    
    @discardableResult
    func response(on queue: DispatchQueue) -> Self {
        responseQueue = queue
        return self
    }
    
    @discardableResult
    func decode(with decoder: JSONDecoder) -> Self {
        self.decoder = decoder
        return self
    }
    
    @discardableResult
    public func retryOnFail(_ retryOnFail: Bool) -> Self {
        self.retryOnFail = retryOnFail
        return self
    }
    
    @discardableResult
    public func onSuccess(_ closure: @escaping ResponseSuccessCallback) -> Self {
        onSuccess.append(closure)
        return self
    }
    
    @discardableResult
    public func onFail(_ closure: @escaping FailCallback) -> Self {
        onFail.append(closure)
        return self
    }
    
    @discardableResult
    public func onProgress(_ closure: @escaping ProgressCallback) -> Self {
        onProgress.append(closure)
        return self
    }
    
    @discardableResult
    public func onDebug(_ closure: @escaping DebugCallback) -> Self {
        onDebug.append(closure)
        return self
    }
    
    @discardableResult
    public func onStart(_ closure: @escaping StartCallback) -> Self {
        onStart.append(closure)
        return self
    }
    
    public func cancel() {
        dispatchOperation?.cancel()
        invalidate()
    }
    
    // MARK: - Calling closures
    
    func callOnFail(with error: ErrorResponse<T.ErrorType>) {
        responseQueue.async { [weak self] in
            for closure in self?.onFail ?? [] {
                closure(error)
            }
        }
    }
    
    func callOnSuccess(with response: T.ResponseObjectType) {
        responseQueue.async { [weak self] in
            for closure in self?.onSuccess ?? [] {
                closure(response)
            }
        }
    }
    
    func callOnProgress(with progress: Double) {
        responseQueue.async { [weak self] in
            for closure in self?.onProgress ?? [] {
                closure(progress)
            }
        }
    }
    
    func callOnDebug(with info: DebugInfo) {
        responseQueue.async { [weak self] in
            for closure in self?.onDebug ?? [] {
                closure(info)
            }
        }
    }
    
    func callOnStart() {
        responseQueue.async { [weak self] in
            for closure in self?.onStart ?? [] {
                closure()
            }
        }
    }
    
    func invalidate() {
        isValid = false
    }
}
