//
//  Data+MultipartResourceConvertable.swift
//  Networking
//
//  Created by new user on 07.06.2020.
//

import Foundation

extension Data: MultipartResourceConvertable {
    public var resourceName: String {
        "file_\(hashValue)"
    }
    
    public var stream: InputStream? {
        InputStream(data: self)
    }
}
