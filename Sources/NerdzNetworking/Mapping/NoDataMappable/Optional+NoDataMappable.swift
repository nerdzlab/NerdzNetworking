//
//  File.swift
//  
//
//  Created by new user on 29.01.2022.
//

import Foundation

extension Optional: NoDataMappable {
    
    public static func noDataObject() -> Optional<Wrapped> {
        nil
    }
    
}
