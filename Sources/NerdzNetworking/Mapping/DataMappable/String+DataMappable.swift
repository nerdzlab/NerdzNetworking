//
//  File.swift
//  
//
//  Created by new user on 12.05.2022.
//

import Foundation

extension String: DataMappable {
    
    public static func object(from data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }
}
