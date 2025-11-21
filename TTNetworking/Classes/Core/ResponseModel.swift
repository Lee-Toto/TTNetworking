//
//  ResponseModel.swift
//  TTNetworking
//
//  Created by Lee-Toto on 2024/4/26.
//

import Foundation

public enum JSONValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null
    
    var value: Any? {
        switch self {
        case .string(let string):
            return string
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .bool(let bool):
            return bool
        case .object(let dictionary):
            return dictionary
        case .array(let array):
            return array
        case .null:
            return nil
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .bool(let bool):
            try container.encode(bool)
        case .object(let dictionary):
            try container.encode(dictionary)
        case .array(let array):
            try container.encode(array)
        case .null:
            try container.encodeNil()
        }
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if container.decodeNil() {
            self = .null
        }else{
            throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
        }
    }
}

public struct ResponseModel: Codable {
    public var code = ResponseCode.success.rawValue
    public var msg = ""
    public var tmpData: JSONValue?
    public var data: Any?
    public var swTraceId: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg, data, swTraceId
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(msg, forKey: .msg)
        try container.encode(swTraceId, forKey: .swTraceId)
        try container.encode(tmpData, forKey: .data)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(Int.self, forKey: .code)
        msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        let tmpData = try values.decodeIfPresent(JSONValue.self, forKey: .data)
        self.tmpData = tmpData
        let encodeData = try JSONEncoder().encode(tmpData)
        if let jsonData = try? JSONSerialization.jsonObject(with: encodeData) {
            data = jsonData
        }else {
            data = tmpData?.value
        }
        swTraceId = try values.decodeIfPresent(String.self, forKey: .swTraceId)
    }
}

public extension PrimitiveSequence where Trait == SingleTrait {
    
    func mapPrimary<T>(_ type: T.Type) -> PrimitiveSequence<Trait, T?> {
        return self.map { (object) -> T? in
              object as? T
        }
    }
}
