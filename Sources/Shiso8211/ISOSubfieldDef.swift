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
    
    func width(data: Data) -> Int {
        guard data.count > 0 else { return 0 }
        if isFixedWidth { return min(formatWidth, data.count) }
        else {
            var width: Int = 0
            while width < data.count && data[data.startIndex+width] != ISOModule.DDF_UNIT_TERMINATOR {
                if 32...127 ~= data[data.startIndex] && data[data.startIndex+width] == ISOModule.DDF_FIELD_TERMINATOR { break }
                width += 1
            }
            return width + (data.count == 0 ? 0 : 1)
        }
    }
    
    func load(from data: Data, into value: ISOValue) -> Int {
        let dataWidth: Int = isFixedWidth ? formatWidth : data.firstIndex(of: ISOModule.DDF_UNIT_TERMINATOR)! - data.startIndex
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
            let string: String = String(data: valueData, encoding: .ascii) ?? ""
            switch stringType {
            case .string: value.string = string
            case .int: value.int32 = Int32(string) ?? 0
            case .double: value.double = Double(string) ?? 0
            }
        case .binary: value.binary = [UInt8](valueData)
        }
        return dataWidth + (isFixedWidth ? 0 : 1)
    }
}
