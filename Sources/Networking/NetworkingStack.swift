//
//  Networking.swift
//  Brew
//
//  Created by Vasyl Khmil on 1/18/19.
//  Copyright © 2019 NerdzLab. All rights reserved.
//

import Foundation

// MARK: NetworkingStack

class NetworkingStack {
    // MARK: - Errors
    enum Errors: Error {
        case stackAlreadyInitialized
        
        var localizedDescription: String {
            switch self {
            case .stackAlreadyInitialized: return "Networking stack already initialize. To reinitialize use `force` parameter"
            }
        }
    }
    
    // MARK: - Singleton
    static private(set) var instance: NetworkingStack?
    
    // MARK: - Configuration
    let baseUrl: URL
    let sessionConfiguration: URLSessionConfiguration
    
    var contentType: MimeType {
        didSet { requestFactory.contentType = contentType }
    }
    
    var accept: MimeType {
        didSet { requestFactory.accept = accept }
    }
    
    var additionalHeaders: [NetworkingHeader] {
        didSet { requestFactory.headers = additionalHeaders }
    }
    
    var token: AuthToken? {
        didSet { requestFactory.tokenHeader = token }
    }
    
    // MARK: - Stack
    private(set) var authManager: AuthManager?
    private(set) var requestExecuter: NetworkingRequestExecuter
    
    var observationManager: NetworkingObservationManager {
        requestExecuter.observationManager
    }
    
    var requestDispatcher: NetworkingURLSessionNetworkDispatcher {
        requestExecuter.dispatcher
    }
    
    var requestFactory: NetworkingRequestFactory {
        requestDispatcher.requestFactory
    }
    
    // MARK: - Initialization
    private init(
        baseUrl: URL, 
        sessionConfiguration: URLSessionConfiguration,
        contentType: MimeType,
        accept: MimeType = .applicationJson,
        token: AuthToken?,
        additionalHeaders: [NetworkingHeader]) 
    {
        self.baseUrl = baseUrl
        self.sessionConfiguration = sessionConfiguration
        self.contentType = contentType
        self.accept = accept
        self.additionalHeaders = additionalHeaders
        self.token = token
        
        self.requestExecuter = NetworkingStack.createdRequestExecuter(
            baseUrl             : baseUrl, 
            sessionConfiguration: sessionConfiguration, 
            contentType         : contentType, 
            accept              : accept, 
            token               : token, 
            additionalHeaders   : additionalHeaders)
    }
    
    static func initialize(
        baseUrl             : URL, 
        sessionConfiguration: URLSessionConfiguration = .default,
        contentType         : MimeType = .applicationJson,
        accept              : MimeType = .applicationJson,
        token               : AuthToken? = nil,
        additionalHeaders   : [NetworkingHeader] = [],
        
        force: Bool = false) throws 
    {
        guard instance == nil || force else {
            throw Errors.stackAlreadyInitialized
        }
        
        instance = NetworkingStack(
            baseUrl             : baseUrl, 
            sessionConfiguration: sessionConfiguration, 
            contentType         : contentType, 
            accept              : accept, 
            token               : token, 
            additionalHeaders   : additionalHeaders)
    }
    
    func setAuthManager(_ authManager: AuthManager) {
        guard self.authManager == nil else {
            return
        }
        
        self.authManager = authManager
    }
    
    private func configure() {
        
    }
    
    private static func createdRequestExecuter(
        baseUrl             : URL, 
        sessionConfiguration: URLSessionConfiguration,
        contentType         : MimeType,
        accept              : MimeType,
        token               : AuthToken?,
        additionalHeaders   : [NetworkingHeader]) 
        
        -> NetworkingRequestExecuter
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
            observationManager  : NetworkingObservationManager())
        
        return requestExecuter
    }
    
    private static func createdRequestExecuter(
        networkDispatcher   : NetworkingURLSessionNetworkDispatcher, 
        observationManager  : NetworkingObservationManager)
        
        -> NetworkingRequestExecuter 
    {
        return NetworkingRequestExecuter(dispatcher: networkDispatcher, observationManager: observationManager)
    }
    
    private static func createdNetworkDispatcher(
        requestFactory  : NetworkingRequestFactory, 
        configuration   : URLSessionConfiguration) 
        
        -> NetworkingURLSessionNetworkDispatcher 
    {
        return NetworkingURLSessionNetworkDispatcher(requestFactory: requestFactory, sessionConfiguration: configuration)
    }
    
    private static func createdRequestFactory(
        baseUrl          : URL, 
        tokenHeader      : AuthToken?, 
        contentType      : MimeType, 
        accept           : MimeType,
        additionalHeaders: [NetworkingHeader]) 
        
        -> NetworkingRequestFactory 
    {
        let requestFactory = NetworkingRequestFactory(baseUrl: baseUrl)
        
        requestFactory.tokenHeader = tokenHeader
        requestFactory.contentType = contentType
        requestFactory.accept      = accept
        
        return requestFactory
    }
}

// MARK: - AuthManager

protocol AuthManager: class {
    var authToken: AuthToken? { get }
    
    var onTokenUpdated: ((_ newToken: AuthToken?) -> Void)? { get set }
    
    @discardableResult
    func refreshToken(completion: ((_ success: Bool) -> Void)?) -> Bool
    
    @discardableResult
    func logout(completion: ((_ success: Bool) -> Void)?) -> Bool
}

// MARK: - RequestRetrier

protocol RequestRetrier {
    @discardableResult
    func handle<T: NetworkingRequestType>(_ error: NetworkingError<T.ErrorType>, for request: T, completion: @escaping (T) -> Void) -> Bool
}
