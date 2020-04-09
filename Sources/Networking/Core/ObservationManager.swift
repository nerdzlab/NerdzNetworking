//
//  NetworkingObservationManager.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public class ObservationManager {
    private var responseObservers: [Any] = []

    func addResponseObserver<T>(onNotify: @escaping (T, T.ResponseObjectType?, ErrorResponse<T.ErrorType>?) -> Void) where T: Request {
        responseObservers.append(ResponseObserver(onNotify: onNotify))
    }

    func sendResponseNotification<T>(request: T, result: T.ResponseObjectType?, error: ErrorResponse<T.ErrorType>?) where T: Request {
        for observer in responseObservers {
            (observer as? ResponseObserver<T>)?.onNotify(request, result, error)
        }
    }
}

private class ResponseObserver<T> where T: Request {
    typealias NotifyClosure = (T, T.ResponseObjectType?, ErrorResponse<T.ErrorType>?) -> Void

    fileprivate let onNotify: NotifyClosure

    init(onNotify: @escaping NotifyClosure) {
        self.onNotify = onNotify
    }
}
