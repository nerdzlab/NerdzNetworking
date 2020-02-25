//
//  Optional.swift
//  Networking
//
//  Created by new user on 06.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Optional: NetworkingResponseObject where Wrapped: NetworkingResponseObject {
    public static func object(from json: Any) -> Optional<Wrapped>? {
        if let result = Wrapped.object(from: json) {
            return .some(result)
        }
        else {
            return .none
        }
    }
}
