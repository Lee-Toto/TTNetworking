//
//  DemoSmartCodableModel.swift
//  TTNetworking_Example
//
//  Created by LeeToto on 2025/11/21.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

public enum EnumDemoType: String, SmartCaseDefaultable {
    case EnumDemoType_One    = "EnumDemoType_One"
    case EnumDemoType_Two    = "EnumDemoType_Two"
    case EnumDemoType_Three  = "EnumDemoType_Three"
    case EnumDemoType_Four   = "EnumDemoType_Four"
}

public struct DemoSmartCodableModel: SmartCodable {
    
    var modelString: String?
    
    var modelInt: Int?
    
    var modelDouble: Int?
    
    var modelModel: DemoSmartCodableSubModel?
    
    public init() {}
}

public struct DemoSmartCodableSubModel: SmartCodable {
    
    var type: EnumDemoType?
    
    public static func mappingForValue() -> [SmartValueTransformer]? {
        [
            CodingKeys.type  <---  FastTransformer<EnumDemoType, String>(fromJSON: { value in
                EnumDemoType(rawValue: value ?? "")
            }, toJSON: { type in
                type?.rawValue
            })
        ]
    }
    
    public init() {}
}
