//
//  NetworkingRequestFactory.swift
//  Networking
//
//  Created by Vasyl Khmil on 21.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

class RequestFactory {
    private enum RequestFactoryError: Error {
        case unsiutableMultipartParameters
        case invalidUrl
        case noBaseUrl
        
        var localizedDescription: String {
            switch self {
            case .noBaseUrl: 
                return "No base url provided to create a request"
                
            case .invalidUrl: 
                return "URL is invalid"
                
            case .unsiutableMultipartParameters: 
                return "Requst parameters for multipart request are invalid"
            }
        }
    }
    
    let baseUrl: URL?
    
    var headers: [RequestHeaderKey: String] = [:]

    init(baseUrl: URL, headers: [RequestHeaderKey: String] = [:]) {
        self.baseUrl = baseUrl
        self.headers = headers
    }
    
    func request(from requestData: RequestData) throws -> URLRequest {
        guard let baseUrl = baseUrl else {
            throw RequestFactoryError.noBaseUrl
        }
        
        let urlString = baseUrl.absoluteString + requestData.path

        guard let url = URL(string: urlString)?.withAdded(requestData.queryParams) else {
            throw RequestFactoryError.invalidUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestData.method.rawValue
        setHeaders(for: &urlRequest, wuth: requestData)
        
        if let timeout = requestData.timeout {
            urlRequest.timeoutInterval = timeout
        }
        
        if let data = requestData as? MultipartRequestData, let streamData = data.streamData {
            let mime: MimeType = .multipart(.form_data, parameters: ["boundary": streamData.boundary])
            urlRequest.setHeader(.contentType, with: mime.value)
            urlRequest.httpBodyStream = streamData.stream
        }
        else {
            urlRequest.httpBody = try requestData.body?.generateBodyData()
        }

        return urlRequest
    }
    
    private func setHeaders(for request: inout URLRequest, wuth data: RequestData) {
        for (header, value) in (headers + data.headers) {
            request.setHeader(header, with: value)
        }
    }
}

private extension URLRequest {
    mutating func setHeader( _ header: RequestHeaderKey, with value: String) {
        setValue(value, forHTTPHeaderField: header.string)
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
