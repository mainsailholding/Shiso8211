//
//  ISOField.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/17/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

public enum Encoding: Codable {
    case oneByte, twoByteLittle, twoByteBig
    func terminator(_ value: UInt8) -> Data {
        switch self {
        case .oneByte:          return Data([value])
        case .twoByteLittle:    return Data([value, 0x00])
        case .twoByteBig:       return Data([0x00, value])
        }
    }
    var unitTerminator: Data { terminator(ISOModule.DDF_UNIT_TERMINATOR) }
    var fieldTerminator: Data { terminator(ISOModule.DDF_FIELD_TERMINATOR) }
    var width: Int { self == .oneByte ? 1 : 2 }
    static func infer(from data: Data) -> Encoding {
        if data.suffix(2) == Data([0x1E, 0x00]) { return .twoByteLittle }
        else if data.suffix(2) == Data([0x00, 0x1E]) { return .twoByteBig }
        return .oneByte
    }
    static func fromEscape(_ ascii: String) -> Encoding {
        if ascii == "%/A" { return .twoByteBig }
        else { return .oneByte }
    }
}

public class ISOField: Codable {
    public let tag: String
    public let length: Int
    public let position: Int
    
    public var rows: [ISORow] = []
    
    var data: Data? = nil

    init(leader: ISOLeader, ascii: String) {
        var s: Int = 0; var e: Int = leader.sizeFieldTag
        tag = ascii[s..<e]
        s = e; e = s+leader.sizeFieldLength
        length = Int(ascii[s..<e])!
        s = e; e = s+leader.sizeFieldPosition
        position = Int(ascii[s..<e])!
    }
        
    func load(module: ISOModule, data: Data) throws {
        self.data = data
        let fieldDef: ISOFieldDef = module.fieldDef(for: tag)
        var i: Int = 0

//        let encoding: Encoding = (fieldDef.isRepeatable && !fieldDef.isFixedWidth) ? .infer(from: data) : .oneByte
        
        for _: Int in 0..<fieldDef.noOfRows(data: data/*, encoding: encoding*/) {
            let row: ISORow = ISORow()
            for subfieldDef: ISOSubfieldDef in fieldDef.subfieldDefs {
                let value: ISOValue = ISOValue(name: subfieldDef.tag)
                i += try subfieldDef.load(from: data[(data.startIndex+i)...], into: value, encoding: fieldDef.encoding)
                row.values.append(value)
            }
            rows.append(row)
        }
    }
}
