//
//  Empty.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct Empty: ResponseObject {
    
    public static var mapper: BaseObjectMapper<Empty> {
        return CustomObjectMapper(
            jsonClosure: { _ in Empty() }, 
            dataClosure: { _ in Empty() }
        )
    }
}
