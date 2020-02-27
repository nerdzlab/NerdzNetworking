//
//  NetworkingRequestFactory.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class NetworkingRequestFactory {
    enum InternalError: Error {
        case unsiutableMultipartParameters
        case invalidUrl
        case noBaseUrl
        
        var localizedDescription: String {
            switch self {
            case .noBaseUrl: return "No base url provided to create a request"
            case .invalidUrl: return "URL is invalid"
            case .unsiutableMultipartParameters: return "Requst parameters for multipart request are invalid"
            }
        }
    }
    
    let baseUrl: URL?
    
    var tokenHeader: AuthToken?
    var contentType: MimeType = .applicationJson
    var accept: MimeType = .applicationJson
    var headers: [NetworkingHeader] = []

    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }
    
    func request(from requestData: NetworkingRequestData) throws -> URLRequest {
        guard let baseUrl = baseUrl else {
            throw InternalError.noBaseUrl
        }
        
        let urlString = baseUrl.absoluteString + requestData.path

        guard let url = URL(string: urlString)?.withAdded(requestData.queryParams) else {
            throw InternalError.invalidUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestData.method.rawValue
        setHeaders(for: &urlRequest, wuth: requestData)
        
        if let timeout = requestData.timeout {
            urlRequest.timeoutInterval = timeout
        }
        
        if let data = requestData as? NetworkingMultipartRequestData, let streamData = data.streamData {
            urlRequest.setHeader(ContentHeader.contenType(.multipart, boundary: streamData.boundary))
            urlRequest.httpBodyStream = streamData.stream
        }
        else if !requestData.bodyParams.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestData.bodyParams, options: [])
        }

        return urlRequest
    }

    func updateHeader(_ header: NetworkingHeader) {
        if let index = headers.firstIndex(where: { $0.key == header.key }) {
            headers[index] = header
        }
    }
    
    private func setHeaders(for request: inout URLRequest, wuth data: NetworkingRequestData) {
        
        for header in headers {
            request.setHeader(header)
        }
        
        request.setHeader(ContentHeader.contenType(contentType))
        request.setHeader(ContentHeader.accept(accept))
        
        if let token = tokenHeader {
            request.setHeader(token)
        }
        
        for header in data.headers {
            request.setHeader(header)
        }
    }
}

private extension URLRequest {
    mutating func setHeader( _ header: NetworkingHeader) {
        setValue(header.value, forHTTPHeaderField: header.key)
    }
}

private extension URL {
    func withAdded(_ queryParams: [(key: String, value: String)]) -> URL {
        if var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true), !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            return urlComponents.url ?? self
        }
        else {
            return self
        }
    }
}
