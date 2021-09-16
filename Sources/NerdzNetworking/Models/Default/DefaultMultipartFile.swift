//
//  NetworkingDefaultMultipartFile.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct DefaultMultipartFile: MultipartFile {
    public var resource: MultipartResourceConvertable
    public var mime: MimeType
    public var name: String
    public var fileName: String
    
    public init(resource: MultipartResourceConvertable, mime: MimeType, name: String, fileName: String? = nil) {
        self.resource = resource
        self.mime = mime
        self.name = name
        self.fileName = fileName ?? name
    }
}
