//
//  ISOField.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/17/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

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
        
    func load(module: ISOModule, data: Data) {
        self.data = data
        let fieldDef: ISOFieldDef = module.fieldDef(for: tag)
        var i: Int = 0
        
        for _: Int in 0..<fieldDef.noOfRows(data: data) {
            let row: ISORow = ISORow()
            for subfieldDef: ISOSubfieldDef in fieldDef.subfieldDefs {
                let value: ISOValue = ISOValue(name: subfieldDef.tag)
                i += subfieldDef.load(from: data[(data.startIndex+i)...], into: value)
                row.values.append(value)
            }
            rows.append(row)
        }
    }
}
