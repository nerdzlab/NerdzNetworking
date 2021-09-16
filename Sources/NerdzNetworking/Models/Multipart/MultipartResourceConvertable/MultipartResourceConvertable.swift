//
//  MultipartResourceConvertable.swift
//  Networking
//
//  Created by new user on 07.06.2020.
//

import Foundation

public protocol MultipartResourceConvertable {
    var stream: InputStream? { get }
    
    var fileName: String? { get }
}

public extension MultipartResourceConvertable {
    var fileName: String? {
        nil
    } 
} 
