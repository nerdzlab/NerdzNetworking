//
//  RequestExecutionData.swift
//  Networking
//
//  Created by new user on 28.03.2020.
//

import Foundation

public class ResponseInfoBuilder<T: Request> {
    public typealias ResponseSuccessCallback = (T.ResponseObjectType) -> Void
    public typealias FailCallback = (ErrorResponse<T.ErrorType>) -> Void
    public typealias ProgressCallback = (Double) -> Void
    public typealias DebugCallback = (DebugInfo) -> Void
    public typealias StartCallback = (RequestOperation) -> Void
    
    private(set) var responseQueue: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main
    private(set) var retryOnFail: Bool = true 
    
    private(set) var onSuccess: ResponseSuccessCallback? = nil
    private(set) var onFail: FailCallback? = nil
    private(set) var onProgress: ProgressCallback? = nil
    private(set) var onDebug: DebugCallback? = nil 
    private(set) var onStart: StartCallback? = nil
    
    @discardableResult
    func responseOn(_ queue: DispatchQueue) -> Self {
        responseQueue = queue
        return self
    }
    
    func retryOnFail(_ retryOnFail: Bool) -> Self {
        self.retryOnFail = retryOnFail
        return self
    }
    
    func onSuccess(_ closure: @escaping ResponseSuccessCallback) -> Self {
        onSuccess = closure
        return self
    }
    
    func onFail(_ closure: @escaping FailCallback) -> Self {
        onFail = closure
        return self
    }
    
    func onProgress(_ closure: @escaping ProgressCallback) -> Self {
        onProgress = closure
        return self
    }
    
    func onDebug(_ closure: @escaping DebugCallback) -> Self {
        onDebug = closure
        return self
    }
    
    func onStart(_ closure: @escaping StartCallback) -> Self {
        onStart = closure
        return self
    }
}
