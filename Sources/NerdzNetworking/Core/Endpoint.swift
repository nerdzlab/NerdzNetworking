//
//  Endpoint.swift
//  Networking
//
//  Created by new user on 28.03.2020.
//

import Foundation

public class Endpoint {
    // MARK: - Singleton
    public static var `default`: Endpoint?
    
    // MARK: - Configuration
    public let baseUrl: URL
    public let sessionConfiguration: URLSessionConfiguration
    
    public var headers: [RequestHeaderKey: String] {
        didSet { requestFactory.headers = headers }
    }

    var requestFactory: RequestFactory {
        requestDispatcher.requestFactory
    }
    
    var requestDispatcher: RequestDataDispatcher {
        requestExecuter.dispatcher
    }
    
    private(set) var requestExecuter: RequestExecuter
    
    // MARK: - Initialization
    
    public init(
        baseUrl: URL, 
        sessionConfiguration: URLSessionConfiguration = .default,
        headers: [RequestHeaderKey: String] = [:]) 
    {
        self.baseUrl = baseUrl
        self.sessionConfiguration = sessionConfiguration
        self.headers = headers
        
        self.requestExecuter = Endpoint.createdRequestExecuter(
            baseUrl             : baseUrl, 
            sessionConfiguration: sessionConfiguration,
            headers             : headers)
    }
    
    // MARK: - Methods(Public)
    
    public func execute<T: Request>(_ request: T) -> ResponseInfoBuilder<T> {
        let data = ResponseInfoBuilder<T>()
        
        let queue = OperationQueue.current?.underlyingQueue ?? .main
        
        queue.async {
            do {
                try self.requestExecuter.execure(request, with: data)
            }
            catch {
                data.onFail?(.system(error))
            }
        }
        
        return data
    }
    
    // MARK: - Methods(Private)
    
    private static func createdRequestExecuter(
        baseUrl             : URL, 
        sessionConfiguration: URLSessionConfiguration,
        headers             : [RequestHeaderKey: String]) 
        
        -> RequestExecuter
    {
        let requestFactory = createdRequestFactory(
            baseUrl: baseUrl,
            headers: headers)
        
        let networkDispatcher = createdNetworkDispatcher(
            requestFactory  : requestFactory, 
            configuration   : sessionConfiguration)
        
        let requestExecuter = createdRequestExecuter(
            networkDispatcher   : networkDispatcher, 
            observationManager  : ObservationManager())
        
        return requestExecuter
    }
    
    private static func createdRequestExecuter(
        networkDispatcher   : RequestDataDispatcher, 
        observationManager  : ObservationManager)
        
        -> RequestExecuter 
    {
        return RequestExecuter(dispatcher: networkDispatcher, observationManager: observationManager)
    }
    
    private static func createdNetworkDispatcher(
        requestFactory  : RequestFactory, 
        configuration   : URLSessionConfiguration) 
        
        -> RequestDataDispatcher 
    {
        return RequestDataDispatcher(requestFactory: requestFactory, sessionConfiguration: configuration)
    }
    
    private static func createdRequestFactory(
        baseUrl: URL,
        headers: [RequestHeaderKey: String]) 
        
        -> RequestFactory 
    {
        RequestFactory(baseUrl: baseUrl, headers: headers)
    }
}
