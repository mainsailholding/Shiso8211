//
//  File.swift
//  
//
//  Created by Joe Charlier on 4/22/24.
//

import Foundation

public extension Collection {
    func summate<T: BinaryInteger>(_ value: (Element)->(T)) -> T {
        var sum: T = 0
        forEach { sum += value($0) }
        return sum
    }
}

extension Decodable {
    public init?(json: String) {
        guard let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        do {
            self = try decoder.decode(Self.self, from: data)
        } catch {
            print("ERROR: Decodable.init?(json: String) [\(error)]")
            return nil
        }
    }
}
extension Encodable {
    public func toJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }
}

public extension Data {
    func ascii(_ range: Range<Int>) -> String { String(data: self[range], encoding: .ascii)! }
}

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
