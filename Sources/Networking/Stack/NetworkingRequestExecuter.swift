//
//  NetworkingRequestExecuter.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class NetworkingRequestExecuter {
    enum InternaError: Error {
        case unableToMap
        
        var localizedDescription: String {
            switch self {
            case .unableToMap: return "Unable to map response from server into expected data"
            }
        }
    }
    
    let dispatcher: NetworkingURLSessionNetworkDispatcher
    let observationManager: NetworkingObservationManager

    var requestRetries: [RequestRetrier] = []

    init(dispatcher: NetworkingURLSessionNetworkDispatcher, observationManager: NetworkingObservationManager) {
        self.dispatcher = dispatcher
        self.observationManager = observationManager
    }

    func execute<T: NetworkingRequestType>(
        _ request: T, 
        responseQueue   : DispatchQueue = .main, 
        retryOnFail     : Bool = true, 
        onSuccess       : ((T.ResponseObjectType) -> Void)? = nil, 
        onError         : ((NetworkingError<T.ErrorType>) -> Void)? = nil,
        onProgress      : ((Double) -> Void)? = nil,
        onDebug         : ((NetworkingDebugInfo) -> Void)? = nil) throws 
        
        -> NetworkingRequestOperation 
    {
        return try dispatcher.dispatch(request.data,

                            onSuccess: { [weak self] (data, statusCode) in
                                guard let strongSelf = self else {
                                    return
                                }
                                
                                do {
                                    let statusCode = NetworkingStatusCode(statusCode)


                                    if statusCode.isSuccessful {
                                        if let result = try T.ResponseObjectType.object(from: data, jsonConverter: request.responseConverter) {
                                            strongSelf.callSuccess(
                                                for: request, 
                                                on: responseQueue, 
                                                with: result, 
                                                onSuccess: onSuccess)
                                            
                                        }
                                        else {
                                            strongSelf.callError(
                                                for: request, 
                                                on: responseQueue, 
                                                with: .system(InternaError.unableToMap), 
                                                onError: onError)
                                        }
                                    }
                                    else {
                                        
                                        if let result = try T.ErrorType.object(from: data, jsonConverter: request.errorConverter) {
                                            let error: NetworkingError<T.ErrorType> = .custom(result, statusCode: statusCode)

                                            if retryOnFail {
                                                strongSelf.retry(
                                                    with: error, 
                                                    for: request, 
                                                    responseQueue: responseQueue, 
                                                    onSuccess: onSuccess, 
                                                    onError: onError)
                                            }
                                            else {
                                                strongSelf.callError(
                                                    for: request, 
                                                    on: responseQueue, 
                                                    with: error, 
                                                    onError: onError)
                                            }

                                        }
                                        else {
                                            strongSelf.callError(
                                            for: request, 
                                            on: responseQueue, 
                                            with: .system(InternaError.unableToMap), 
                                            onError: onError)
                                        }
                                    }
                                }
                                catch {
                                    strongSelf.callError(
                                    for: request, 
                                    on: responseQueue, 
                                    with: .system(error), 
                                    onError: onError)
                                }
        },

                            onError: { [weak self] in

                                let error: NetworkingError<T.ErrorType> = .system($0)

                                if retryOnFail {
                                    self?.retry(
                                        with: error, 
                                        for: request, 
                                        responseQueue: responseQueue, 
                                        onSuccess: onSuccess, 
                                        onError: onError)
                                }
                                else {
                                    self?.callError(
                                        for: request, 
                                        on: responseQueue, 
                                        with: error, 
                                        onError: onError)
                                }
        },
                            onProgress: onProgress,
                            onDebug: onDebug)
    }

    private func callSuccess<T: NetworkingRequestType>(for request: T, on responseQueue: DispatchQueue, with result: T.ResponseObjectType, onSuccess: ((T.ResponseObjectType) -> Void)?) {

        responseQueue.async { onSuccess?(result) }

        observationManager.sendResponseNotification(
            request: request, 
            result: result, 
            error: nil)
    }

    private func callError<T: NetworkingRequestType>(for request: T, on responseQueue: DispatchQueue, with error: NetworkingError<T.ErrorType>, onError: ((NetworkingError<T.ErrorType>) -> Void)?) {

        responseQueue.async { onError?(error) }

        observationManager.sendResponseNotification(
            request: request, 
            result: nil, 
            error: error)
    }

    private func retry<T: NetworkingRequestType>(with error: NetworkingError<T.ErrorType>, for request: T, responseQueue: DispatchQueue, onSuccess: ((T.ResponseObjectType) -> Void)? = nil, onError: ((NetworkingError<T.ErrorType>) -> Void)? = nil) {

        for retrier in requestRetries {
            let handled = retrier.handle(error, for: request) { [weak self] newRequest in
                let _ = try? self?.execute(newRequest, 
                    responseQueue: responseQueue, 
                    retryOnFail: false, 
                    onSuccess: onSuccess, 
                    onError: onError)
            }

            if handled {
                return
            }
        }

        callError(
            for: request, 
            on: responseQueue, 
            with: error, 
            onError: onError)
    }
}
