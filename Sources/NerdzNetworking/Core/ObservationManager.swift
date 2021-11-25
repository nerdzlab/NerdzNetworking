//
//  NetworkingObservationManager.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public class ObservationManager {
    public typealias MultipleObserverClosure = (_ request: Any, _ result: Any?, _ error: Any?) -> Void
    public typealias StatusCodeObserverClosure = (_ statusCode: StatusCode, _ request: Any?) -> Void
    
    private var singleRequestObservers: [String: Any] = [:]
    private var multipleRequestsObservers: [String: MultipleRequestsObserver] = [:]
    private var statusCodeObservers: [String: StatusCodeObserverClosureWrapper] = [:]

    @discardableResult
    public func register<RequestType: Request>(_ closure: @escaping (RequestType, RequestType.ResponseObjectType?, ErrorResponse<RequestType.ErrorType>?) -> Void) -> String {
        register(SingleRequestObserverClosureWrapper(closure))
    }
    
    @discardableResult
    public func register(_ closure: @escaping MultipleObserverClosure) -> String {
        register(MultipleRequestsObserverClosureWrapper(closure))
    }
    
    @discardableResult
    public func register<T: SingleRequestObserver>(_ observer: T) -> String {
        let token = UUID().uuidString
        
        singleRequestObservers[token] = SingleRequestObserverClosureWrapper {
            observer.handle(request: $0, result: $1, error: $2)
        }
        
        return token
    }
    
    @discardableResult
    public func register(_ observer: MultipleRequestsObserver) -> String {
        let token = UUID().uuidString
        multipleRequestsObservers[token] = observer
        return token
    }
    
    @discardableResult
    public func register(for code: StatusCode? = nil, _ closure: @escaping StatusCodeObserverClosure) -> String {
        let token = UUID().uuidString
        statusCodeObservers[token] = StatusCodeObserverClosureWrapper(closure: closure, statusCode: code)
        return token
    }
    
    public func unregisterObserver(with token: String) {
        singleRequestObservers.removeValue(forKey: token)
        multipleRequestsObservers.removeValue(forKey: token)
        statusCodeObservers.removeValue(forKey: token)
    }

    func sendResponseNotification<RequestType: Request>(request: RequestType, result: RequestType.ResponseObjectType?, error: ErrorResponse<RequestType.ErrorType>?) {
        for observer in Array(singleRequestObservers.values) {
            (observer as? SingleRequestObserverClosureWrapper<RequestType>)?.handle(request: request, result: result, error: error)
        }
        
        for observer in Array(multipleRequestsObservers.values) {
            observer.handle(request: request, result: result, error: error)
        }
        
        if case .server(_, let code) = error {
            for wrapper in Array(statusCodeObservers.values) {
                guard code == wrapper.statusCode || wrapper.statusCode == nil else {
                    continue
                }
                
                wrapper.closure(code, request)
            }
        }
    }
}

// MARK: - Protocols

public protocol SingleRequestObserver {
    associatedtype ObservableRequest: Request
    
    func handle(request: ObservableRequest, result: ObservableRequest.ResponseObjectType?, error: ErrorResponse<ObservableRequest.ErrorType>?)
}

public protocol MultipleRequestsObserver {
    func handle<RequestType: Request>(request: RequestType, result: RequestType.ResponseObjectType?, error: ErrorResponse<RequestType.ErrorType>?)
}

// MARK: - Closure wrappers

private class SingleRequestObserverClosureWrapper<RequestType: Request>: SingleRequestObserver {
    typealias NotifyClosure = (RequestType, RequestType.ResponseObjectType?, ErrorResponse<RequestType.ErrorType>?) -> Void
    typealias ObservableRequest = RequestType
    
    fileprivate let notifyClosure: NotifyClosure

    init(_ closure: @escaping NotifyClosure) {
        self.notifyClosure = closure
    }
    
    func handle(request: RequestType, result: RequestType.ResponseObjectType?, error: ErrorResponse<RequestType.ErrorType>?) {
        self.notifyClosure(request, result, error)
    }
}

private class MultipleRequestsObserverClosureWrapper: MultipleRequestsObserver {
    
    let notifyClosure: ObservationManager.MultipleObserverClosure

    init(_ closure: @escaping ObservationManager.MultipleObserverClosure) {
        self.notifyClosure = closure
    }
    
    func handle<T>(request: T, result: T.ResponseObjectType?, error: ErrorResponse<T.ErrorType>?) where T : Request {
        notifyClosure(request, result, error)
    }
}

private class StatusCodeObserverClosureWrapper {
    let statusCode: StatusCode?
    let closure: ObservationManager.StatusCodeObserverClosure
    
    init(closure: @escaping ObservationManager.StatusCodeObserverClosure, statusCode: StatusCode? = nil) {
        self.closure = closure
        self.statusCode = statusCode
    }
}
