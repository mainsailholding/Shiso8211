//
//  String+Acheron.swift
//  Acheron
//
//  Created by Joe Charlier on 4/23/19.
//  Copyright © 2019 Aepryus Software. All rights reserved.
//

import Foundation

public extension String {
    subscript(i: Int) -> String {                                           // [a]
        String(self[index(startIndex, offsetBy: i)])
    }
    subscript(r: CountableClosedRange<Int>) -> String {                     // [a...b]
        String(self[index(startIndex, offsetBy: r.lowerBound)...index(startIndex, offsetBy: r.upperBound)])
    }
    subscript(r: CountablePartialRangeFrom<Int>) -> String {                // [a...]
        String(self[index(startIndex, offsetBy: r.lowerBound)..<endIndex])
    }
    subscript(r: PartialRangeThrough<Int>) -> String {                      // [...b]
        String(self[startIndex...index(startIndex, offsetBy: r.upperBound)])
    }
    subscript(r: PartialRangeUpTo<Int>) -> String {                         // [..<b]
        String(self[startIndex...index(startIndex, offsetBy: r.upperBound-1)])
    }
    subscript(r: Range<Int>) -> String {
        String(self[index(startIndex, offsetBy: r.lowerBound)..<index(startIndex, offsetBy: r.upperBound)])
    }
    
    func toInt(_ r: Range<Int>) -> Int { Int(self[r])! }
}
