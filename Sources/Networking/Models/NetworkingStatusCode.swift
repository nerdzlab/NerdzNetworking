//
//  StatusCode.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct NetworkingStatusCode {
    public static let unknown = NetworkingStatusCode(-1)

    public let code: Int

    init(_ code: Int) {
        self.code = code
    }

    public var isSuccessful: Bool {
        return isInRange(200...299)
    }

    public var isNotFound: Bool {
        return code == 404
    }

    public var isUnauthorize: Bool {
        return code == 401
    }
    
    private func isInRange(_ range: ClosedRange<Int>) -> Bool {
        return range.contains(code)
    }
}
