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
    var subject: MultipartaSubject { get }
    var mime: MimeType { get }
    var fileName: String? { get }
}

public extension MultipartFile {
    var fileName: String? {
        return nil
    }
}

public enum MultipartaSubject {
    case data(_ data: Data, resourceName: String? = nil)
    case url(_ url: URL)
    case path(_ path: String)
    
    var resourceName: String? {
        switch self {
        case .url(let url): return url.lastPathComponent
        case .path(let path): return URL(fileURLWithPath: path).lastPathComponent
        case .data(_, let resourceName): return resourceName
        }
    }
    
    var stream: InputStream? {
        switch self {
        case .data(let data, _): return InputStream(data: data)
        case .url(let url): return InputStream(url: url)
        case .path(let path): return InputStream(fileAtPath: path)
        }
    }
}
