//
//  MimeType.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public enum MimeType {
    case applicationJson
    case applicationXml
    case applicationZip
    case textHtml
    case imagePng
    case imageJpeg
    case multipart
    
    case custom(_ string: String)
    
    public var value: String {
        switch self {
        case .applicationJson: return "application/json"
        case .applicationXml: return "application/xml"
        case .applicationZip: return "application/zip"
        case .textHtml: return "text/html"
        case .imagePng: return "image/png"
        case .imageJpeg: return "image/jpeg"
        case .multipart: return "multipart/form-data"
        case .custom(let string): return string
        }
    }
}
