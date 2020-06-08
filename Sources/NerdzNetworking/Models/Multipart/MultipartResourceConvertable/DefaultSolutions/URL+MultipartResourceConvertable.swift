//
//  URL+MultipartResourceConvertable.swift
//  Networking
//
//  Created by new user on 07.06.2020.
//

import Foundation

extension URL: MultipartResourceConvertable {
    public var resourceName: String {
        lastPathComponent
    }
    
    public var stream: InputStream? {
        InputStream(url: self)
    }
}
