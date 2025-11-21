//
//  TTTarget.swift
//  TTNetworking_Example
//
//  Created by Lee-Toto on 2024/2/23.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
@_exported import Moya
@_exported import RxSwift

public protocol LoadingPolicyProvider {
    var loadingPolicy: LoadingPolicy { get }
}

public enum LoadingPolicy {
    case autoHide(Bool) // 自动隐藏控制
    case manualControl  // 手动控制
}

public protocol TTTarget: TargetType, AccessTokenAuthorizable, LoadingPolicyProvider {
        
    var requestPath: TTPath { get }
    
    var parameter: [String: Any]? { get }
    
    var encoding: ParameterEncoding { get }
    
    var request: Single<Any?> { get }
}


extension TTTarget {
    
    public var authorizationType: AuthorizationType? {
        (TTRequestManager.shared.delegate?.token ?? "").isEmpty ? .basic : .bearer
    }
    
    public var request: Single<Any?> {
        provider.handleError(.target(self))
    }
    
    public var baseURL: URL {
        URL(string:TTRequestManager.shared.delegate?.baseUrl ?? "")!
    }
        
    public var path: String {
        requestPath.path
    }
    
    public var method: Moya.Method {
        requestPath.method
    }
    
    public var encoding: ParameterEncoding {
        requestPath.encoding
    }
    
    public var loadingPolicy: LoadingPolicy {
        .autoHide(true)
    }
    
    public var task: Moya.Task {
        guard let parameter = parameter else { return .requestPlain }
        return .requestParameters(parameters: parameter, encoding: requestPath.encoding)
    }
    
    public var headers: [String : String]? {
        TTRequestManager.shared.delegate?.header
    }

}

extension MultiTarget: TTTarget {
    
    public var requestPath: TTPath {
        (target as! TTTarget).requestPath
    }
    
    public var parameter: [String : Any]? {
        [:]
    }
    
    public var loadingPolicy: LoadingPolicy {
        if let neTarget = target as? TTTarget {
            return neTarget.loadingPolicy
        }
        return .autoHide(true)
    }
}


