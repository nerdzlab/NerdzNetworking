//
//  URLSessionNetworkDispatcher.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class NetworkingURLSessionNetworkDispatcher: NSObject, URLSessionDataDelegate {
    // MARK: - Errors
    
    enum Errors: Error {
        case invalidResponse
        
        var localizedDescription: String {
            switch self {
            case .invalidResponse: return "Response is invalid"
            }
        }
    }
    
    // MARK: - DebugInfo
    
    struct DebugInfo {
        let sessionConfiguration: URLSessionConfiguration
        let request: URLRequest
        let dataResponse: Data?
        let urlResponse: HTTPURLResponse?
        let errorResponse: Error?
        let requestDuration: TimeInterval
    }
    
    // MARK: - Properties(Public)
    
    let requestFactory: NetworkingRequestFactory
    let configuration: URLSessionConfiguration
    
    private(set) lazy var session: URLSession = {
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main) 
    }()
    
    init(requestFactory: NetworkingRequestFactory, sessionConfiguration: URLSessionConfiguration = .default) {
        self.configuration = sessionConfiguration
        self.requestFactory = requestFactory
    }
    
    // MARK: - Properties(Private)
    
    private var progressClosures: [URLSessionTask: (Double) -> Void] = [:]
    
    public func dispatch(
        _ requestData   : NetworkingRequestData, 
        onSuccess       : ((Data?, Int) -> Void)? = nil, 
        onError         : ((Error) -> Void)? = nil,
        onProgress      : ((Double) -> Void)? = nil,
        onDebug         : ((DebugInfo) -> Void)? = nil) throws 
        
        -> NetworkingRequestOperation 
    {
        let request = try requestFactory.request(from: requestData)
        
        let requestStartDate = Date()
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {
                return
            }
            
            let debugInfo = DebugInfo(
                sessionConfiguration: self.session.configuration, 
                request             : request, 
                dataResponse        : data, 
                urlResponse         : response as? HTTPURLResponse, 
                errorResponse       : error, 
                requestDuration     : Date().timeIntervalSince(requestStartDate))
            
            onDebug?(debugInfo)
            
            if let error = error {
                onError?(error)
                return
            }
            
            if let httpUrlResponse = response as? HTTPURLResponse {
                onSuccess?(data, httpUrlResponse.statusCode)
            }
            else {
                onError?(Errors.invalidResponse)
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
