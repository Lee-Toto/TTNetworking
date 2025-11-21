//
//  DemoService.swift
//  TTNetworking_Example
//
//  Created by LeeToto on 2025/11/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

public enum DemoService {
    
    case postDefaultCodeDemo(_ name: String)
    
    case postURLEncodingDemo(_ name: String)
    
    case postNoParam
    
    case getDefaultCodeDemo(_ name: String)
    
    case getJSONEncodingDemo(_ name: String)
    
    case getNoParam
    
    case refreshToken(_ token: String)
    
}

extension DemoService: TTTarget {
    
    public var requestPath: TTNetworking.TTPath {
        switch self {
        case .postDefaultCodeDemo:
            return .post("/demo/path/post/coding/default")
        case .postURLEncodingDemo:
            return .post("/demo/path/post/coding/URLEncoding", encoding: URLEncoding.default)
        case .postNoParam:
            return .post("/demo/path/post/param/none")
        case .getDefaultCodeDemo:
            return .get("/demo/path/get/coding/default")
        case .getJSONEncodingDemo:
            return .get("/demo/path/get/coding/JSONEncoding", encoding: JSONEncoding.default)
        case .getNoParam:
            return .get("/demo/path/get/param/none")
        case .refreshToken:
            return .post("demo/path/post/refreshToken")
        }
    }
    
    public var parameter: [String : Any]? {
        var parameters: [String: Any] = [:]
        parameters["commonParam"] = "commonParam"
        switch self {
        case let .postDefaultCodeDemo(name):
            parameters["name"] = name
        case let .postURLEncodingDemo(name):
            parameters["name"] = name
        case let .getDefaultCodeDemo(name):
            parameters["name"] = name
        case let .getJSONEncodingDemo(name):
            parameters["name"] = name
        case let .refreshToken(token):
            parameters["refresh_token"] = token
        default:
            break
        }
        
        return parameters
    }
}
