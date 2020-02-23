//
//  MultipartFormDataRequestData.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

protocol NetworkingMultipartRequestData: NetworkingRequestData {
    var files: [NetworkingMultipartFile] { get }
}

protocol NetworkingMultipartFile {
    var subject: NetworkingMultipartaSubject { get }
    var mime: MimeType { get }
    var fileName: String? { get }
}

extension NetworkingMultipartFile {
    var fileName: String? {
        return nil
    }
}

enum NetworkingMultipartaSubject {
    case data(_ data: Data)
    case url(_ url: URL)
    case path(_ path: String)
    
    var stream: InputStream? {
        switch self {
        case .data(let data): return InputStream(data: data)
        case .url(let url): return InputStream(url: url)
        case .path(let path): return InputStream(fileAtPath: path)
        }
    }
}
