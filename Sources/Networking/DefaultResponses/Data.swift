//
//  Data.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Data: NetworkingResponseObject {
    public static func object(from json: Any) -> Data? {
        return try? JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    public static func object(from data: Data) -> Data? {
        return data
    }
}
