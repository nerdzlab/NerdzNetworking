//
//  MultipartFormDataRequestData.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public protocol MultipartRequestData: RequestData {
    var files: [MultipartFile] { get }
}

public protocol MultipartFile {
    var resource: MultipartResourceConvertable { get }
    var mime: MimeType { get }
    var name: String { get }
    var fileName: String { get }
}

public extension MultipartFile {
    var fileName: String {
        name
    }
}
