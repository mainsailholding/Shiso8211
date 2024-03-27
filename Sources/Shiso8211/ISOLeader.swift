//
//  ISOLeader.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/20/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

public class ISOLeader: Codable {
    let recordLength: Int
    let interchangeLevel: Int
    let leaderIdentifier: String
    let inlineCodeExtensionIndicator: String
    let versionNumber: Int
    let appIndicator: String
    let fieldControlLength: Int
    let fieldAreaStart: Int
    let extendedCharSet: String
    let sizeFieldLength: Int
    let sizeFieldPosition: Int
    let sizeFieldTag: Int
    
    init(data: Data) {
        let ascii: String = String(bytes: data, encoding: .ascii)!
        recordLength                    = Int(ascii[0...4])!
        interchangeLevel                = Int(ascii[5]) ?? 0        // "3" - unused
        leaderIdentifier                = ascii[6]                  // "L" - unused
        inlineCodeExtensionIndicator    = ascii[7]                  // "E" - unused
        versionNumber                   = Int(ascii[8]) ?? 0        // "1" - unused
        appIndicator                    = ascii[9]                  // " " - unused
        fieldControlLength              = Int(ascii[10...11]) ?? 0  // "09" - fixed
        fieldAreaStart                  = Int(ascii[12...16])!
        extendedCharSet                 = ascii[17...19]            // " ! " - unused
        sizeFieldLength                 = Int(ascii[20])!
        sizeFieldPosition               = Int(ascii[21])!
                                       // ascii[22]                 // "0" - reserved for future use
        sizeFieldTag                    = Int(ascii[23])!
    }
    
    var fieldEntryLength: Int { sizeFieldTag + sizeFieldLength + sizeFieldPosition }
}
