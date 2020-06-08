//
//  String+MultipartResourceConvertible.swift
//  Networking
//
//  Created by new user on 07.06.2020.
//

import Foundation

extension String: MultipartResourceConvertable {
    public var resourceName: String {
        URL(string: self)?.lastPathComponent ?? self
    }
    
    public var stream: InputStream? {
        InputStream(fileAtPath: self)
    }
}
