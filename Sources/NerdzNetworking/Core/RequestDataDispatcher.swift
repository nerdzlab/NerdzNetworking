//
//  URLSessionNetworkDispatcher.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class RequestDataDispatcher: NSObject, URLSessionDataDelegate {
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
    
    private struct DataTaskInfo {
        let id: Int
        let startDate: Date
        let request: URLRequest
        
        var response: HTTPURLResponse?
        
        let onSuccess: ((Data?, Int) -> Void)? 
        let onError: ((Error) -> Void)?
        let onProgress: ((Double) -> Void)?
        let onDebug: ((DebugInfo) -> Void)?
    }
    
    // MARK: - Properties(Public)
    
    let requestFactory: RequestFactory
    let configuration: URLSessionConfiguration
    
    // MARK: - Properties(Private)
    
    private var ongoingTasks: [Int: DataTaskInfo] = [:]
    
    private(set) lazy var session: URLSession = {
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main) 
    }()
    
    init(requestFactory: RequestFactory, sessionConfiguration: URLSessionConfiguration) {
        self.configuration = sessionConfiguration
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
        
        let task = session.dataTask(with: request)
        
        ongoingTasks[task.taskIdentifier] = DataTaskInfo(
            id: task.taskIdentifier, 
            startDate: Date(), 
            request: request, 
            response: nil, 
            onSuccess: onSuccess, 
            onError: onError, 
            onProgress: onProgress, 
            onDebug: onDebug
        )
        
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
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard var info = ongoingTasks[dataTask.taskIdentifier] else {
            completionHandler(.cancel)
            return
        }
        
        info.response = response as? HTTPURLResponse
        ongoingTasks[dataTask.taskIdentifier] = info
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let info = ongoingTasks[dataTask.taskIdentifier] else {
            return
        }
        
        let response = info.response
        let request = info.request
        
        let debugInfo = DebugInfo(
            sessionConfiguration: self.session.configuration, 
            request             : request, 
            dataResponse        : data, 
            urlResponse         : response, 
            errorResponse       : nil, 
            requestDuration     : Date().timeIntervalSince(info.startDate),
            cURL                : request.cURL)
        
        info.onDebug?(debugInfo)
        info.onSuccess?(data, response?.statusCode ?? 0)
        
        ongoingTasks.removeValue(forKey: dataTask.taskIdentifier)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = task as? URLSessionDataTask else {
            return
        }
        
        guard let error = error else {
            return
        }
        
        ongoingTasks[task.taskIdentifier]?.onError?(error)
    }
}
