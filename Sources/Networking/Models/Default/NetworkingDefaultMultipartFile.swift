//
//  NetworkingDefaultMultipartFile.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

struct NetworkingDefaultMultipartFile: NetworkingMultipartFile {
    var subject: NetworkingMultipartaSubject
    var mime: MimeType
    var fileName: String?
    
    init(subject: NetworkingMultipartaSubject, mime: MimeType, fileName: String? = nil) {
        self.subject = subject
        self.mime = mime
        self.fileName = fileName
    }
}
