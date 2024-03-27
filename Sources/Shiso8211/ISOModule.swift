//
//  ISOModule.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/16/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

public class ISOModule: Codable {
    let leader: ISOLeader
    public let fieldDefs: [ISOFieldDef]
    public var records: [ISORecord] = []
    
    public init?(path: String) {
        do {
            let fileHandle: FileHandle = try FileHandle.init(forReadingFrom: URL(fileURLWithPath: path))
            
            // Leader ==============================================================================
            var data: Data = try fileHandle.read(upToCount: ISOModule.LEADER_SIZE)!
            leader = ISOLeader(data: data)
            
            // Field Entries =======================================================================
            data = try fileHandle.read(upToCount: leader.fieldAreaStart - ISOModule.LEADER_SIZE)!
            var fieldDefs: [ISOFieldDef] = []
            var i: Int = 0
            while data[i] != ISOModule.DDF_FIELD_TERMINATOR {
                fieldDefs.append(ISOFieldDef(leader: leader, ascii: data.ascii(i..<(i+leader.fieldEntryLength))))
                i += leader.fieldEntryLength
            }
            self.fieldDefs = fieldDefs
            
            // Field Definitions ===================================================================
            data = try fileHandle.read(upToCount: leader.recordLength - leader.fieldAreaStart)!
            self.fieldDefs.forEach { $0.load(leader: leader, ascii: data.ascii($0.position..<($0.position+$0.length))) }
            
            // Records =============================================================================
            while let record: ISORecord = ISORecord(module: self, fileHandle: fileHandle) {
                records.append(record)
            }
        }
        catch { return nil }
    }
    
    public func fieldDef(for tag: String) -> ISOFieldDef! {
        fieldDefs.first(where: { $0.tag == tag })!
    }
    
// Static ==========================================================================================
    static let LEADER_SIZE: Int = 24
    static let DDF_FIELD_TERMINATOR: UInt8 = 30
    static let DDF_UNIT_TERMINATOR: UInt8 = 31
}
