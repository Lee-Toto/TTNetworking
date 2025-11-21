//
//  TTPath.swift
//  TTNetworking
//
//  Created by Lee-Toto on 2024/8/20.
//

import Foundation
import Alamofire

public enum TTPath {
    
    case get(_ url: String, encoding: ParameterEncoding = URLEncoding.default)
    case post(_ url: String , encoding: ParameterEncoding = JSONEncoding.default)
    case put(_ url: String, encoding: ParameterEncoding = JSONEncoding.default)
    case delete(_ url: String, encoding: ParameterEncoding = JSONEncoding.default)
    
    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case let .delete(path,_),
            let .get(path,_),
            let .post(path,_),
            let .put(path,_):
            return path
        }
    }
    
    var encoding : ParameterEncoding {
        switch self {
        case let .get(_, encoding),
            let .post(_, encoding),
            let .put(_, encoding),
            let .delete(_, encoding):
            return encoding
        }
    }
}
