//
//  ISOSubfield.swift
//  ISO8211
//
//  Created by Joe Charlier on 3/16/24.
//  Copyright © 2024 Aepryus Software. All rights reserved.
//

import Foundation

public class ISOSubfieldDef: Codable {
    enum BinaryType: Int { case notBinary, uInt, sInt, fpReal, floatReal, floatComplex }
    public enum DataType: String, Codable { case int8, int16, int32, uInt8, uInt16, uInt32, float, double, string, binary }
    public enum StringType: String, Codable { case string, int, double }
    
    public let tag: String
    public var format: String = "" {
        didSet { compile() }
    }
    public var dataType: DataType = .int8
    public var stringType: StringType? = nil
    public var formatWidth: Int = 0
    
    init(tag: String) {
        self.tag = tag
    }
    
    var isFixedWidth: Bool { formatWidth != 0 }
    
    private func compile() {
        guard !format.isEmpty else { return }
        
        if format.count > 1 && format[1] == "(" { formatWidth = Int(format[2...format.count-2]) ?? 0 }
        
        switch format[0] {
        case "A", "C":
            dataType = .string
            stringType = .string
        case "I", "S":
            dataType = .string
            stringType = .int
        case "R":
            dataType = .string
            stringType = .double
        case "B", "b":
            if format[1] == "(" {
                formatWidth = Int(format[2...format.count-2])! / 8
                dataType = .binary
            } else {
                let binaryType: BinaryType = BinaryType(rawValue: Int(format[1...1])!)!
                formatWidth = Int(format[2...2])!
                switch binaryType {
                case .uInt:
                    switch formatWidth {
                    case 1: dataType = .uInt8
                    case 2: dataType = .uInt16
                    case 4: dataType = .uInt32
                    default: fatalError()
                    }
                case .sInt:
                    switch formatWidth {
                    case 1: dataType = .int8
                    case 2: dataType = .int16
                    case 4: dataType = .int32
                    default: fatalError()
                    }
                case .floatReal:
                    switch formatWidth {
                    case 4: dataType = .float
                    case 8: dataType = .double
                    default: fatalError()
                    }
                case .notBinary, .fpReal, .floatComplex:
                    fatalError()
                }
            }
        default: fatalError()
        }
    }
    
    func width(data: Data, encoding: Encoding) -> Int {
        guard !data.isEmpty else { return 0 }
        if isFixedWidth { return min(formatWidth, data.count) }
        if let range = data.range(of: encoding.unitTerminator) { return range.lowerBound + encoding.width }
        return data.count
    }
    
    func load(from data: Data, into value: ISOValue, encoding: Encoding) throws -> Int {
        let dataWidth: Int
        if isFixedWidth { dataWidth = formatWidth }
        else {
            guard let firstIndex: Int = data.range(of: encoding.unitTerminator)?.lowerBound else {
                throw ISOError(kind: .terminatorNotFound)
            }
            dataWidth = firstIndex - data.startIndex
        }
        
        /* =========================================================================================
         The new Data instance is created here instead of just passing the slice, in order to ensure
         byte alignment.  Without data alignment (startIndex % 2, % 4 == 0) $0.load will crash.
         ========================================================================================= */
        let valueData: Data = Data(data[data.startIndex..<(data.startIndex+dataWidth)])
        switch dataType {
        case .int8: value.int8 = valueData.withUnsafeBytes { $0.load(as: Int8.self) }
        case .int16: value.int16 = valueData.withUnsafeBytes { $0.load(as: Int16.self) }
        case .int32: value.int32 = valueData.withUnsafeBytes { $0.load(as: Int32.self) }
        case .uInt8: value.uInt8 = valueData.withUnsafeBytes { $0.load(as: UInt8.self) }
        case .uInt16: value.uInt16 = valueData.withUnsafeBytes { $0.load(as: UInt16.self) }
        case .uInt32: value.uInt32 = valueData.withUnsafeBytes { $0.load(as: UInt32.self) }
        case .float: value.float = valueData.withUnsafeBytes { $0.load(as: Float.self) }
        case .double: value.double = valueData.withUnsafeBytes { $0.load(as: Double.self) }
        case .string:
            guard let stringType else { fatalError() }
            switch stringType {
            case .string: value.string = String(data: valueData, encoding: encoding == .oneByte ? .utf8 : .utf16) ?? ""
            case .int: value.int32 = Int32(String(data: valueData, encoding: .ascii) ?? "0") ?? 0
            case .double: value.double = Double(String(data: valueData, encoding: .ascii) ?? "0") ?? 0
            }
        case .binary: value.binary = [UInt8](valueData)
        }
        return dataWidth + (isFixedWidth ? 0 : encoding.width)
    }
}
