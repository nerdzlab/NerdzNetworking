//
//  Endpoint.swift
//  Networking
//
//  Created by new user on 28.03.2020.
//

import Foundation
import TrustKit

open class Endpoint {
    
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
    
    // MARK: - Completions
    
    open var onNewTokenAutoSet: ((TokenContainer?) -> Void)?
    
    // MARK: - Configuration
    
    public let decoder: JSONDecoder
    public let responseQueue: DispatchQueue?
    
    public let baseUrl: URL
    public let sessionConfiguration: URLSessionConfiguration
    public let retryingCount: Int
    public let observation = ObservationManager()
    
    public let requestRetrying = RequestRetryingManager()
    
    public var handleAppMoveToBackground: Bool = false {
        didSet {
            requestExecuter.handleAppMoveToBackground = handleAppMoveToBackground
        }
    }
    
    open var trustKit: TrustKit? {
        didSet {
            requestDispatcher.trustKit = trustKit
        }
    }
    
    open var headers: [RequestHeaderKey: String] {
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
        decoder: JSONDecoder = JSONDecoder(),
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
        
        setupComponents()
    }
    
    // MARK: - Methods(Public)
    
    @available(iOS 13, *)
    @discardableResult
    open func asyncExecute<T: Request>(_ request: T) async throws -> T.ResponseObjectType {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.execute(request)
                .onSuccess {
                    continuation.resume(returning: $0)
                }
            
                .onFail {
                    continuation.resume(throwing: $0)
                }
        }
    }
    
    open func execute<T: Request>(_ request: T) -> ExecutionOperation<T> {
        let queue = responseQueue ?? OperationQueue.current?.underlyingQueue ?? .main
        let decoder = request.decoder ?? self.decoder
        let operation = ExecutionOperation<T>(request: request, decoder: decoder, responseQueue: queue, retryingCount: retryingCount)
        
        queue.async {
            self.requestExecuter.execureOperation(operation)
        }
        
        return operation
    }
    
    open func cURL<T: Request>(for request: T) throws -> String {
        try requestFactory.request(from: request).cURL
    }
    
    open func useAsDefault() {
        type(of: self).default = self
    }
    
    open func cachedResponse<T: Request>(
        for request: T, 
        decoder: JSONDecoder? = nil, 
        converter: ResponseJsonConverter? = nil
    ) -> T.ResponseObjectType? 
    {
        do {
            let finalDecoder = decoder ?? self.decoder
            return try requestExecuter.cachedResult(for: request, decoder: finalDecoder, converter: converter)
        }
        catch {
            return nil
        }
    }
    
    @discardableResult
    open func clearCache<RequestType: Request>(for request: RequestType) -> Bool {
        do {
            try requestExecuter.clearCache(for: request)
            return true
        }
        catch {
            return false
        }
    }
    @discardableResult
    open func clearAllCache() -> Bool {
        
        requestExecuter.clearAllCache()
        return true
    }
    
    // MARK: - Methonds(Internal)
    
    var test: TokenContainer?
    
    func setNewAuthToken(_ tokenContainer: TokenContainer?) {   
        // TODO: workaround to dispatch
        DispatchQueue.main.async {
            self.headers.authToken = tokenContainer?.token
            self.onNewTokenAutoSet?(tokenContainer)
        }   
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
    
    private func setupComponents() {
        requestRetrying.endpoint = self
        
        requestExecuter.onNewTokenReceived = { [weak self] tokenContainer in
            self?.setNewAuthToken(tokenContainer)
        }
    }
}
