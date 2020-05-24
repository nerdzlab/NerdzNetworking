//
//  Status.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct Status: ResponseObject, Codable {
    
    enum InternalError: Error {
        case unableToMap
        
        var localizedDescription: String {
            switch self {
            case .unableToMap: return "Unable to map status response from given JSON"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case statusCode
        case status
    }

    let statusCode: StatusCode

    init(statusCode: StatusCode) {
        self.statusCode = statusCode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let code = try container.decodeIfPresent(Int.self, forKey: .code) ?? 
            (try container.decodeIfPresent(Int.self, forKey: .statusCode)) ?? 
            (try container.decodeIfPresent(Int.self, forKey: .status))
        
        if let code = code  {
            statusCode = StatusCode(code)
        }
        else {
            throw InternalError.unableToMap
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode.code, forKey: .code)
    }
}
