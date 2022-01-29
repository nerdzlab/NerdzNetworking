//
//  File.swift
//  
//
//  Created by new user on 29.01.2022.
//

import Foundation

extension Empty: NoDataMappable {
    public static func noDataObject() -> Self {
        Empty()
    }
}
