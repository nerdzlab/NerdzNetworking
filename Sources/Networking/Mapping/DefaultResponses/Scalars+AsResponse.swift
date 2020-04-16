//
//  Scalars+AsResponse.swift
//  NetworkingTEsting
//
//  Created by new user on 16.04.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension Int: ResponseObject { }
extension Int8: ResponseObject { }
extension Int16: ResponseObject { }
extension Int32: ResponseObject { }
extension Int64: ResponseObject { }

extension UInt: ResponseObject { }
extension UInt8: ResponseObject { }
extension UInt16: ResponseObject { }
extension UInt32: ResponseObject { }
extension UInt64: ResponseObject { }

extension Float: ResponseObject { }
extension Double: ResponseObject { }
extension Bool: ResponseObject { }
extension Data: ResponseObject { }
