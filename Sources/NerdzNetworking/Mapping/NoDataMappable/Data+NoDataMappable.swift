//
//  File.swift
//  
//
//  Created by new user on 29.01.2022.
//

import Foundation

extension Data: NoDataMappable {
    public static func noDataObject() -> Data {
        Data()
    }
}
