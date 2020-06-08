//
//  MultipartResourceConvertable.swift
//  Networking
//
//  Created by new user on 07.06.2020.
//

import Foundation

public protocol MultipartResourceConvertable {
    var resourceName: String { get }
    var stream: InputStream? { get }
}
