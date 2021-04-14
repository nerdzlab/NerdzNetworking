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
    private(set) var retryingCount: Int
    
    var willRetryOnFail: Bool {
        retryingCount > 0
    }
    
    private(set) var onSuccess: [ResponseSuccessCallback] = []
    private(set) var onFail: [FailCallback] = []
    private(set) var onProgress: [ProgressCallback] = []
    private(set) var onDebug: [DebugCallback] = []
    private(set) var onStart: [StartCallback] = []
    
    private(set) var isValid: Bool = true
    
    init(request: T, decoder: JSONDecoder = JSONDecoder(), responseQueue: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main, retryingCount: Int = 1) {
        self.request = request
        self.decoder = decoder
        self.responseQueue = responseQueue
        self.retryingCount = retryingCount
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
    public func retryOnFail(_ retryingCount: Int) -> Self {
        self.retryingCount = retryingCount
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
    
    func callOnFail(with error: ErrorResponse<T.ErrorType>, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onFail ?? [] {
                closure(error)
            }
            
            completion?()
        }
    }
    
    func callOnSuccess(with response: T.ResponseObjectType, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onSuccess ?? [] {
                closure(response)
            }
            
            completion?()
        }
    }
    
    func callOnProgress(with progress: Double, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onProgress ?? [] {
                closure(progress)
            }
            
            completion?()
        }
    }
    
    func callOnDebug(with info: DebugInfo, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onDebug ?? [] {
                closure(info)
            }
            
            completion?()
        }
    }
    
    func callOnStart(completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onStart ?? [] {
                closure()
            }
            
            completion?()
        }
    }
    
    func handleRetryOnFailActionMade() {
        retryingCount = max(0, retryingCount - 1)
    }
    
    func invalidate() {
        isValid = false
    }
}
