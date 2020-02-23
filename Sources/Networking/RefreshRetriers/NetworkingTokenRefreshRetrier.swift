//
//  NetworkingTokenRefreshRetrier.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class NetworkingTokenRefreshRetrier: RequestRetrier {
    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    @discardableResult
    func handle<T>(_ error: NetworkingError<T.ErrorType>, for request: T, completion: @escaping (T) -> Void) -> Bool where T: NetworkingRequestType {
        guard case .custom(_, let statusCode) = error, statusCode.isUnauthorize else {
            return false
        }

        return authManager.refreshToken { _ in
            completion(request)
        }
    }
}
