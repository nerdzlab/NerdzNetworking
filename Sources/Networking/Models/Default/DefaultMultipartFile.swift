//
//  NetworkingDefaultMultipartFile.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct DefaultMultipartFile: MultipartFile {
    public var subject: MultipartaSubject
    public var mime: MimeType
    public var fileName: String?
    
    init(subject: MultipartaSubject, mime: MimeType, fileName: String? = nil) {
        self.subject = subject
        self.mime = mime
        self.fileName = fileName
    }
}
