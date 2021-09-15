//
//  NetworkingRequestExecuter.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class RequestExecuter {
    
    let dispatcher: RequestDataDispatcher
    let observationManager: ObservationManager
    
    let requestRetryingManager: RequestRetryingManager
    
    private(set) var wrappers: [String: Any] = [:]
    
    init(dispatcher: RequestDataDispatcher, observationManager: ObservationManager, requestRetryingManager: RequestRetryingManager) {
        self.dispatcher = dispatcher
        self.observationManager = observationManager
        self.requestRetryingManager = requestRetryingManager
    }
    
    func execureOperation<T: Request>(_ operation: ExecutionOperation<T>) {
        let wrapper = RequestExecutionWrapper(operation: operation, dispatcher: dispatcher)
        let key = UUID().uuidString
        
        wrapper.onFinish = { [weak self, weak wrapper] result, error in
            guard let wrapper = wrapper else {
                return
            }
            
            self?.wrappers.removeValue(forKey: key)
            self?.observationManager.sendResponseNotification(request: wrapper.operation.request, result: result, error: error)
        }
        
        wrapper.onNeedRetrier = { [weak self, weak wrapper] error in
            guard let wrapper = wrapper else {
                return nil
            }
            
            return self?.requestRetryingManager.retrier(for: error, from: wrapper.operation.request)
        }
        
        wrappers[key] = wrapper
        wrapper.execute()
    }
    
    func cachedResult<RequestType: Request>(for request: RequestType, decoder: JSONDecoder, converter: ResponseJsonConverter? = nil) throws -> RequestType.ResponseObjectType? {
        
        let data = try dispatcher.cahcedResponse(for: request)
        
        return try Mapper<RequestType.ResponseObjectType>(
            decoder: decoder, 
            converter: converter)
            .map(from: data)
    }
}
