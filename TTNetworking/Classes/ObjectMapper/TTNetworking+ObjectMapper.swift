//
//  TTNetworking+ObjectMapper.swift
//  Pods
//
//  Created by Lee-Toto on 2024/10/11.
//

import ObjectMapper

public struct PageModel<T: Mappable>: Mappable {
    
    public var pageNum = 1
    public var pageSize = 10
    public var totalPage = 0
    public var total = 0
    public var list = [T]()
    public var hasNext = false
    
    public init?(map: ObjectMapper.Map) {
    }
    
    mutating public func mapping(map: ObjectMapper.Map) {
        pageNum          <- map["pageNum"]
        pageSize         <- map["pageSize"]
        totalPage        <- map["totalPage"]
        total            <- map["total"]
        list             <- map["list"]
        hasNext          <- map["hasNext"]
    }
    
    
}

public extension PrimitiveSequence where Trait == SingleTrait {
    
    func mapObject<T: BaseMappable>(_ type: T.Type) -> PrimitiveSequence<Trait, T> {
        return self.map { (object) -> T in
            if let model = Mapper<T>().map(JSON: object as? [String:Any] ?? [:]) {
                return model
            }
            return Mapper<T>.init() as! T
        }
    }
    
    func mapList<T: BaseMappable>(_ type: T.Type, key: String? = nil) -> PrimitiveSequence<Trait, [T]> {
        return self.map { (object) -> [T] in
            if let array = object as? [[String:Any]] {
                return Mapper<T>().mapArray(JSONArray: array)
            }
            if let json = object as? [String: Any],let key = key,let array = json[key] as? [[String:Any]] {
                return Mapper<T>().mapArray(JSONArray: array)
            }
            return []
        }
    }
    func mapPageList<T: BaseMappable>(_ type: T.Type) -> PrimitiveSequence<Trait, PageModel<T>> {
        return self.mapObject(PageModel<T>.self)
    }
}
