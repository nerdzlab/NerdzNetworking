//
//  File.swift
//  
//
//  Created by new user on 21.09.2022.
//

import Foundation
import ObjectiveC

private var retriesCountHandler: UInt = 0

class RequestFailureRetrier: RequestRetrier {
    private class WeakRequest {
        
        /// Wrapped object
        weak var object: AnyObject?
        
        init(_ object: AnyObject) {
            self.object = object
        }
    }
    
    let retryCount: Int
    
    private var requests: [String: WeakRequest] = [:]
    private var atempts: [String: Int] = [:]
    
    init(retryCount: Int = 1) {
        self.retryCount = retryCount
    }
    
    func canHandleError<T>(_ error: ErrorResponse<T.ErrorType>, for request: T) -> Bool where T : Request {
        let retryCount = (objc_getAssociatedObject(request, &retriesCountHandler) as? Int) ?? 0
        
        return retryCount < self.retryCount
    }
    
    func handleError<T: Request>(_ error: ErrorResponse<T.ErrorType>, for request: T, on endpoint: Endpoint) async -> T? {
        let retryCount = (objc_getAssociatedObject(request, &retriesCountHandler) as? Int) ?? 0
        
        guard retryCount < self.retryCount else {
            return nil
        }
        
        objc_setAssociatedObject(request, &retriesCountHandler, retryCount + 1, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return request
        
//        let pastRequestKey: String
//        
//        if let objectRequest = request as? Any {
//            pastRequestKey = requests.first(where: { ($0.value.object as? Any) === request })?.key ?? UUID().uuidString
//        }
//        
//        
//        let atemptsCount = atempts[pastRequestKey] ?? 0
//        
//        if atemptsCount < retryCount {
//            atempts[pastRequestKey] = atemptsCount + 1
//            requests[pastRequestKey] = WeakRequest(request)
//            
//            return request
//        }
//        else {
//            return nil
//        }
    }
}
