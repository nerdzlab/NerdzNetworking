//
//  Dictionary.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Dictionary: NetworkingResponseObject where Key == String {
    public static func object(from json: Any) -> Dictionary<Key, Value>? {
        return json as? Dictionary<Key, Value>
    }
}
