//
//  NetworkingRequestExecuter.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation
import UIKit

class RequestExecuter {
    private struct ExecutionInfo {
        let isExecuted: Bool
        let backgroundTask: UIBackgroundTaskIdentifier?
        let wrapper: Any
    }
    
    var onNewTokenReceived: ((TokenContainer) -> Void)?
    
    let dispatcher: RequestDataDispatcher
    let observationManager: ObservationManager
    let requestRetryingManager: RequestRetryingManager
    
    var handleAppMoveToBackground: Bool = false
    
    private var wrappers: [String: ExecutionInfo] = [:]
    
    init(dispatcher: RequestDataDispatcher, observationManager: ObservationManager, requestRetryingManager: RequestRetryingManager) {
        self.dispatcher = dispatcher
        self.observationManager = observationManager
        self.requestRetryingManager = requestRetryingManager
    }
    
    func execureOperation<T: Request>(_ operation: ExecutionOperation<T>) {
        let wrapper = RequestExecutionWrapper(operation: operation, dispatcher: dispatcher)
        let key = UUID().uuidString
        
        var backgroundTask: UIBackgroundTaskIdentifier?
        
        if handleAppMoveToBackground {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: key) { [weak self] in
                self?.endBackgroundTask(for: self?.wrappers[key]?.backgroundTask)
            }
        }
        
        wrapper.onFinish = { [weak self, weak wrapper] result, error in
            guard let wrapper = wrapper else {
                return
            }
            
            let info = self?.wrappers.removeValue(forKey: key)
            self?.handleExecutionFinish(for: wrapper, result: result, error: error)
            self?.endBackgroundTask(for: info?.backgroundTask)
            
            if info?.isExecuted == true {
                self?.handlePendingExecutionInfo(wrapper: wrapper, result: result, error: error)
            }
        }
        
        wrapper.onRetry = { [weak self, weak wrapper] error in
            guard let wrapper = wrapper else {
                return nil
            }
            
            return await self?.requestRetryingManager.retries(for: error, from: wrapper.operation.request)
        }
        
        if operation.request.supportParallelExecution {
            wrappers[key] = ExecutionInfo(isExecuted: true, backgroundTask: backgroundTask, wrapper: wrapper)
            wrapper.execute()
        }
        else {
            /// Checking if same request is being executed at the moment to avoid making similar GET requests in parallel
            let executingSameRequest = wrappers.contains(where: { info in
                guard let storedWrapper = info.value.wrapper as? RequestExecutionWrapper<T> else {
                    return false
                }
                
                return wrapper.operation.request.isEqual(to: storedWrapper.operation.request) && info.value.isExecuted
            })
            
            wrappers[key] = ExecutionInfo(isExecuted: !executingSameRequest, backgroundTask: backgroundTask, wrapper: wrapper)
            
            if !executingSameRequest {
                wrapper.execute()
            }
        }
    }
    
    func cachedResult<RequestType: Request>(for request: RequestType, decoder: JSONDecoder, converter: ResponseJsonConverter? = nil) throws -> RequestType.ResponseObjectType? {
        
        let data = try dispatcher.cahcedResponse(for: request)
        let finalConverter = converter ?? request.responseConverter
        
        return try Mapper<RequestType.ResponseObjectType>(
            decoder: decoder, 
            converter: finalConverter)
            .map(from: data)
    }
    
    func clearCache<RequestType: Request>(for request: RequestType) throws {
        try dispatcher.clearCachedResponse(for: request)
    }
    
    func clearAllCache() {
        dispatcher.clearAllCachedResponses()
    }
    
    private func handleExecutionFinish<T: Request>(for wrapper: RequestExecutionWrapper<T>, result: T.ResponseObjectType?, error: ErrorResponse<T.ErrorType>?) {
        
        if let tokenContainer = result as? TokenContainer {
            onNewTokenReceived?(tokenContainer)
        }
        
        observationManager.sendResponseNotification(request: wrapper.operation.request, result: result, error: error)
    }
    
    private func endBackgroundTask(for id: UIBackgroundTaskIdentifier?) {
        guard let id else {
            return
        }
        
        UIApplication.shared.endBackgroundTask(id)
    }
    
    private func handlePendingExecutionInfo<RequestType: Request>(wrapper: RequestExecutionWrapper<RequestType>, result: RequestType.ResponseObjectType?, error: ErrorResponse<RequestType.ErrorType>?) {
        
        for (key, value) in wrappers {
            guard !value.isExecuted else {
                return
            }
            
            guard let pendingWrapper = value.wrapper as? RequestExecutionWrapper<RequestType> else {
                continue
            }
            
            guard pendingWrapper.operation.request.isEqual(to: wrapper.operation.request) else {
                return
            }
            
            pendingWrapper.onFinish?(result, error)
            wrappers.removeValue(forKey: key)
        }
    }
}
