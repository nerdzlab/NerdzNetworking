//
//  InputStream+MultipartResourceConvertible.swift
//  Networking
//
//  Created by new user on 07.06.2020.
//

import Foundation

extension InputStream: MultipartResourceConvertable {
    public var resourceName: String {
        "file"
    }
    
    public var stream: InputStream? {
        self
    }
}
