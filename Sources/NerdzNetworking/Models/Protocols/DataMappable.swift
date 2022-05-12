//
//  File.swift
//  
//
//  Created by new user on 12.05.2022.
//

import Foundation

public protocol DataMappable {
    static func object(from data: Data) -> Self?
}
