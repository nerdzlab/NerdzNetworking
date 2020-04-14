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
    
    public var contentType: MimeType {
        didSet { requestFactory.contentType = contentType }
    }
    
    public var accept: MimeType {
        didSet { requestFactory.accept = accept }
    }
    
    public var additionalHeaders: [RequestHeader] {
        didSet { requestFactory.headers = additionalHeaders }
    }
    
    public var token: AuthToken? {
        didSet { requestFactory.tokenHeader = token }
    }
    
    var requestFactory: RequestFactory {
        requestDispatcher.requestFactory
    }
    
    var requestDispatcher: RequestDataDispatcher {
        requestExecuter.dispatcher
    }
    
    private(set) var requestExecuter: RequestExecuter
    
    // MARK: - Methods(Public)
    
    func execute<T: Request>(_ request: T) -> ResponseInfoBuilder<T> {
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
    
    // MARK: - Initialization
    public init(
        baseUrl: URL, 
        sessionConfiguration: URLSessionConfiguration = .default,
        contentType: MimeType = .application(.json),
        accept: MimeType = .application(.json),
        token: AuthToken? = nil,
        additionalHeaders: [RequestHeader] = []) 
    {
        self.baseUrl = baseUrl
        self.sessionConfiguration = sessionConfiguration
        self.contentType = contentType
        self.accept = accept
        self.additionalHeaders = additionalHeaders
        self.token = token
        
        self.requestExecuter = Endpoint.createdRequestExecuter(
            baseUrl             : baseUrl, 
            sessionConfiguration: sessionConfiguration, 
            contentType         : contentType, 
            accept              : accept, 
            token               : token, 
            additionalHeaders   : additionalHeaders)
    }
    
    private static func createdRequestExecuter(
        baseUrl             : URL, 
        sessionConfiguration: URLSessionConfiguration,
        contentType         : MimeType,
        accept              : MimeType,
        token               : AuthToken?,
        additionalHeaders   : [RequestHeader]) 
        
        -> RequestExecuter
    {
        let requestFactory = createdRequestFactory(
            baseUrl          : baseUrl, 
            tokenHeader      : token, 
            contentType      : contentType, 
            accept           : accept,
            additionalHeaders: additionalHeaders)
        
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
        baseUrl          : URL, 
        tokenHeader      : AuthToken?, 
        contentType      : MimeType, 
        accept           : MimeType,
        additionalHeaders: [RequestHeader]) 
        
        -> RequestFactory 
    {
        let requestFactory = RequestFactory(baseUrl: baseUrl)
        
        requestFactory.tokenHeader = tokenHeader
        requestFactory.contentType = contentType
        requestFactory.accept      = accept
        
        return requestFactory
    }
}
