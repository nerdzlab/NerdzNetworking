//
//  File.swift
//  
//
//  Created by new user on 01.10.2022.
//

import Foundation

public protocol TokenContainer {
    var token: AuthToken? { get }
    var refreshToken: String? { get }
}
