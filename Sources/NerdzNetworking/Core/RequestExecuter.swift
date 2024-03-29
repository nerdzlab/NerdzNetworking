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
    
    var onNewTokenReceived: ((TokenContainer) -> Void)?
    
    let dispatcher: RequestDataDispatcher
    let observationManager: ObservationManager
    let requestRetryingManager: RequestRetryingManager
    
    var handleAppMoveToBackground: Bool = false
    
    private(set) var wrappers: [String: Any] = [:]
    private var backgroundTasks: [String: UIBackgroundTaskIdentifier] = [:]
    
    init(dispatcher: RequestDataDispatcher, observationManager: ObservationManager, requestRetryingManager: RequestRetryingManager) {
        self.dispatcher = dispatcher
        self.observationManager = observationManager
        self.requestRetryingManager = requestRetryingManager
    }
    
    func execureOperation<T: Request>(_ operation: ExecutionOperation<T>) {
        let wrapper = RequestExecutionWrapper(operation: operation, dispatcher: dispatcher)
        let key = UUID().uuidString
        
        if handleAppMoveToBackground {
            let taskId = UIApplication.shared.beginBackgroundTask(withName: key) { [weak self] in
                self?.endBackgroundTask(for: key)
            }
            
            backgroundTasks[key] = taskId
        }
        
        wrapper.onFinish = { [weak self, weak wrapper] result, error in
            guard let wrapper = wrapper else {
                return
            }
            
            self?.wrappers.removeValue(forKey: key)
            self?.handleExecutionFinish(for: wrapper, result: result, error: error)
            self?.endBackgroundTask(for: key)
        }
        
        wrapper.onRetry = { [weak self, weak wrapper] error in
            guard let wrapper = wrapper else {
                return nil
            }
            
            return await self?.requestRetryingManager.retries(for: error, from: wrapper.operation.request)
        }
        
        wrappers[key] = wrapper
        wrapper.execute()
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
    
    private func endBackgroundTask(for key: String) {
        guard let id = backgroundTasks.removeValue(forKey: key) else {
            return
        }
        
        UIApplication.shared.endBackgroundTask(id)
    }
}
