//
//  String.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension String: ResponseObject {
    public static var mapper: BaseObjectMapper<Self> {
        return CustomObjectMapper(
            jsonClosure: { json -> Self? in
                guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
                    return nil
                }
                
                return String(data: data, encoding: .utf8)
        }, 
            dataClosure: { data -> Self? in
                String(data: data, encoding: .utf8)
        })
    }
}
