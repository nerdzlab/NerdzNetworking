//
//  String.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension String: NetworkingResponseObject {
    static func object(from json: Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    } 
    
    static func object(from data: Data) -> String? {
        return String(data: data, encoding: .utf8)
    }
}
