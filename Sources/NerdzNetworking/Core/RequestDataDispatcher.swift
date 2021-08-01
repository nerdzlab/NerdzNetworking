//
//  URLSessionNetworkDispatcher.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class RequestDataDispatcher: NSObject, URLSessionDataDelegate {
    
    // MARK: - Constants
    
    private enum Constants {
        static let downloadSessionId = "NerdzNetworking.downloadSession"
    }
    
    // MARK: - Errors
    
    private enum RequestDataDispatcher: Error {
        case invalidResponse
        
        var localizedDescription: String {
            switch self {
            case .invalidResponse: 
                return "Response is invalid"
            }
        }
    }
    
    // MARK: - Properties(Public)
    
    let requestFactory: RequestFactory
    let httpRequestConfiguration: URLSessionConfiguration
    
    let downloadConfiguration = URLSessionConfiguration.background(withIdentifier: Constants.downloadSessionId)
    
    private(set) lazy var httpRequestSession: URLSession = {
        return URLSession(configuration: httpRequestConfiguration, delegate: self, delegateQueue: .main) 
    }()
    
    init(requestFactory: RequestFactory, sessionConfiguration: URLSessionConfiguration = .default) {
        self.httpRequestConfiguration = sessionConfiguration
        self.requestFactory = requestFactory
    }
    
    // MARK: - Properties(Private)
    
    private var progressClosures: [URLSessionTask: (Double) -> Void] = [:]
    
    public func dispatch(
        _ requestData   : RequestData, 
        onSuccess       : ((Data?, Int) -> Void)? = nil, 
        onError         : ((Error) -> Void)? = nil,
        onProgress      : ((Double) -> Void)? = nil,
        onDebug         : ((DebugInfo) -> Void)? = nil) throws 
        
        -> DispatchOperation 
    {
        let request = try requestFactory.request(from: requestData)
        
        let requestStartDate = Date()
        
        let task = httpRequestSession.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {
                return
            }
            
            let debugInfo = DebugInfo(
                sessionConfiguration: self.httpRequestSession.configuration, 
                request             : request, 
                dataResponse        : data, 
                urlResponse         : response as? HTTPURLResponse, 
                errorResponse       : error, 
                requestDuration     : Date().timeIntervalSince(requestStartDate),
                cURL                : request.cURL)
            
            onDebug?(debugInfo)
            
            if let error = error {
                onError?(error)
                return
            }
            
            if let httpUrlResponse = response as? HTTPURLResponse {
                onSuccess?(data, httpUrlResponse.statusCode)
            }
            else {
                onError?(RequestDataDispatcher.invalidResponse)
            }
        }
        
        if let progressClosure = onProgress {
            progressClosures[task] = progressClosure
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - URLSessionDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let closure = progressClosures[task] {
            let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
            closure(progress)
        }
    }
}
