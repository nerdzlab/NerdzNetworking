//
//  RequestHeadersContainer.swift
//  Networking
//
//  Created by new user on 14.06.2020.
//

import Foundation

public extension Dictionary where Key == RequestHeaderKey, Value == String {
    
    var contentType: MimeType? {
        get {
            if let value = self[.contentType] {
                return MimeType(value)
            }
            
            return nil
        }
        
        set {
            if let type = newValue {
                self[.contentType] = String(type) 
            }
            else {
                removeValue(forKey: .contentType)
            }
        }
    }
    
    var accept: MimeType? {
        get {
            if let value = self[.accept] {
                return MimeType(value)
            }
            
            return nil
        }
        
        set {
            if let type = newValue {
                self[.accept] = String(type) 
            }
            else {
                removeValue(forKey: .accept)
            }
        }
    }
    
    var authToken: AuthToken? {
        get {
            if let value = self[.authorization] {
                return AuthToken(value)
            }
            
            return nil
        }
        
        set {
            if let token = newValue {
                self[.authorization] = String(token)
            }
            else {
                removeValue(forKey: .authorization)
            }
        }
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        
        for (key, value) in rhs {
            result[key] = value
        }
        
        return result
    }
}
