//
//  NetworkingDefaultMultipartFile.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct NetworkingDefaultMultipartFile: NetworkingMultipartFile {
    public var subject: NetworkingMultipartaSubject
    public var mime: MimeType
    public var fileName: String?
    
    init(subject: NetworkingMultipartaSubject, mime: MimeType, fileName: String? = nil) {
        self.subject = subject
        self.mime = mime
        self.fileName = fileName
    }
}
