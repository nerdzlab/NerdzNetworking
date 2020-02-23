//
//  Array.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Array: NetworkingResponseObject {
    static func object(from json: Any) -> Self? {
        guard let arrayJson = json as? [Any] else {
            return nil
        }
        
        if let result = arrayJson as? Self {
            return result
        }
        else {
            return arrayJson.map({ (Element.self as? NetworkingResponseObject.Type)?.object(from: $0) as? Element? }) as? Self
        }
    }
}
