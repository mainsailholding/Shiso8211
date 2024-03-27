//
//  ISOField.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/16/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

public class ISOFieldDef: Codable {
    public enum StructType: Int, Codable { case elementary, vector, array, concatenated }
    public enum DataType: Int, Codable { case charString, implicitPoint, explicitPoint, explicitPointScaled, charBitString, bitString, mixed }

    public let tag: String
    public let length: Int
    public let position: Int
    
    public var structType: StructType = .elementary
    public var dataType: DataType = .charString
    public var name: String = ""
    public var array: String = ""
    public var format: String = ""
    public var isRepeatable: Bool = false
    
    public var subfieldDefs: [ISOSubfieldDef] = []
    
    var ascii: String = ""
    
    init(leader: ISOLeader, ascii: String) {
        var s: Int = 0; var e: Int = leader.sizeFieldTag
        tag = ascii[s..<e]
        s = e; e = s+leader.sizeFieldLength
        length = Int(ascii[s..<e])!
        s = e; e = s+leader.sizeFieldPosition
        position = Int(ascii[s..<e])!
    }
    
    var fixedWidth: Int? {
        var fixedWidth: Int = 0
        for subfieldDef: ISOSubfieldDef in subfieldDefs {
            guard subfieldDef.isFixedWidth else { return nil }
            fixedWidth += subfieldDef.formatWidth
        }
        return fixedWidth
    }
    var isFixedWidth: Bool { fixedWidth != nil }
    
    private func field(ascii: String, from: Int) -> String {
        var i: Int = from
        var result: String = ""
        while i < ascii.count 
                && ascii[i].first!.asciiValue != ISOModule.DDF_FIELD_TERMINATOR
                && ascii[i].first!.asciiValue != ISOModule.DDF_UNIT_TERMINATOR {
            result += ascii[i]
            i += 1
        }
        return result
    }
    func load(leader: ISOLeader, ascii: String) {
        self.ascii = ascii
        
        structType = StructType(rawValue: ascii.toInt(0..<1))!
        dataType = DataType(rawValue: ascii.toInt(1..<2))!
        
        var index: Int = leader.fieldControlLength
        name = field(ascii: ascii, from: index)
        index += name.count + 1
        array = field(ascii: ascii, from: index)
        index += array.count + 1
        format = field(ascii: ascii, from: index)
        
        guard structType != .elementary else { return }
        
        let tagsString: String
        if let lastIndex: String.Index = array.lastIndex(of: "*") {
            tagsString = String(array[array.index(after: lastIndex)...])
            isRepeatable = true
        } else { tagsString = array }
        
        let tags: [String] = tagsString.components(separatedBy: "!")
        tags.forEach { subfieldDefs.append(ISOSubfieldDef(tag: $0)) }
        
        guard !format.isEmpty else { return }
        
        let tokensString: String = format[1...(format.count-2)]
        let tokens: [String] = tokensString.components(separatedBy: ",")
        var formats: [String] = []
        tokens.forEach {
            var digits: String = ""
            var i: Int = 0
            while $0[i].first!.isNumber {
                digits.append($0[i])
                i += 1
            }
            let a: Int = digits.isEmpty ? 1 : Int(digits)!
            let format: String = $0[i...]
            for _ in 0..<a { formats.append(format) }
        }
        
        guard subfieldDefs.count == formats.count else { return }
        
        for i in 0..<subfieldDefs.count { subfieldDefs[i].format = formats[i] }
    }
    
    func noOfRows(data: Data) -> Int {
        guard isRepeatable else { return 1 }
        
        if let fixedWidth { return data.count / fixedWidth }
    
        var i: Int = 0
        var rows: Int = 0
        repeat {
            rows += 1
            for subfieldDef: ISOSubfieldDef in subfieldDefs {
                i += subfieldDef.width(data: data.advanced(by: i))
            }
        } while i < data.count - 1
        
        return rows
    }
}
