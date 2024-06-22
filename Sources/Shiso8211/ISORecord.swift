//
//  ISORecord.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/17/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

public class ISORecord: Codable {
    public let leader: ISOLeader
    public let fields: [ISOField]
    
    public init?(module: ISOModule, fileHandle: FileHandle) {
        do {
            // Leader ==============================================================================
            var data: Data! = try fileHandle.read(upToCount: ISOModule.LEADER_SIZE)
            guard data != nil, let leader = ISOLeader(data: data) else { return nil }
            self.leader = leader
            
            // Fields ==============================================================================
            data = try fileHandle.read(upToCount: leader.fieldAreaStart - ISOModule.LEADER_SIZE)!
            var fields: [ISOField] = []
            var i: Int = 0
            while data[i] != ISOModule.DDF_FIELD_TERMINATOR {
                fields.append(ISOField(leader: leader, ascii: data.ascii(i..<(i+leader.fieldEntryLength))))
                i += leader.fieldEntryLength
            }
            self.fields = fields
            
            // Field Data ==========================================================================
            data = try fileHandle.read(upToCount: leader.recordLength - leader.fieldAreaStart)!
            try self.fields.forEach {
                try $0.load(module: module, data: data[$0.position..<($0.position+$0.length)])
            }
        }
        catch { return nil }
    }
    
    public func data(tag: String, row: Int, data: String) -> ISOValue? {
        guard let field: ISOField = fields.first(where: { $0.tag == tag }),
              row < field.rows.count
        else { return nil }
        let row: ISORow = field.rows[row]
        return row.values.first(where: { $0.name == data })
    }
    public func rowCount(tag: String) -> Int {
        guard let field: ISOField = fields.first(where: { $0.tag == tag }) else { return 0 }
        return field.rows.count
    }
}
