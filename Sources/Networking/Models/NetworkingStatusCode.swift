//
//  StatusCode.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

struct NetworkingStatusCode {
    static let unknown = NetworkingStatusCode(-1)

    let code: Int

    init(_ code: Int) {
        self.code = code
    }

    var isSuccessful: Bool {
        return isInRange(200...299)
    }

    var isNotFound: Bool {
        return code == 404
    }

    var isUnauthorize: Bool {
        return code == 401
    }
    
    private func isInRange(_ range: ClosedRange<Int>) -> Bool {
        return range.contains(code)
    }
}
