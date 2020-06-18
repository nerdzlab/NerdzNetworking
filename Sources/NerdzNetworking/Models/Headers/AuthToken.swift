//
//  AuthToken.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public enum AuthToken: Equatable {
    private enum Constants {
        static let bearerPrefix = "Bearer"
        static let basicPrefix = "Basic"
    }
    
    case bearer(_ token: String)
    case basic(username: String, password: String)
    case custom(_ string: String)

    public var value: String {
        switch self {
        case .bearer(let token): 
            return "\(Constants.bearerPrefix) \(token)"
            
        case .basic(let username, let password): 
            return "\(Constants.basicPrefix) \(username):\(password)"
                .data(using: String.Encoding.utf8)?
                .base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) ?? ""
            
        case .custom(let string): 
            return string
            
        }
    }

    public init?(_ value: String) {
        let components = value.split(separator: " ").map({ String($0) })
        
        if components.count == 2 {
            if components.first == Constants.bearerPrefix {
                self = .bearer(components[1])
            }
            else if components.first == Constants.basicPrefix {
                guard let data = Data(base64Encoded: components[1], options: Data.Base64DecodingOptions(rawValue: 0)) else {
                    self = .custom(value)
                    return
                }

                guard let string = String(data: data as Data, encoding: String.Encoding.utf8) else {
                    self = .custom(value)
                    return
                } 
                
                let basicComponents = string.split(separator: ":").map({ String($0) })
                
                guard basicComponents.count == 2 else {
                    self = .custom(value)
                    return
                }
                
                self = .basic(username: basicComponents[0], password: basicComponents[1])
            }
            else {
                self = .custom(value)
            }
        }
        else {
            self = .custom(value)
        }
    }

    public static func ==(left: AuthToken, right: AuthToken) -> Bool {
        return left.value == right.value
    }
}

public extension String {
    init(_ token: AuthToken) {
        self.init(token.value)
    }
}
