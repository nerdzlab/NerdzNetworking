//
//  NetworkingResponseConverter.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public protocol ResponseJsonConverter {
    func convertedJson(from json: Any) throws -> Any
}

extension ResponseJsonConverter {
    func convertedData(from data: Data) throws -> Data {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        let finalJson = try convertedJson(from: json)
        return try JSONSerialization.data(withJSONObject: finalJson, options: [])
    }
}
