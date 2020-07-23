//
//  Optional.swift
//  Networking
//
//  Created by new user on 06.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Optional: ResponseObject where Wrapped: ResponseObject {
    public static var mapper: BaseObjectMapper<Self> {
        return CustomObjectMapper(
            jsonClosure: { json throws -> Self in
                try Wrapped.mapper.mapJson(json)
        }, 
            dataClosure: { data throws -> Self in
                try Wrapped.mapper.mapData(data)
        })
    }
}
