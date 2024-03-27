//
//  Array+Acheron.swift
//  Acheron
//
//  Created by Joe Charlier on 5/10/19.
//  Copyright © 2019 Aepryus Software. All rights reserved.
//

import Foundation

public extension Collection {
    func summate<T: BinaryInteger>(_ value: (Element)->(T)) -> T {
        var sum: T = 0
        forEach { sum += value($0) }
        return sum
    }
}
