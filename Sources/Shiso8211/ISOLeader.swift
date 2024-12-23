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
    
    init?(data: Data) {
        guard let ascii: String = String(bytes: data, encoding: .ascii),
              let recordLength                  = Int(ascii[0...4]),
              let fieldAreaStart                = Int(ascii[12...16]),
              let sizeFieldLength               = Int(ascii[20]),
              let sizeFieldPosition             = Int(ascii[21]),
              let sizeFieldTag                  = Int(ascii[23])
        else { return nil }

        let interchangeLevel              = Int(ascii[5]) ?? 0
        let leaderIdentifier              = ascii[6]                  // "L" - unused
        let inlineCodeExtensionIndicator  = ascii[7]                  // "E" - unused
        let versionNumber                 = Int(ascii[8]) ?? 0        // "1" - unused
        let appIndicator                  = ascii[9]                  // " " - unused
        let fieldControlLength            = Int(ascii[10...11]) ?? 0  // "09" - fixed
        let extendedCharSet               = ascii[17...19]            // " ! " - unused
                                         // ascii[22]                 // "0" - reserved for future use
        
        self.recordLength = recordLength
        self.interchangeLevel = interchangeLevel
        self.leaderIdentifier = leaderIdentifier
        self.inlineCodeExtensionIndicator = inlineCodeExtensionIndicator
        self.versionNumber = versionNumber
        self.appIndicator = appIndicator
        self.fieldControlLength = fieldControlLength
        self.fieldAreaStart = fieldAreaStart
        self.extendedCharSet = extendedCharSet
        self.sizeFieldLength = sizeFieldLength
        self.sizeFieldPosition = sizeFieldPosition
        self.sizeFieldTag = sizeFieldTag
    }
    
    var fieldEntryLength: Int { sizeFieldTag + sizeFieldLength + sizeFieldPosition }
}
