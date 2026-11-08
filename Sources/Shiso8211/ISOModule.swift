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
    
    /// A module read from a file.
    public convenience init?(path: String) {
        let fileHandle: FileHandle
        do { fileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: path)) }
        catch {
            print("Shiso8211 ISOModule Error: [\(error)]")
            return nil
        }
        defer { try? fileHandle.close() }
        self.init(read: { try fileHandle.read(upToCount: $0) })
    }
    /// A module read from memory: a file's bytes that never touch the disk (a chart opened from
    /// its encrypted form, say).
    public convenience init?(data: Data) {
        var offset: Int = 0
        self.init(read: { (count: Int) -> Data? in
            guard offset < data.count else { return nil }
            let end: Int = min(offset + max(count, 0), data.count)
            defer { offset = end }
            return Data(data[(data.startIndex + offset)..<(data.startIndex + end)])
        })
    }

    /// `read` hands back the next bytes asked for (fewer at the end, nil once there are none),
    /// indexed from 0.
    init?(read: (Int) throws -> Data?) {
        do {
            // Leader ==============================================================================
            guard let data: Data = try read(ISOModule.LEADER_SIZE), let leader = ISOLeader(data: data) else { return nil }
            self.leader = leader

            // Field Entries =======================================================================
            guard let entries: Data = try read(leader.fieldAreaStart - ISOModule.LEADER_SIZE) else { return nil }
            var fieldDefs: [ISOFieldDef] = []
            var i: Int = 0
            while i + leader.fieldEntryLength <= entries.count && entries[i] != ISOModule.DDF_FIELD_TERMINATOR {
                fieldDefs.append(ISOFieldDef(leader: leader, ascii: entries.ascii(i..<(i+leader.fieldEntryLength))))
                i += leader.fieldEntryLength
            }
            self.fieldDefs = fieldDefs

            // Field Definitions ===================================================================
            guard let definitions: Data = try read(leader.recordLength - leader.fieldAreaStart) else { return nil }
            self.fieldDefs.forEach { $0.load(leader: leader, ascii: definitions.ascii($0.position..<($0.position+$0.length))) }

            // Records =============================================================================
            while let record: ISORecord = ISORecord(module: self, read: read) {
                records.append(record)
            }
        }
        catch {
            print("Shiso8211 ISOModule Error: [\(error)]")
            return nil
        }
    }
    
    public func fieldDef(for tag: String) -> ISOFieldDef! {
        fieldDefs.first(where: { $0.tag == tag })!
    }
    
// Static ==========================================================================================
    static let LEADER_SIZE: Int = 24
    static let DDF_FIELD_TERMINATOR: UInt8 = 0x1E
    static let DDF_UNIT_TERMINATOR: UInt8 = 0x1F
}
