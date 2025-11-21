//
//  TTNetworking+SmartCodable.swift
//  Pods
//
//  Created by Lee-Toto on 2024/10/11.
//

import SmartCodable

public struct PageModel<T: SmartCodable>: SmartCodable {
    
    public var pageNum = 1
    public var pageSize = 10
    public var totalPage = 0
    public var total = 0
    public var list = [T]()
    public var hasNext : Bool {
        pageNum < totalPage
    }
    
    public init() {}
    
}

public extension PrimitiveSequence where Trait == SingleTrait {
    
    func mapObject<T: SmartCodable>(_ type: T.Type) -> PrimitiveSequence<Trait, T> {
        return self.map { (object) -> T in
            T.deserialize(from: object as? [String:Any]) ?? .init()
        }
    }
    
    func mapList<T: SmartCodable>(_ type: T.Type, key: String? = nil) -> PrimitiveSequence<Trait, [T]> {
        return self.map { (object) -> [T] in
            if let array = object as? [[String:Any]] {
                return [T].deserialize(from: array) ?? []
            }
            if let json = object as? [String: Any],let key = key,let array = json[key] as? [[String:Any]] {
                return [T].deserialize(from: array) ?? []
            }
            return []
        }
    }
    
    func mapPageList<T: SmartCodable>(_ type: T.Type) -> PrimitiveSequence<Trait, PageModel<T>> {
        return mapObject(PageModel<T>.self)
    }
    
    func mapStringList(key: String? = nil) -> PrimitiveSequence<Trait, [String]> {
        return self.map { (object) -> [String] in
            if let array = object as? [String] {
                return array
            }
            if let json = object as? [String: Any], let key = key, let array = json[key] as? [String] {
                return array
            }
            return []
        }
    }
    
    func mapString(key: String? = nil) -> PrimitiveSequence<Trait, String?> {
        return self.map { (object) -> String? in
            if let string = object as? String {
                return string
            }
            if let json = object as? [String: Any], let key = key, let string = json[key] as? String {
                return string
            }
            return nil
        }
    }
}

public struct TransformOf<ObjectType, JSONType>: ValueTransformable {
    private let fromJSON: (JSONType?) -> ObjectType?
    private let toJSON: (ObjectType?) -> JSONType?

    public init(fromJSON: @escaping(JSONType?) -> ObjectType?, toJSON: @escaping(ObjectType?) -> JSONType?) {
        self.fromJSON = fromJSON
        self.toJSON = toJSON
    }
    
    public func transformFromJSON(_ value: Any) -> ObjectType?? {
        let value = fromJSON(value as? JSONType)
        return value
    }

    public func transformToJSON(_ value: ObjectType?) -> JSONType? {
        return toJSON(value)
    }
}

public extension SmartEncodable {
    
    func toJSON() -> [String: Any] {
        toDictionary() ?? [:]
    }
}
