//
//  ExecutionOperation.swift
//  Networking
//
//  Created by new user on 21.07.2021.
//

import Foundation

public class ExecutionOperation<T: RequestData>: DispatchOperation {
    public typealias ProgressCallback = (Double) -> Void
    public typealias StartCallback = () -> Void
    
    var dispatchOperation: DispatchOperation?
    
    private(set) var responseQueue: DispatchQueue
    
    private(set) var isValid: Bool = true
    
    private(set) var onProgress: [ProgressCallback] = []
    private(set) var onStart: [StartCallback] = []
    
    init(responseQueue: DispatchQueue = .main) {
        self.responseQueue = responseQueue
    }
    
    // MARK: - Setup
    
    @discardableResult
    public func response(on queue: DispatchQueue) -> Self {
        responseQueue = queue
        return self
    }
    
    @discardableResult
    public func onProgress(_ closure: @escaping ProgressCallback) -> Self {
        onProgress.append(closure)
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
    
    func callOnProgress(with progress: Double, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onProgress ?? [] {
                closure(progress)
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
    
    func invalidate() {
        isValid = false
    }
}
