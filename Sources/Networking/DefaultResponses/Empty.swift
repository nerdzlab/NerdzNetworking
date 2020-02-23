//
//  Empty.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

struct Empty: CodableNetworkingResponseObject {
    
    static func object(from json: Any) -> Empty? {
        return Empty()
    }
    
    static func object(from data: Data) -> Empty? {
        return Empty()
    }
}
