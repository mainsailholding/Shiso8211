//
//  ISOError.swift
//  ISO8211
//
//  Created by Joe Charlier on 6/23/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

struct ISOError: Error {
    enum Kind { case terminatorNotFound }
    let kind: Kind
}
