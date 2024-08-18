//
//  NetworkingErrors.swift
//  Networking
//
//  Created by Vasyl Khmil on 22.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation
import FileProvider

public enum ErrorResponse<T: ServerError>: LocalizedError {
    case server(_ error: T, statusCode: StatusCode)
    case decoding(_ error: DescriptiveDecodingError)
    case system(_ error: Error)

    public var errorDescription: String? {
        switch self {
        case .system(let error): 
            return error.localizedDescription
            
        case .decoding(let error):
            return error.localizedDescription
            
        case .server(let error, _): 
            return error.message
        }
    }
}
