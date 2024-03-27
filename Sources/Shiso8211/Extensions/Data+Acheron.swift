//
//  Data+Acheron.swift
//  Acheron
//
//  Created by Joe Charlier on 4/23/19.
//  Copyright © 2019 Aepryus Software. All rights reserved.
//

import Foundation

public extension Data {
    func ascii(_ range: Range<Int>) -> String { String(data: self[range], encoding: .ascii)! }
}
