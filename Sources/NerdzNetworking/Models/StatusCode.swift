//
//  StatusCode.swift
//  Networking
//
//  Created by new user on 25.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public enum StatusCode: Int {
    case unknown = -1
    
    case `continue` = 100
    case switchingProtocol = 101
    case processing = 102
    case earlyHints = 103
    
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritative = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case imUsed = 226
    
    case multipleChoice = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case noteModified = 304
    case useProxy = 305
    case switchProxy = 306
    case temporaryRedirect = 307
    case permanentRedirect = 308
    
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case payloadTooLarge = 413
    case uriTooLong = 414
    case unsupportedMediaType = 415
    case rangeNotSatisfiable = 416
    case expectationFailed = 417
    case misdirectedRequest = 421
    case unprocessableEntity = 422
    case locked = 423
    case failedDependency = 424
    case tooEasy = 425
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431
    case unavailableForLargeReasons = 451
    
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case notExtended = 510
    case networkAuthenticationRequired = 511

    public var code: Int {
        rawValue
    }

    init(_ code: Int) {
        self = StatusCode(rawValue: code) ?? .unknown
    }

    public var isInformational: Bool {
        return isInRange(100...199)
    }
    
    public var isSuccessful: Bool {
        return isInRange(200...299)
    }
    
    public var isRedirection: Bool {
        return isInRange(300...399)
    }
    
    public var isClientError: Bool {
        return isInRange(400...499)
    }
    
    public var isServerError: Bool {
        return isInRange(500...599)
    }
    
    private func isInRange(_ range: ClosedRange<Int>) -> Bool {
        return range.contains(code)
    }
}
