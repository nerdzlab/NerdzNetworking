//
//  Empty.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct Empty: CodableNetworkingResponseObject {
    
    public static func object(from json: Any) -> Empty? {
        return Empty()
    }
    
    public static func object(from data: Data) -> Empty? {
        return Empty()
    }
}
