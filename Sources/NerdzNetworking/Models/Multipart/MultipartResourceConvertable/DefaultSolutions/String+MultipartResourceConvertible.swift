//
//  String+MultipartResourceConvertible.swift
//  Networking
//
//  Created by new user on 07.06.2020.
//

import Foundation

extension String: MultipartResourceConvertable {
    public var fileName: String? {
        URL(string: self)?.lastPathComponent
    }
    
    public var stream: InputStream? {
        InputStream(fileAtPath: self)
    }
}
