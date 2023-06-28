//
//  NetworkingDefaultRequestType.swift
//  Networking
//
//  Created by new user on 16.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public class DefaultRequest<Response: Decodable, Error: ServerError>: DefaultRequestData, Request {
    public typealias ResponseObjectType = Response
    public typealias ErrorType = Error
    
    public var decoder: JSONDecoder?
    public var endpoint: Endpoint?
    
    public var responseConverter: ResponseJsonConverter?
    public var errorConverter: ResponseJsonConverter?
    
    public init(
        path: String, 
        method: HTTPMethod, 
        queryParams: [(String, String)] = [], 
        body: RequestBody? = nil, 
        headers: [RequestHeaderKey: String] = [:], 
        timeout: TimeInterval? = nil,
        responseConverter: ResponseJsonConverter? = nil,
        errorConverter: ResponseJsonConverter? = nil,
        endpoint: Endpoint? = nil,
        decoder: JSONDecoder? = nil
    )
    {
        super.init(
            path: path, 
            method: method, 
            queryParams: queryParams, 
            body: body, 
            headers: headers, 
            timeout: timeout
        )
        
        self.responseConverter = responseConverter
        self.errorConverter = errorConverter
        self.endpoint = endpoint
        self.decoder = decoder
    }
    
    public convenience init?(
        url: URL, 
        method: HTTPMethod = .get,
        body: RequestBody? = nil, 
        headers: [RequestHeaderKey: String] = [:], 
        timeout: TimeInterval? = nil,
        responseConverter: ResponseJsonConverter? = nil,
        errorConverter: ResponseJsonConverter? = nil,
        endpoint: Endpoint? = nil,
        decoder: JSONDecoder? = nil
    ) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let queryParams: [(String, String)] = components.queryItems?.reduce(into: []) {
            guard let value = $1.value else {
                return
            }
            
            $0.append(($1.name, value))
        } ?? []
        
        self.init(
            path: components.path, 
            method: method, 
            queryParams: queryParams,
            body: body,
            headers: headers,
            timeout: timeout,
            responseConverter: responseConverter,
            errorConverter: errorConverter,
            endpoint: endpoint,
            decoder: decoder
        )
    }
}
