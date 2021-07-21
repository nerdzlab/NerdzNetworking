//
//  DownloadRequestExecutionOperation.swift
//  Networking
//
//  Created by new user on 20.07.2021.
//

import Foundation

public class DownloadExecutionOperation<T: DownloadRequest>: ExecutionOperation<T> {
    public typealias DataReceivedCallback = (Data) -> Void
    public typealias FailCallback = (ErrorResponse<T.ErrorType>) -> Void
    public typealias SavedToDiskCallback = (URL) -> Void

    private(set) var location: DownloadLocation
    
    private(set) var onDataReceived: [DataReceivedCallback] = []
    private(set) var onCached: [SavedToDiskCallback] = []
    private(set) var onSaved: [SavedToDiskCallback] = []
    private(set) var onFail: [FailCallback] = []
    
    internal(set) public var request: T
    
    init(request: T, responseQueue: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main) {
        self.request = request
        self.location = request.location
        
        super.init(responseQueue: responseQueue)
    }
    
    @discardableResult
    public func save(to location: DownloadLocation) -> Self {
        self.location = location
        return self
    }
    
    @discardableResult
    public func onDataReceived(_ closure: @escaping DataReceivedCallback) -> Self {
        onDataReceived.append(closure)
        return self
    }
    
    @discardableResult
    public func onCached(_ closure: @escaping SavedToDiskCallback) -> Self {
        onCached.append(closure)
        return self
    }
    
    @discardableResult
    public func onSaved(_ closure: @escaping SavedToDiskCallback) -> Self {
        onSaved.append(closure)
        return self
    }
    
    @discardableResult
    public func onFail(_ closure: @escaping FailCallback) -> Self {
        onFail.append(closure)
        return self
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
    
    func callOnCached(with url: URL, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onCached ?? [] {
                closure(url)
            }
            
            completion?()
        }
    }
    
    func callOnSaved(with url: URL, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onSaved ?? [] {
                closure(url)
            }
            
            completion?()
        }
    }
    
    func callOnDataReceived(with data: Data, completion: (() -> Void)? = nil) {
        responseQueue.async { [weak self] in
            for closure in self?.onDataReceived ?? [] {
                closure(data)
            }
            
            completion?()
        }
    }
}
