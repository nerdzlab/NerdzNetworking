//
//  RequestHeaderKey.swift
//  Networking
//
//  Created by new user on 14.06.2020.
//

import Foundation

public struct RequestHeaderKey {
    public let string: String
    
    public init(_ string: String) {
        self.string = string
    }
    
    public static let accept = RequestHeaderKey("Accept")
    public static let acceptCharset = RequestHeaderKey("Accept-Charset")
    public static let acceptEncoding = RequestHeaderKey("Accept-Encoding")
    public static let acceptLanguage = RequestHeaderKey("Accept-Language")
    public static let acceptRanges = RequestHeaderKey("Accept-Ranges")
    public static let age = RequestHeaderKey("Age")
    public static let allow = RequestHeaderKey("Allow")
    public static let alternates = RequestHeaderKey("Alternates")
    public static let cacheControl = RequestHeaderKey("Cache-Control")
    public static let connection = RequestHeaderKey("Connection")
    public static let contentDisposition = RequestHeaderKey("Content-Disposition")
    public static let contentEncoding = RequestHeaderKey("Content-Encoding")
    public static let contentLength = RequestHeaderKey("Content-Length")
    public static let contentLocation = RequestHeaderKey("Content-Location")
    public static let contentRange = RequestHeaderKey("Content-Range")
    public static let contentType = RequestHeaderKey("Content-Type")
    public static let contentVersion = RequestHeaderKey("Content-Version")
    public static let date = RequestHeaderKey("Date")
    public static let derivedFrom = RequestHeaderKey("Derived-From")
    public static let eTag = RequestHeaderKey("ETag")
    public static let expect = RequestHeaderKey("Expect")
    public static let expires = RequestHeaderKey("Expires")
    public static let from = RequestHeaderKey("From")
    public static let host = RequestHeaderKey("Host")
    public static let ifMatch = RequestHeaderKey("If-Match")
    public static let ifModifiedSince = RequestHeaderKey("If-Modified-Since")
    public static let ifNoneMatch = RequestHeaderKey("If-None-Match")
    public static let ifRange = RequestHeaderKey("If-Range")
    public static let ifUnmodifiedSince = RequestHeaderKey("If-Unmodified-Since")
    public static let lastModified = RequestHeaderKey("Last-Modified")
    public static let link = RequestHeaderKey("Link")
    public static let location = RequestHeaderKey("Location")
    public static let maxForwards = RequestHeaderKey("Max-Forwards")
    public static let mimeVersion = RequestHeaderKey("MIME-Version")
    public static let pragma = RequestHeaderKey("Pragma")
    public static let proxyAuthenticate = RequestHeaderKey("Proxy-Authenticate")
    public static let proxyAuthorization = RequestHeaderKey("Proxy-Authorization")
    public static let `public` = RequestHeaderKey("Public")
    public static let range = RequestHeaderKey("Range")
    public static let referer = RequestHeaderKey("Referer")
    public static let retryAfter = RequestHeaderKey("Retry-After")
    public static let server = RequestHeaderKey("Server")
    public static let title = RequestHeaderKey("Title")
    public static let te = RequestHeaderKey("TE")
    public static let trailer = RequestHeaderKey("Trailer")
    public static let transferEncoding = RequestHeaderKey("Transfer-Encoding")
    public static let upgrade = RequestHeaderKey("Upgrade")
    public static let userAgent = RequestHeaderKey("User-Agent")
    public static let vary = RequestHeaderKey("Vary")
    public static let via = RequestHeaderKey("Via")
    public static let warning = RequestHeaderKey("Warning")
    public static let wwwAuthenticate = RequestHeaderKey("WWW-Authenticate")
    public static let authorization = RequestHeaderKey("Authorization")
}

extension RequestHeaderKey: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.string == rhs.string
    }
}

public extension String {
    init(_ key: RequestHeaderKey) {
        self.init(key.string)
    }
}
