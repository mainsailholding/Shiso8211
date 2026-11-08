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
    
    public convenience init?(module: ISOModule, fileHandle: FileHandle) {
        self.init(module: module, read: { try fileHandle.read(upToCount: $0) })
    }
    /// The module's next record, from `read` (see ISOModule.init(read:)); nil at the end.
    init?(module: ISOModule, read: (Int) throws -> Data?) {
        do {
            // Leader ==============================================================================
            guard let data: Data = try read(ISOModule.LEADER_SIZE), let leader = ISOLeader(data: data) else { return nil }
            self.leader = leader
            
            // Fields ==============================================================================
            guard let entries: Data = try read(leader.fieldAreaStart - ISOModule.LEADER_SIZE) else { return nil }
            var fields: [ISOField] = []
            var i: Int = 0
            while i + leader.fieldEntryLength <= entries.count && entries[i] != ISOModule.DDF_FIELD_TERMINATOR {
                fields.append(ISOField(leader: leader, ascii: entries.ascii(i..<(i+leader.fieldEntryLength))))
                i += leader.fieldEntryLength
            }
            self.fields = fields
            
            // Field Data ==========================================================================
            guard let values: Data = try read(leader.recordLength - leader.fieldAreaStart) else { return nil }
            self.fields.forEach {
                do { try $0.load(module: module, data: values[$0.position..<($0.position+$0.length)]) }
                catch { print("Shiso8211 Error [tag:\($0.tag)]: \(error)") }
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
