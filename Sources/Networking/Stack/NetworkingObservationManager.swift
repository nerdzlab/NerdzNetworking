//
//  NetworkingObservationManager.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public class NetworkingObservationManager {
    private var responseObservers: [Any] = []

    func addNetworkingResponseObserver<T>(onNotify: @escaping (T, T.ResponseObjectType?, NetworkingError<T.ErrorType>?) -> Void) where T: NetworkingRequestType {
        responseObservers.append(NetworkingResponseObserver(onNotify: onNotify))
    }

    func sendResponseNotification<T>(request: T, result: T.ResponseObjectType?, error: NetworkingError<T.ErrorType>?) where T: NetworkingRequestType {
        for observer in responseObservers {
            (observer as? NetworkingResponseObserver<T>)?.onNotify(request, result, error)
        }
    }
}

private class NetworkingResponseObserver<T> where T: NetworkingRequestType {
    typealias NotifyClosure = (T, T.ResponseObjectType?, NetworkingError<T.ErrorType>?) -> Void

    fileprivate let onNotify: NotifyClosure

    init(onNotify: @escaping NotifyClosure) {
        self.onNotify = onNotify
    }
}
