//
//  AEValue.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/17/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

public class ISOValue: Codable {
    public var name: String

    public var int8: Int8?
    public var int16: Int16?
    public var int32: Int32?
    public var uInt8: UInt8?
    public var uInt16: UInt16?
    public var uInt32: UInt32?
    public var float: Float?
    public var double: Double?
    public var string: String?
    public var binary: [UInt8]?
    
    public init(name: String) {
        self.name = name
    }
    
    public var uInt: UInt? {
        if let uInt8 { return UInt(uInt8) }
        if let uInt16 { return UInt(uInt16) }
        if let uInt32 { return UInt(uInt32) }
        return nil
    }
    public var int: Int? {
        if let int8 { return Int(int8) }
        if let int16 { return Int(int16) }
        if let int32 { return Int(int32) }
        return nil
    }
    public var real: Double?  {
        if let float { return Double(float) }
        if let double { return double }
        return nil
    }
}
