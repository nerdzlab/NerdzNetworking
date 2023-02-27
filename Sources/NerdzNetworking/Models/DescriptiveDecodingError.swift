//
//  File.swift
//  
//
//  Created by Vasyl Khmil on 27.02.2023.
//

import Foundation

public enum DescriptiveDecodingError: Error, CustomStringConvertible {
    
    case dataCorrupted(_ message: String)
    case keyNotFound(_ message: String)
    case typeMismatch(_ message: String)
    case valueNotFound(_ message: String)
    case unableToMap(_ type: String)
    case any(_ error: Error)
    
    public var description: String {
        switch self {
        case let .dataCorrupted(message),
            let .keyNotFound(message),
            let .typeMismatch(message),
            let .valueNotFound(message):
            return message
            
        case .unableToMap(let type): 
            return "Unable to map \(type)"
            
        case let .any(error):
            return error.localizedDescription
        }
    }
    
    init(_ error: Error) {
        guard let decodingError = error as? DecodingError else {
            self = .any(error)
            return
        }
        
        switch decodingError {
        case let .dataCorrupted(context):
            let debugDescription = (context.underlyingError as NSError?)?.userInfo["NSDebugDescription"] ?? ""
            self = .dataCorrupted("Data corrupted. \(context.debugDescription) \(debugDescription)")
            
        case let .keyNotFound(key, context):
            self = .keyNotFound("Key not found. Expected -> \(key.stringValue) <- at: \(context.prettyPath())")
            
        case let .typeMismatch(_, context):
            self = .typeMismatch("Type mismatch. \(context.debugDescription), at: \(context.prettyPath())")
            
        case let .valueNotFound(_, context):
            self = .valueNotFound("Value not found. -> \(context.prettyPath()) <- \(context.debugDescription)")
            
        @unknown default:
            self = .any(error)
        }
    }
}

extension DecodingError.Context {
    func prettyPath(separatedBy separator: String = ".") -> String {
        codingPath.map { $0.stringValue }.joined(separator: ".")
    }
}
