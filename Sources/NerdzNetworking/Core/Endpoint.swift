//
//  Endpoint.swift
//  Networking
//
//  Created by new user on 28.03.2020.
//

import Foundation

public class Endpoint {
    
    private enum Constants {
        static let defaultHeaders: [RequestHeaderKey: String] = {
            var headers: [RequestHeaderKey: String] = [:]
            headers.accept = .application(.json)
            headers.contentType = .application(.json)
            return headers
        }()
    }
    
    // MARK: - Singleton
    
    public static var `default`: Endpoint?
    
    // MARK: - Configuration
    
    public let decoder: JSONDecoder?
    public let responseQueue: DispatchQueue?
    
    public let baseUrl: URL
    public let sessionConfiguration: URLSessionConfiguration
    public let retryingCount: Int
    public let observation = ObservationManager()
    public let requestRetrying = RequestRetryingManager()
    
    public var headers: [RequestHeaderKey: String] {
        didSet { requestFactory.headers = headers }
    }

    var requestFactory: RequestFactory {
        requestDispatcher.requestFactory
    }
    
    var requestDispatcher: RequestDataDispatcher {
        requestExecuter.dispatcher
    }
    
    private var requestExecuter: RequestExecuter
    
    // MARK: - Initialization
    
    public init(
        baseUrl: URL,
        decoder: JSONDecoder? = nil,
        responseQueue: DispatchQueue? = nil,
        sessionConfiguration: URLSessionConfiguration = .default,
        retryingCount: Int = 1,
        headers: [RequestHeaderKey: String] = [:]
    ) 
    {
        self.baseUrl = baseUrl
        self.decoder = decoder
        self.responseQueue = responseQueue
        self.retryingCount = retryingCount
        self.sessionConfiguration = sessionConfiguration
        self.headers = Constants.defaultHeaders + headers
        
        self.requestExecuter = Endpoint.createdRequestExecuter(
            baseUrl                 : baseUrl, 
            sessionConfiguration    : sessionConfiguration,
            headers                 : headers,
            observation             : observation,
            requestRetryingManager  : requestRetrying)
    }
    
    // MARK: - Methods(Public)
    
    public func execute<T: Request>(_ request: T) -> ExecutionOperation<T> {
        let queue = responseQueue ?? OperationQueue.current?.underlyingQueue ?? .main
        let decoder = request.decoder ?? self.decoder ?? JSONDecoder()
        let operation = ExecutionOperation<T>(request: request, decoder: decoder, responseQueue: queue, retryingCount: retryingCount)
        
        queue.async {
            self.requestExecuter.execureOperation(operation)
        }
        
        return operation
    }
    
    public func cURL<T: Request>(for request: T) throws -> String {
        try requestFactory.request(from: request).cURL
    }
    
    public func useAsDefault() {
        type(of: self).default = self
    }
    
    // MARK: - Methods(Private)
    
    private static func createdRequestExecuter(
        baseUrl                 : URL, 
        sessionConfiguration    : URLSessionConfiguration,
        headers                 : [RequestHeaderKey: String],
        observation             : ObservationManager,
        requestRetryingManager  : RequestRetryingManager) 
        
        -> RequestExecuter
    {
        let requestFactory = createdRequestFactory(
            baseUrl: baseUrl,
            headers: headers)
        
        let networkDispatcher = createdNetworkDispatcher(
            requestFactory  : requestFactory, 
            configuration   : sessionConfiguration)
        
        let requestExecuter = createdRequestExecuter(
            networkDispatcher       : networkDispatcher, 
            observationManager      : observation,
            requestRetryingManager  : requestRetryingManager)
        
        return requestExecuter
    }
    
    private static func createdRequestExecuter(
        networkDispatcher       : RequestDataDispatcher, 
        observationManager      : ObservationManager,
        requestRetryingManager  : RequestRetryingManager)
        
        -> RequestExecuter 
    {
        return RequestExecuter(
            dispatcher: networkDispatcher, 
            observationManager: observationManager,
            requestRetryingManager: requestRetryingManager)
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
